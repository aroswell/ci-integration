#!/bin/bash
# setting exit on error
set -e

# global variables
# format to assign VERSION should be followed. This script is parsed to obtain the version.
VERSION='0.0.1.beta'
APP_NAME='Gitrise CI'

# sourcing functions
source ./gitrise-functions/actions.sh

# e.g. of possible use where -e would allow for environment variables to be passed to the CI machine
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

  -bs|--build_status-path)
  BUILD_STATUS_PATH="$2"
  shift
  shift
  ;;

  -tr|--trigger-response-path)
  TRIGGER_RESPONSE_PATH="$2"
  shift
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
  result=$(<"$TRIGGER_RESPONSE_PATH")
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
    status_call_result=$(<"$BUILD_STATUS_PATH")
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
exit $exit_code
