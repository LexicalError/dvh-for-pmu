#!/bin/bash

L2_IP="localhost" 
L2_PORT="2222"
L2_USER="root"

echo "[*] Starting Context Switch Migration Test..."

echo "[*] Launching workload inside L2..."
ssh ${L2_USER}@${L2_IP} -p ${L2_PORT} "nohup perf stat -e instructions,cycles,cache-misses,branch-misses,branches /host/bench/loop > /tmp/perf_result.txt 2>&1 &"

QEMU_PID=$(pgrep -f "qemu-system-x86_64")
if [ -z "$QEMU_PID" ]; then
    echo "[!] Error: Could not find QEMU process/"
    exit 1
fi

VCPU_TID=$(ps -T -p $QEMU_PID | grep "CPU 0/KVM" | awk '{print $2}')
if [ -z "$VCPU_TID" ]; then
    VCPU_TID=$(ps -T -p $QEMU_PID | tail -n +3 | head -n 1 | awk '{print $2}')
fi

echo "[*] Found L2 vCPU Thread: $VCPU_TID"

# 3. Force brutal core migration every 1 second while L2 is running
echo "[*] Initiating violent core migrations..."
for core in 0 1 2 3 0 1 2 3; do
    echo "    -> Pinning L2 vCPU to L1 Core $core"
    taskset -pc $core $VCPU_TID > /dev/null
    sleep 1
done

# 4. Wait for L2 workload to finish and fetch results
echo "[*] Waiting for L2 workload to complete..."
ssh ${L2_USER}@${L2_IP} -p ${L2_PORT} "while pgrep /host/bench/loop > /dev/null; do sleep 1; done"

echo "[*] Migration complete. Fetching L2 Perf Results:"
echo "---------------------------------------------------"
ssh ${L2_USER}@${L2_IP} -p ${L2_PORT} "cat /tmp/perf_result.txt"