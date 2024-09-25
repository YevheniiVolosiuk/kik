#!/usr/bin/env bash

# colors.sh - Color definitions for use with gum in kik tool

# Main colors
readonly COLOR_PRIMARY="212"    # A vibrant blue
readonly COLOR_SECONDARY="141"  # A soft green
readonly COLOR_ACCENT="204"     # A bright pink

# Semantic colors
readonly COLOR_SUCCESS="82"     # A bright green
readonly COLOR_WARNING="220"    # A golden yellow
readonly COLOR_ERROR="160"      # A bold red
readonly COLOR_INFO="39"        # A light blue

# Text colors
readonly COLOR_TEXT_NORMAL="252"  # Almost white
readonly COLOR_TEXT_DIM="244"     # A softer gray for less emphasis

# Specialized colors
readonly COLOR_HELP="226"       # A bright yellow for help text
readonly COLOR_QUOTE="104"      # A light purple for quotations or highlights
readonly COLOR_LINK="27"        # A blue shade for links or references

#readonly RESET_COLOR="\033[0m" # No Color

# Function to print all color uses in kik
print_color_palette() {
    echo "Color Samples:"
    for color in $(compgen -A variable | grep "^COLOR_"); do
        eval "gum style --foreground \${$color} \"$color: This is a sample text\""
    done
}
