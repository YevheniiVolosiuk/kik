#!/usr/bin/env bash

# gum.sh - Utility functions for using gum in kik tool

# Check if gum is available
if command -v gum &> /dev/null; then
    USE_GUM=true
else
    USE_GUM=false
    echo "Gum not found. Using standard output." >&2
fi

# Function to print styled output
gum_style() {
    local color="$1"
    shift
    if [ "$USE_GUM" = true ]; then
        gum style --foreground "$color" "$@"
    else
        echo "$@"
    fi
}

# Function to display messages using gum
gum_message() {
  local type="$1"
  local message="$2"
  local color="$3"
  case $type in
    success) gum style --foreground "$color" --align left "✅ $message" ;;
    error) gum style --foreground "$color" --align left "❌ $message" ;;
    info) gum style --foreground "$color" --align left "ℹ️ $message" ;;
    *) gum style --align left "$message" ;;
  esac
}

# Function for user confirmation
gum_confirm() {
    if [ "$USE_GUM" = true ]; then
        gum confirm "$1"
    else
        read -p "$1 (y/n): " -n 1 -r
        echo
        [[ $REPLY =~ ^[Yy]$ ]]
    fi
}

# Function to choose from a list of options
gum_choose() {
    if [ "$USE_GUM" = true ]; then
        gum choose "$@"
    else
        select opt in "$@"; do
            echo "$opt"
            break
        done
    fi
}

# Function for user input
gum_input() {
    local prompt="$1"
    shift
    if [ "$USE_GUM" = true ]; then
        gum input --prompt "$prompt" "$@"
    else
        read -p -r "$prompt: " input
        echo "$input"
    fi
}

# Function for password input
gum_password() {
    local prompt="$1"
    shift
    if [ "$USE_GUM" = true ]; then
        gum input --password --prompt "$prompt" "$@"
    else
        read -s -p -r "$prompt: " password
        echo >&2
        echo "$password"
    fi
}

# Function to display a spinner
gum_spin() {
    local message="$1"
    shift
    if [ "$USE_GUM" = true ]; then
        gum spin --spinner dot --title "$message" -- "$@"
    else
        echo "$message"
        "$@"
    fi
}

# Function to format text
gum_format() {
    if [ "$USE_GUM" = true ]; then
        gum format "$@"
    else
        cat
    fi
}

# Function to join lines with a character
gum_join() {
    local character="$1"
    if [ "$USE_GUM" = true ]; then
        gum join --character "$character"
    else
        paste -sd "$character" -
    fi
}

# Function to display a progress bar
gum_progress() {
    if [ "$USE_GUM" = true ]; then
        gum progress "$@"
    else
        cat > /dev/null
        echo "Progress: 100%"
    fi
}
