#!/bin/bash

# file path to mocks 
TRIGGER_200_RESPONSE="./mocks/trigger_response_200.json"
BUILD_STATUS_ABORTED="./mocks/build_status_aborted.json"
BUILD_STATUS_FAILED="./mocks/build_status_failed.json"
BUILD_STATUS_SUCCESS="./mocks/build_status_success.json"


# test cases where the trigger response is 200
test_aborted_build() {
  ./app/gitrise.sh -TM --build_status-path $BUILD_STATUS_ABORTED --trigger-response-path $TRIGGER_200_RESPONSE
  assertEquals 1 $?
}

test_failed_build() {
  ./app/gitrise.sh -TM --build_status-path $BUILD_STATUS_FAILED --trigger-response-path $TRIGGER_200_RESPONSE
  assertEquals 1 $?
}

test_success_build() {
  ./app/gitrise.sh -TM --build_status-path $BUILD_STATUS_SUCCESS --trigger-response-path $TRIGGER_200_RESPONSE
  assertEquals 0 $?
}


# In progress test will not return but run in a loop
# BUILD_STATUS_IN_PROGRESS="./mocks/build_status_in_progress.json"
# test_in_progress_build() {
#   echo $(./gitrise.sh -TM --build_status-path $BUILD_STATUS_IN_PROGRESS --trigger-response-path $TRIGGER_200_RESPONSE)
#   echo
# }

# Load and run shUnit2.
. ./tests/shunit2