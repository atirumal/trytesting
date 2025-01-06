#!/bin/bash

# Output CSV file
OUTPUT_CSV="try_timings.csv"

# Define the column headers
HEADER=("Execution Round" "Script start" "Sandbox setup start" "Sandbox setup end" "Sandbox validation start" "Sandbox validation end" "Directory and mount preparation start" "Directory and mount preparation end" "Overlay mount operations start" "Overlay mount operations end" "Prepare scripts for mounting and execution end" "Unshare and execute sandbox start" "Unshare and execute sandbox end" "Cleanup start" "Cleanup end" "Script end")

# Write the header to the CSV file
echo "$(IFS=,; echo "${HEADER[*]}")" > "$OUTPUT_CSV"

# Perform 2 executions (adjust this for more executions if needed)
for i in {1..100}; do
    echo "Starting execution $i..."

    # Uninstall pyenv (if installed) to ensure try installs it every time
    if command -v pyenv &>/dev/null; then
        echo "Uninstalling pyenv..."
        rm -rf "$HOME/.pyenv"  # Remove pyenv directory
        rm -f "$HOME/.bash_profile"  # Remove any pyenv-related lines from the profile
        rm -f "$HOME/.bashrc"  # Same for bashrc
        source "$HOME/.bash_profile"  # Reload the profile
        source "$HOME/.bashrc"  # Reload bashrc
        echo "pyenv uninstalled."
    fi

    # Record the start time of the execution in nanoseconds (for precision)
    START_TIME=$(date +%s%N)

    # Run the try command (adjust the command as needed)
    ~/trytesting/try -y pip3 install pipenv

    # Initialize an array to store the times for this execution
    EXECUTION_TIMES=()

    # Read the timing log file and extract times for each step
    if [[ -f "$HOME/try_timing.txt" ]]; then
        while IFS= read -r line; do
            # Extract the step time and calculate the time difference
            CURRENT_TIME=$(date +%s%N)  # Current timestamp in nanoseconds
            OFFSET_TIME=$((CURRENT_TIME - START_TIME))  # Time difference from start time

            # Convert the offset to seconds (and format to 3 decimal places)
            OFFSET_TIME_SEC=$(echo "scale=3; $OFFSET_TIME / 1000000000" | bc)

            # Append the time for this step to the array
            EXECUTION_TIMES+=("$OFFSET_TIME_SEC")
        done < "$HOME/try_timing.txt"
    else
        echo "Timing log not found for execution $i!"
    fi

    # Check for mismatched values
    NUM_HEADERS=${#HEADER[@]}
    NUM_TIMES=${#EXECUTION_TIMES[@]}

    if [[ $NUM_TIMES -lt $((NUM_HEADERS - 1)) ]]; then
        echo "Warning: Missing timing values for execution $i. Filling with 'N/A'."
        while [[ ${#EXECUTION_TIMES[@]} -lt $((NUM_HEADERS - 1)) ]]; do
            EXECUTION_TIMES+=("N/A")
        done
    elif [[ $NUM_TIMES -gt $((NUM_HEADERS - 1)) ]]; then
        echo "Warning: Extra timing values for execution $i. Trimming values."
        EXECUTION_TIMES=("${EXECUTION_TIMES[@]:0:$((NUM_HEADERS - 1))}")
    fi

    # Format the execution row as comma-separated values
    EXECUTION_ROW="$i"
    for time in "${EXECUTION_TIMES[@]}"; do
        EXECUTION_ROW="$EXECUTION_ROW,$time"
    done

    # Append the execution row to the CSV file
    echo "$EXECUTION_ROW" >> "$OUTPUT_CSV"
done

echo "Timings recorded in $OUTPUT_CSV."

