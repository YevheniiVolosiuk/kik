setup() {
    load './../test_helper/bats-support/load'
    load './../test_helper/bats-assert/load'
    # ... the remaining setup is unchanged

    load './../../core/utility/array.sh'

    # get the containing directory of this file
    # use $BATS_TEST_FILENAME instead of ${BASH_SOURCE[0]} or $0,
    # as those will point to the bats executable's location or the preprocessed file respectively
    DIR="$( cd "$( dirname "$BATS_TEST_FILENAME" )" >/dev/null 2>&1 && pwd )"
    # make executables in src/ visible to PATH
    PATH="$DIR/../../kik-framework:$PATH"
}

teardown () {
      # Reset associative array before each test
    unset array_basket
    declare -A array_basket
}

# Test: Successfully create an array with elements
@test "create array with elements" {
    run array_create "myArray" "element1" "element2" "element3"
    assert_success
    [ "${array_basket["myArray"]}" = "element1 element2 element3 " ]
}

# Test: Fail to create an array when no array name is provided
@test "fail to create array with no name" {
    run array_create "" "element1" "element2"
    [ "$status" -eq 1 ]
    [ -z "${array_basket[""]}" ]  # Ensure no array was created
}

# Test: Create an array with a single element
@test "create array with single element" {
    run array_create "singleElementArray" "onlyElement"
    [ "$status" -eq 0 ]
    [ "${array_basket["singleElementArray"]}" = "onlyElement " ]
}

# Test: Create an array with multiple elements including empty elements
@test "create array with empty elements" {
    run array_create "mixedArray" "first" "" "third"
    [ "$status" -eq 0 ]
    [ "${array_basket["mixedArray"]}" = "first  third " ]
}

# Test: Handle case where array creation fails due to missing parameters
@test "create array with missing parameters" {
    run array_create "incompleteArray"
    [ "$status" -eq 0 ]
    [ "${array_basket["incompleteArray"]}" = " " ]  # Should still create an array with no elements
}

# Test: Ensure that subsequent creations do not affect previous arrays
@test "create multiple arrays" {
    run array_create "firstArray" "a" "b" "c"
    [ "$status" -eq 0 ]
    [ "${array_basket["firstArray"]}" = "a b c " ]

    run array_create "secondArray" "x" "y"
    [ "$status" -eq 0 ]
    [ "${array_basket["secondArray"]}" = "x y " ]

    [ "${array_basket["firstArray"]}" = "a b c " ]
    [ "${array_basket["secondArray"]}" = "x y " ]
}
