#!/bin/bash

cd $1

PMU_TESTS=(
    "r_perf_capabilities"
    "r_perf_global_status"
    "w_perf_global_ctrl"
    "w_perf_fixed_ctr_ctrl"
    "w_p6_evntsel0"
    "w_perfctr0"
    "w_pmc0"
    "w_perf_fixed_ctr0"
)

echo "========================================"
echo " Starting PMU / LBR Microbenchmarks"
echo "========================================"

# Loop through each test and run it in isolation
for test in "${PMU_TESTS[@]}"; do
    echo -e "\n---> Benchmarking: $test"
    # -cpu host,pmu=on is required to expose the PMU to the guest
    # -append "$test" tells vmexit's main() function to only execute this specific test
    ./x86-run x86/vmexit.flat -cpu host,pmu=on -append "$test"
done

echo -e "\n========================================"
echo " Benchmarks Complete"
echo "========================================"
