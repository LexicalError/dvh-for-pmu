#!/bin/bash

# --- Configuration: Update these paths to your custom .ko files ---
IRQ_BYPASS_KO="/host/img/irqbypass.ko"
KVM_KO="/host/img/kvm.ko"
KVM_INTEL_KO="/host/img/kvm-intel.ko"
# -----------------------------------path/to/your/irq_bypass.ko-------------------------------

PARAM_VALUE=$1

echo "=== Step 0: Killing all qemu-system-x86_64 processes ==="
if pgrep -f "qemu-system-x86_64" > /dev/null; then
    echo "Found running QEMU processes. Terminating..."
    pkill -9 -f "qemu-system-x86_64"
    sleep 1
else
    echo "No running QEMU processes found."
fi

echo -e "\n=== Step 1: Checking irq_bypass module ==="
if lsmod | grep -q "^irqbypass"; then
    echo "irq_bypass is already loaded."
else
    echo "irq_bypass is not loaded. Installing custom .ko..."
    if [ ! -f "$IRQ_BYPASS_KO" ]; then
        echo "Error: Custom irq_bypass.ko not found at $IRQ_BYPASS_KO"
        exit 1
    fi
    insmod "$IRQ_BYPASS_KO"
    if [ $? -eq 0 ]; then
        echo "Successfully loaded irq_bypass."
    else
        echo "Failed to insmod irq_bypass. Exiting."
        exit 1
    fi
fi

echo -e "\n=== Step 2: Removing existing kvm_intel and kvm modules ==="
if lsmod | grep -q "^kvm_intel"; then
    echo "Removing kvm_intel..."
    rmmod kvm_intel
fi

if lsmod | grep -q "^kvm"; then
    echo "Removing kvm..."
    rmmod kvm
fi

echo "Loading custom kvm..."
insmod "$KVM_KO"

echo "Loading custom kvm_intel with dvh_pmu_passthrough=$PARAM_VALUE..."
insmod "$KVM_INTEL_KO" dvh_pmu_passthrough=$PARAM_VALUE

if [ $? -ne 0 ]; then
    echo "Error: Failed to insmod kvm_intel."
    exit 1
fi

echo -e "\n=== Step 4: Verifying the parameter ==="
PARAM_PATH="/sys/module/kvm_intel/parameters/dvh_pmu_passthrough"

if [ -f "$PARAM_PATH" ]; then
    echo "Parameter path: $PARAM_PATH"
    echo -n "Current Value: "
    cat "$PARAM_PATH"
else
    echo "Error: Parameter file not found at $PARAM_PATH"
    echo "Listing available kvm_intel parameters:"
    ls /sys/module/kvm_intel/parameters/ 2>/dev/null || echo "kvm_intel module directory not found."
fi