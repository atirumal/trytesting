#!/bin/bash

# Output CSV file
OUTPUT_CSV="try_timings.csv"

# Create CSV header
echo "Execution,Step,Time (Seconds)" > "$OUTPUT_CSV"

# Perform 2 executions
for i in {1..2}; do
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

    # Read the timing log file and append to CSV
    if [[ -f "$HOME/try_timing.txt" ]]; then
        # Process each line in the timing log
        while IFS= read -r line; do
            # Extract the step time and calculate the time difference
            CURRENT_TIME=$(date +%s%N)  # Current timestamp in nanoseconds
            OFFSET_TIME=$((CURRENT_TIME - START_TIME))  # Time difference from start time

            STEP=$(echo "$line" | awk -F ' - ' '{print $2}')  # Extract the step name

            # Convert the offset to seconds (and format to 3 decimal places)
            OFFSET_TIME_SEC=$(echo "scale=3; $OFFSET_TIME / 1000000000" | bc)

            # Append to CSV (escape commas if present in STEP)
            echo "$i,\"$STEP\",$OFFSET_TIME_SEC" >> "$OUTPUT_CSV"
        done < "$HOME/try_timing.txt"
    else
        echo "Timing log not found for execution $i!"
    fi
done

echo "Timings recorded in $OUTPUT_CSV."
