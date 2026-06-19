#!/bin/bash

set -e

NAME=$1
SIZE=$2
IMAGE=$3

MOUNT_DIR=$(mktemp -d -p .)
echo "Created temporary mount point: ${MOUNT_DIR}"

cleanup() {
    echo "Cleaning up..."
    if mountpoint -q "${MOUNT_DIR}"; then
        sudo umount "${MOUNT_DIR}"
    fi
    rm -rf "${MOUNT_DIR}"
}
trap cleanup EXIT INT TERM

qemu-img create -f raw ${NAME} ${SIZE}
mkfs.ext4 ${NAME}
sudo mount ${NAME} "${MOUNT_DIR}"

tar -xvf "${TAR_IMAGE}" --transform='s|.*/||' -O > extracted_disk.img
qemu-img convert -f raw extracted_disk.img "${NAME}"
qemu-img resize "${NAME}" "${SIZE}"

# Networking
sudo mkdir -p "${MOUNT_DIR}"/etc/systemd/network
cat <<EOF | sudo tee "${MOUNT_DIR}"/etc/systemd/network/20-wired.network
[Match]
Name=en*

[Network]
DHCP=yes
EOF
sudo mkdir -p "${MOUNT_DIR}"/etc/systemd/system/multi-user.target.wants
sudo ln -sf /lib/systemd/system/systemd-networkd.service "${MOUNT_DIR}"/etc/systemd/system/multi-user.target.wants/systemd-networkd.service

sudo mkdir -p "${MOUNT_DIR}"/host
cat <<EOF | sudo tee -a "${MOUNT_DIR}"/etc/fstab

# Auto-mount QEMU 9pfs share
hostshare    /host    9p    trans=virtio,version=9p2000.L,rw,_netdev    0   0
EOF

sudo sed -i 's/^root:x:/root::/' "${MOUNT_DIR}"/etc/passwd
sync