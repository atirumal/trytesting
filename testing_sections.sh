#!/bin/bash

# Output file
OUTPUT_FILE="try_timings.csv"

# Create table header
echo "Execution number | Script start | Sandbox setup start | Sandbox setup end | Sandbox validation start | Sandbox validation end | Directory and mount preparation start | Directory and mount preparation end | Overlay mount operations start | Overlay mount operations end | Prepare scripts for mounting and execution end | Unshare and execute sandbox start | Unshare and execute sandbox end | Cleanup start | Cleanup end | Script end" > "$OUTPUT_FILE"

# Perform 100 executions
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

    # Initialize an array to store the times for this execution
    EXECUTION_TIMES=()

    # Read the timing log file and extract times for each step
    if [[ -f "$HOME/try_timing.txt" ]]; then
        # Process each line in the timing log
        while IFS= read -r line; do
            # Extract the step time and calculate the time difference
            CURRENT_TIME=$(date +%s%N)  # Current timestamp in nanoseconds
            OFFSET_TIME=$((CURRENT_TIME - START_TIME))  # Time difference from start time

            STEP=$(echo "$line" | awk -F ' - ' '{print $2}')  # Extract the step name

            # Convert the offset to seconds (and format to 3 decimal places)
            OFFSET_TIME_SEC=$(echo "scale=3; $OFFSET_TIME / 1000000000" | bc)

            # Append the time for this step to the array
            EXECUTION_TIMES+=("$OFFSET_TIME_SEC")
        done < "$HOME/try_timing.txt"
    else
        echo "Timing log not found for execution $i!"
    fi

    # Format the times into a string with "|" separator for table format
    EXECUTION_LINE="$i | ${EXECUTION_TIMES[*]}"

    # Append the times for this execution to the table file
    echo "$EXECUTION_LINE" >> "$OUTPUT_FILE"
done

echo "Timings recorded in $OUTPUT_FILE."

