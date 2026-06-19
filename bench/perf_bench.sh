#!/bin/bash

MODE=$1
CSV_FILE=$2
LOOPS=1000
ITERATIONS=10

if [ -z "$MODE" ] || [ -z "$CSV_FILE" ]; then
    echo "Usage: $0 [baseline|perf] [output_filename.csv]"
    echo "Example: $0 baseline baseline_results.csv"
    exit 1
fi

echo "Iteration,Time_sec" > "$CSV_FILE"
echo "Starting $ITERATIONS runs of $MODE mode (Saving to $CSV_FILE)..."

for i in $(seq 1 $ITERATIONS); do
    echo -n "  Iteration $i/$ITERATIONS... "
    
    if [ "$MODE" = "baseline" ]; then
        # Run without PMU monitoring
        OUTPUT=$(./perf bench sched messaging -l $LOOPS 2>&1)
    elif [ "$MODE" = "perf" ]; then
        # Run with PMU monitoring
        OUTPUT=$(./perf stat -e instructions,cycles ./perf bench sched messaging -l $LOOPS 2>&1)
    else
        echo "ERROR: Invalid mode. Use 'baseline' or 'perf'."
        exit 1
    fi

    # Extract the number next to "Total time:"
    TIME_VAL=$(echo "$OUTPUT" | grep "Total time:" | awk '{print $3}')
    
    # Save to CSV
    echo "$i,$TIME_VAL" >> "$CSV_FILE"
    echo "${TIME_VAL} sec"
done

echo "Done! Results saved to $CSV_FILE"