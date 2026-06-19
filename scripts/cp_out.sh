#!/bin/bash

scp ./virt/lib/irqbypass.ko $1
scp ./arch/x86/kvm/kvm.ko $1
scp ./arch/x86/kvm/kvm-intel.ko $1
scp ./arch/x86/boot/bzImage $1