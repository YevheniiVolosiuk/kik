#!/usr/bin/env bash

# Function to log debug information
log_debug() {
    local message="$1"
    local name="$2"

    # Base log message
    local log_message="$message"

    # Conditionally append name if it's not empty
    if [[ -n "$name" ]]; then
        log_message="$log_message name=\"$name\""
    fi

    # Log the error message
    gum log --structured --level debug "$log_message"
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
    gum log --structured --level error "$log_message"
}
