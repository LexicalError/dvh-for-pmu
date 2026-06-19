#!/bin/bash
set -e

NAME=$1
IMAGE=$2

if [ -z "$NAME" ] || [ -z "$IMAGE" ]; then
    echo "Usage: ./create_disk.sh <output_name.img> <base_image.[tar.xz|qcow2]>"
    exit 1
fi

MOUNT_DIR=$(mktemp -d -p .)
LOOP_DEV=""

cleanup() {
    echo "[*] Cleaning up..."
    if mountpoint -q "${MOUNT_DIR}"; then
        sudo umount "${MOUNT_DIR}"
    fi
    if [ -n "$LOOP_DEV" ]; then
        sudo losetup -d "$LOOP_DEV"
    fi
    rm -rf "${MOUNT_DIR}"
}
trap cleanup EXIT INT TERM

echo "[*] 1. Extracting base image..."
if [[ "${IMAGE}" == *.tar.xz ]]; then
    tar -xOf "${IMAGE}" > "${NAME}"
elif [[ "${IMAGE}" == *.qcow2 ]]; then
    qemu-img convert -f qcow2 -O raw "${IMAGE}" "${NAME}"
else
    cp "${IMAGE}" "${NAME}"
fi

echo "[*] 2. Mapping partitions..."
LOOP_DEV=$(sudo losetup -Pf --show "${NAME}")
sleep 2 

ROOT_PART="${LOOP_DEV}p1"

echo "[*] 3. Mounting root filesystem..."
sudo mount "${ROOT_PART}" "${MOUNT_DIR}"

echo "[*] 4. Applying custom DVH configurations..."

# --- Networking ---
sudo mkdir -p "${MOUNT_DIR}/etc/systemd/network"
cat <<EOF | sudo tee "${MOUNT_DIR}/etc/systemd/network/20-wired.network" > /dev/null
[Match]
Name=en*

[Network]
DHCP=yes
EOF

# Kill the 2-minute hang
sudo mkdir -p "${MOUNT_DIR}/etc/systemd/system/multi-user.target.wants"
sudo ln -sf /lib/systemd/system/systemd-networkd.service "${MOUNT_DIR}/etc/systemd/system/multi-user.target.wants/systemd-networkd.service"
sudo ln -sf /dev/null "${MOUNT_DIR}/etc/systemd/system/systemd-networkd-wait-online.service"

# --- Host Mount Setup ---
sudo mkdir -p "${MOUNT_DIR}/host"
cat <<EOF | sudo tee -a "${MOUNT_DIR}/etc/fstab" > /dev/null
# Auto-mount QEMU 9pfs share
hostshare   /host   9p  trans=virtio,version=9p2000.L,msize=104857600   0   0
EOF

# Empty root passwd
sudo sed -i 's|^root:[^:]*|root:|' "${MOUNT_DIR}/etc/shadow"

echo "[*] Disk ${NAME} created successfully! (Unmounting now...)"