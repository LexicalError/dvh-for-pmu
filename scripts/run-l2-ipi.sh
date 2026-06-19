#!/bin/bash
BZIMAGE=/home/ubuntu/bzImage-dvhipiL1
FS=/home/ubuntu/nobleL2.img
SEED=/home/ubuntu/seed.img
MONPORT=6666

taskset -c 0 qemu-system-x86_64 \
    -enable-kvm \
    -machine q35,accel=kvm \
    -cpu host \
    -smp 2 \
    -m 8G \
    -nographic \
    -display none \
    -kernel $BZIMAGE \
    -drive if=none,file=$FS,id=vda,format=qcow2 \
    -device virtio-blk-pci,drive=vda \
    -drive if=none,file=$SEED,id=vdb,format=raw \
    -device virtio-blk-pci,drive=vdb \
    -serial mon:stdio \
    -netdev user,id=net0,hostfwd=tcp::3333-:22 \
    -device virtio-net-pci,netdev=net0,mac=de:ad:be:ef:49:41 \
    -append "root=/dev/vda1 rw console=ttyS0 net.ifnames=0 nowatchdog nmi_watchdog=0 x2apic_phys idle=poll" \
    -monitor telnet:127.0.0.1:${MONPORT},server,nowait
