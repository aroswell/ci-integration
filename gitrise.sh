#!/bin/bash
# setting exit on error
set -e

# global variables
VERSION='0.0.1'
APP_NAME='Gitrise CI'

# file path to mocks 
TRIGGER_200_RESPONSE="./mocks/trigger_response_200.json"
BUILD_STATUS_ABORTED="./mocks/build_status_aborted.json"

# function definitions

echo_build_status_message() {
  local __build_status=$1
  case $__build_status in
    0 ) printf "Build TIMED OUT base on mobile trigger internal setting" ;;
    1 ) printf "Build finished, with success" ;;
    2 ) printf "Build finished, with error" ;;
    3 ) printf "Build was aborted" ;;
    * ) printf "Build status did not match any of the values 0, 1, 2 or 3.\nThis is very strange!" ;;
  esac
}

print_usage() {
    echo 
    echo "Usage: gitrise [options]"
    echo 
    echo "[options]"
    echo "  -w, --workflow      <string>    Bitrise Workflow"
    echo "  -b, --branch        <string>    Git Branch"
    echo "  -a, --access-token  <string>    Bitrise access token"
    echo "  -s, --slug          <string>    Bitrise project slug"
    echo "  -h, --help          <string>    Print this help text"
}


# e.g. of use
# ./gitrise.sh \ 
#         -w unittest_and_code_coverage \ 
#         -b "$CI_COMMIT_REF_NAME" \
#         -e TARGET_BRANCH_NAME="$CI_MERGE_REQUEST_TARGET_BRANCH_NAME",ENABLE_CODE_COVERAGE=false \ 
#         --config $CONFIG_FILE_PATH 

# parsing space separated options
POSITIONAL=()
while [[ $# -gt 0 ]]
do
key="$1"

case $key in
  -V|--version)
  VERSION=true
  shift
  ;;

  -TM|--testing-mode)
  TESTING_MODE=true
  shift
  ;;

  -w|--workflow-id)
  WORKFLOW_ID="$2"
  shift
  shift
  ;;

  -b|--branch)
  BRANCH_NAME="$2"
  shift
  shift
  ;;

  -c|--config)
  CONFIG_PATH="$2" # give absolute path
  shift
  shift
  ;;

  -h|--help)
  print_usage
  exit 0
  ;;

  *) # for unknown option
  POSITIONAL+=("$1")
  shift
  ;;
esac
done

# restore positional parameters
set -- "${POSITIONAL[@]}" 

if [ $TESTING_MODE ]; then
  printf "Running in TESTING MODE\n"
else
  # reading and parsing config file if app is not in test mode
  CONFIG_FILE_CONTENTS=$(<"$CONFIG_PATH")
  ACCESS_TOKEN=$(echo "$CONFIG_FILE_CONTENTS" | jq '.theAccessToken' | tr -d '"')
  SLUG=$(echo "$CONFIG_FILE_CONTENTS" | jq '.slug' | tr -d '"')
  PROJECT_NAME=$(echo "$CONFIG_FILE_CONTENTS" | jq '.projectName' | tr -d '"')
fi

# printing app info and project name
printf "\nAPP INFO - %s: %s" "$APP_NAME" "$VERSION"
printf "\nProject: %s" "$PROJECT_NAME"


# call to trigger bitrise
trigger_command="curl --silent -X POST https://api.bitrise.io/v0.1/apps/$SLUG/builds \
        --data '{\"hook_info\":{\"type\":\"bitrise\"},\"build_params\":{\"branch\":\"$BRANCH_NAME\",\"workflow_id\":\"$WORKFLOW_ID\"}}' \
        --header 'Authorization: $ACCESS_TOKEN'"

if [ $TESTING_MODE ]; then
  result=$(<"$TRIGGER_200_RESPONSE")
else
  result=$(eval "$trigger_command")
fi

build_url=$(echo "$result" | jq '.build_url' | sed 's/"//g')
build_slug=$(echo "$result" | jq '.build_slug')

echo
echo "For direct access to the Bitrise platform follow the link below."
echo "Build URL: $build_url"
echo 
echo ":> Waiting on build..."


# polling loop for build status
build_status=0
while [ $build_status -eq 0 ]; do
  if [ $TESTING_MODE ]; then 
    status_call_result=$(<$BUILD_STATUS_ABORTED)
  else
    sleep 10
    build_status_command="curl --silent -X GET https://api.bitrise.io/v0.1/apps/$SLUG/builds/$build_slug \
              --header 'Authorization: $ACCESS_TOKEN'"
    status_call_result=$(eval "$build_status_command")
  fi
  build_status=$(echo "$status_call_result" | jq '.data' | jq '.status')
done 

if [[ $build_status -eq 1 ]]; then
  exit_code=0
else
  exit_code=1
fi


echo_build_status_message "$build_status"
echo
echo "exit code is $exit_code"
