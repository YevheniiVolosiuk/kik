#!/usr/bin/env bash

# colors.sh - Color definitions for use with gum in kik tool

# Main colors
readonly _COLOR_PRIMARY="212"    # A vibrant blue
readonly _COLOR_SECONDARY="141"  # A soft green
readonly _COLOR_ACCENT="204"     # A bright pink

# Semantic colors
readonly _COLOR_SUCCESS="82"     # A bright green
readonly _COLOR_WARNING="220"    # A golden yellow
readonly _COLOR_ERROR="160"      # A bold red
readonly _COLOR_INFO="39"        # A light blue

# Text colors
readonly _COLOR_TEXT_NORMAL="252"  # Almost white
readonly _COLOR_TEXT_DIM="244"     # A softer gray for less emphasis

# Specialized colors
readonly _COLOR_HELP="226"       # A bright yellow for help text
readonly _COLOR_QUOTE="104"      # A light purple for quotations or highlights
readonly _COLOR_LINK="27"        # A blue shade for links or references

#readonly RESET_COLOR="\033[0m" # No Color

# Function to print all color uses in kik
print_color_palette() {
    echo "Color Samples:"
    for color in $(compgen -A variable | grep "^_COLOR_"); do
        eval "gum style --foreground \${$color} \"$color: This is a sample text\""
    done
}
