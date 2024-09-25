#!/usr/bin/env bash

# Define log file path
LOG_FILE="$HOME/.kik/logs/kik.log"
LOG_TO_FILE=true

# Function to log to file
log_to_file() {
    if [ "$LOG_TO_FILE" = true ]; then
        echo -e "$1" >> "$LOG_FILE"
    fi
}

# Function to log debug information
log_debug() {
    local message="$1"
    local name="$2"

    # Base debug message
    local log_message="$message"
    local gum_log_message

    # Conditionally append name if it's not empty
    if [[ -n "$name" ]]; then
        log_message="$log_message name=\"$name\""
    fi

    # Log the debug message
    gum_log_message=$(gum log --structured --time="kitchen" --level="debug" "$log_message")
    log_to_file "$gum_log_message"  # Log to file
}

# Function to log error information
log_error() {
    local message="$1"
    local name="$2"

    # Base log message
    local log_message="$message"

    # Conditionally append name if it's not empty
    if [[ -n "$name" ]]; then
        log_message="$log_message name=\"$name\""
    fi

    # Log the error message
    gum log --structured --time="kitchen" --level="error" "$log_message"
}
