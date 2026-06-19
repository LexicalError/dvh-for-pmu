#!/bin/bash

cp ./virt/lib/irqbypass.ko $1
cp ./arch/x86/kvm/kvm.ko $1
cp ./arch/x86/kvm/kvm-intel.ko $1
cp ./arch/x86/boot/bzImage $1