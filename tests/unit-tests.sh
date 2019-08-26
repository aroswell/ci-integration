#! /bin/bash

# load all app functions
source ./app/gitrise-functions/actions.sh

# test cases
test_echo_build_status_message_zero() {
  assertEquals "Build TIMED OUT base on mobile trigger internal setting" "$(echo_build_status_message 0)"
}

test_echo_build_status_message_one() {
  assertEquals "Build finished, with success" "$(echo_build_status_message 1)"
}

test_echo_build_status_message_two() {
  assertEquals "Build finished, with error" "$(echo_build_status_message 2)"
}

test_echo_build_status_message_three() {
  assertEquals "Build was aborted" "$(echo_build_status_message 3)"
}

test_echo_build_status_message_anything() {
  assertEquals "Message did not match!" \
  "Build status did not match any of the values 0, 1, 2 or 3. This is very strange!" \
  "$(echo_build_status_message 'something_else')"
}


# Load and run shUnit2.
. ./tests/shunit2
