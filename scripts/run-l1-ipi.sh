#!/bin/bash
BZIMAGE=/mnt/subdisk/images/bzImage-dvhipiL1
FS=/mnt/subdisk/images/noble.img
SEED=/mnt/subdisk/images/seed.img
MONPORT=5555

taskset -c 0 qemu-system-x86_64 \
    -enable-kvm \
    -machine q35,accel=kvm \
    -cpu host \
    -smp 4 \
    -m 16G \
    -nographic \
    -display none \
    -kernel $BZIMAGE \
    -drive if=none,file=$FS,id=vda,format=qcow2 \
    -device virtio-blk-pci,drive=vda \
    -drive if=none,file=$SEED,id=vdb,format=raw \
    -device virtio-blk-pci,drive=vdb \
    -serial mon:stdio \
    -netdev user,id=net0,hostfwd=tcp::2222-:22,hostfwd=tcp::3333-:3333 \
    -device virtio-net-pci,netdev=net0,mac=de:ad:be:ef:41:49 \
    -append "root=/dev/vda1 rw console=ttyS0 net.ifnames=0 nowatchdog nmi_watchdog=0 x2apic_phys" \
    -monitor telnet:127.0.0.1:${MONPORT},server,nowait
