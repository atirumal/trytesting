#!/bin/bash

OUTPUT="try_overhead_results.txt"
echo "Overhead Measurement Results" > $OUTPUT
echo "===========================" >> $OUTPUT

# Function to calculate average time
calculate_average() {
    TIMES=($1)
    TOTAL=0
    COUNT=${#TIMES[@]}

    for TIME in "${TIMES[@]}"; do
        TOTAL=$(echo "$TOTAL + $TIME" | bc)
    done

    AVERAGE=$(echo "scale=3; $TOTAL / $COUNT" | bc -l)
    echo "$AVERAGE"
}

# Measure execution time
measure_time() {
    COMMAND=$1
    LABEL=$2

    WITHOUT_TRY_TIMES=()
    WITH_TRY_TIMES=()

    for i in {1..100}; do
        # Measure without try
        START=$(date +%s.%N)
        eval "$COMMAND"
        END=$(date +%s.%N)
        WITHOUT_TRY_TIMES+=( $(echo "scale=3; $END - $START" | bc) )

        # Measure with try
        START=$(date +%s.%N)
        try -y $COMMAND
        END=$(date +%s.%N)
        WITH_TRY_TIMES+=( $(echo "scale=3; $END - $START" | bc) )
    done

    # Calculate averages
    WITHOUT_TRY_AVG=$(calculate_average "${WITHOUT_TRY_TIMES[@]}")
    WITH_TRY_AVG=$(calculate_average "${WITH_TRY_TIMES[@]}")

    # Write only averages to log
    echo "$LABEL: Without try: $WITHOUT_TRY_AVG seconds, With try: $WITH_TRY_AVG seconds" >> $OUTPUT

    # Clean up temporary files created by try
    TEMP_FILES=$(ls /tmp/tmp.*.try* 2>/dev/null)
    if [ -n "$TEMP_FILES" ]; then
        rm -f $TEMP_FILES
    fi
}

# Tests
measure_time "echo 'hello world'" "Simple echo"
measure_time "dd if=/dev/zero of=bigfile bs=1M count=100" "Create 100MB file"
measure_time "rm bigfile" "Remove big file"
measure_time "touch {1..1000}.txt" "Create 1000 small files"
measure_time "ls *.txt > /dev/null" "List 1000 small files"
measure_time "rm {1..1000}.txt" "Remove 1000 small files"
measure_time "dd if=/dev/zero of=modifyfile bs=1M count=100 && sed -i 's/0/1/g' modifyfile" "Modify a large file"
measure_time "cat /dev/urandom | head -c 1M > randomfile && wc -c randomfile" "Process a random file"

# Clean up temporary files
rm -f bigfile modifyfile randomfile {1..1000}.txt

TEMP_FILES=$(ls /tmp/tmp.*.try* 2>/dev/null)
if [ -n "$TEMP_FILES" ]; then
    rm -f $TEMP_FILES
fi

echo "Measurement completed. Results saved to $OUTPUT."
