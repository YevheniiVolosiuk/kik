#!/usr/bin/env bash

# arrays.sh - A utility library for array manipulation in Bash
# Author: Yevhenii Volosiuk
# Created: 2024
# Description: This script provides a set of modular functions for array manipulation in Bash.
# All functions follow best practices for readability, reusability, and maintainability.

# Usage:
# 1. Source this script in your Bash script: `source arrays.sh`
# 2. Use the functions provided in this utility for array manipulation.

set -euo pipefail

# ==============================================================================
# Function: array_create
# Description: Initializes a new array and stores it in an associative array.
#
# Parameters:
#   1. array_name (string) - The name of the array to create.
#   2. elements (optional) - Space-separated list of elements to initialize the array with.
#
# Usage:
#   array:create myArray "element1" "element2" "element3"
#   # After calling array:create, you can access the array's contents with:
#   echo "Contents of myArray: $(array:get myArray)"
#
# Example:
#   array:create fruits "apple" "banana" "cherry"
#   # Output: Array 'fruits' created with elements: apple banana cherry
#   echo "Contents of fruits: $(array:get fruits)"
#   # Output: apple banana cherry
#
# ==============================================================================

# Initialize the associative array to map array names to actual arrays
declare -A array_basket


# Function to create an array and store it in array_basket
array_create() {
    local array_name="$1"  # The name of the array to create
    shift                  # Shift the positional parameters to get the elements
    local elements=("$@")  # Remaining parameters are the elements of the array

    if [[ -z "$array_name" ]]; then
        echo "Error: No array name provided."
        return 1
    fi

    # Store the elements in the associative array
    array_basket["$array_name"]=$(printf "%s " "${elements[@]}")
        echo "Debug: array_basket['$array_name'] = '${array_basket["$array_name"]}'"  # Debug output
    return 0
}



# ==============================================================================
# Function: array:get
# Description: Retrieve the elements of an array by its name.
#
# Parameters:
#   1. array_name (string) - The name of the array whose elements you want to retrieve.
#
# Returns:
#   string - The elements of the specified array, space-separated.
#
# Errors:
#   Returns 1 if no array name is provided or if the array does not exist.
#
# Example:
#   array:get myArray
#   Output: element1 element2 element3
#
# ==============================================================================

array_get() {
    local array_name="$1"  # The name of the array to retrieve

    # Check if the array name is provided
    if [[ -z "$array_name" ]]; then
        echo "Error: No array name provided."
        return 1
    fi

    # Check if the array exists in the associative array
    if [[ -z "${array_basket["$array_name"]+x}" ]]; then
        echo "Error: Array '$array_name' does not exist."
        return 1
    fi

    # Output the elements of the array
    echo "${array_basket["$array_name"]}"
    return 0
}



# ==============================================================================
# Function: array_get_element
# Description: Retrieve a specific element from an array by its index. If no index is provided,
#              the function returns the first element of the array by default.
#
# Parameters:
#   1. array_name (string) - The name of the array from which to retrieve an element.
#   2. index (integer) (default: 0) - The zero-based index of the element to retrieve. Defaults to 0 if not provided.
#
# Returns:
#   string - The element at the specified index of the array.
#
# Errors:
#   Returns 1 if:
#     - No array name is provided.
#     - The specified array does not exist.
#     - The index is out of bounds (i.e., not a valid position in the array).
#
# Example:
#   # Create an array named 'myArray' with elements
#   array_create "myArray" "element1" "element2" "element3"
#
#   # Retrieve and print the second element of 'myArray'
#   array_get_element "myArray" 1
#   # Output: element2
# ==============================================================================

array_get_element() {
    local array_name="$1"
    local index=${2:-0}

    if [[ -z "$array_name" || -z "$index" ]]; then
        echo "Error: Array name or index not provided."
        return 1
    fi

    # Extract the array elements as a list
    local array_elements=(${array_basket["$array_name"]})

    # Validate index
    if [[ $index -ge ${#array_elements[@]} || $index -lt 0 ]]; then
        echo "Error: Index '$index' out of bounds."
        return 1
    fi

    # Output the specific element
    echo "${array_elements[$index]}"
    return 0
}

#array_create animals "dog" "bona" "mona"
#
#echo "Contents of animals: $(array_get animals)"
#echo "Contents of animals: $(array_get_element animals 2)"
