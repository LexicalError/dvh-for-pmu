#!/bin/bash

# Default variables
ITERATIONS=50
OUT_FILE="microbench_results.csv"
CORE_PIN=4
AUTO_MAKE=0

# The usage function
usage() {
    echo -e "Usage: $0 [options] <path_to_kvm_unit_tests>"
    echo -e ""
    echo -e "Options:"
    echo -e "  -i, --iterations <N>   Number of iterations to run each test (default: $ITERATIONS)"
    echo -e "  -c, --core <N>         Physical core to pin the QEMU process (default: $CORE_PIN)"
    echo -e "  -m, --make             Automatically run './configure' and 'make' before testing"
    echo -e "  -o, --out <file>       Output CSV file name (default: $OUT_FILE)"
    echo -e "  -h, --help             Show this help message and exit"
    echo -e ""
    echo -e "Example:"
    echo -e "  $0 -m -i 100 -c 2 /host/kvm-unit-tests"
}

# Parse command line arguments
while [[ "$1" != "" ]]; do
    case $1 in
        -i | --iterations )     shift; ITERATIONS=$1 ;;
        -c | --core )           shift; CORE_PIN=$1 ;;
        -m | --make )           AUTO_MAKE=1 ;;
        -o | --out )            shift; OUT_FILE=$1 ;;
        -h | --help )           usage; exit 0 ;;
        -* )                    echo -e "[!] Error: Unknown option $1\n"; usage; exit 1 ;;
        * )                     
            if [ -z "$KVM_DIR" ]; then 
                KVM_DIR=$1 
            else 
                echo -e "[!] Error: Too many arguments.\n"; usage; exit 1; 
            fi 
            ;;
    esac
    shift
done

# Verify a directory was provided
if [ -z "$KVM_DIR" ]; then
    echo -e "[!] Error: You must specify the path to the kvm-unit-tests directory.\n"
    usage
    exit 1
fi

# 1. Automatically CD into the directory safely
echo "[*] Navigating to $KVM_DIR..."
if ! cd "$KVM_DIR"; then
    echo "[!] Error: Directory '$KVM_DIR' does not exist or permission denied."
    exit 1
fi

# 2. Configure and Make if the flag was passed
if [ $AUTO_MAKE -eq 1 ]; then
    echo "[*] Configuring and Compiling kvm-unit-tests..."
    if ! ./configure; then
        echo "[!] Error: './configure' failed."
        exit 1
    fi
    if ! make; then
        echo "[!] Error: 'make' failed. Please check your C code."
        exit 1
    fi
fi

# The tests to run
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
echo " Iterations: $ITERATIONS | Core Pin: $CORE_PIN"
echo " Output: $OUT_FILE"
echo "========================================"

# Initialize CSV header (overwrites old file)
echo "Test,Iteration,Cycles" > "$OUT_FILE"

# 3. The Execution Loop
for test in "${PMU_TESTS[@]}"; do
    echo -n "---> Benchmarking: $test "
    
    for ((i=1; i<=ITERATIONS; i++)); do
        # Print a dot to show progress
        echo -n "."

        # Run QEMU pinned to a single core, suppress QEMU stderr noise
        OUTPUT=$(taskset -c $CORE_PIN ./x86-run x86/vmexit.flat -cpu host,pmu=on -append "$test" 2>/dev/null)
        
        # EXTRACT DATA:
        # Search for the line that starts EXACTLY with the test name
        # and print the second column (the number)
        CYCLES=$(echo "$OUTPUT" | grep "^$test" | awk '{print $2}')
        
        # Save to CSV
        if [ -n "$CYCLES" ]; then
            echo "$test,$i,$CYCLES" >> "$OUT_FILE"
        else
            echo "$test,$i,ERROR" >> "$OUT_FILE"
        fi
    done
    echo " Done!"
done

echo -e "\n========================================"
echo " Benchmarks Complete. Data saved to $(pwd)/$OUT_FILE"
echo "========================================"