#!/bin/bash


echo_build_status_message() {
  local __build_status=$1
  case $__build_status in
    0 ) printf "Build TIMED OUT base on mobile trigger internal setting" ;;
    1 ) printf "Build finished, with success" ;;
    2 ) printf "Build finished, with error" ;;
    3 ) printf "Build was aborted" ;;
    * ) printf "Build status did not match any of the values 0, 1, 2 or 3. This is very strange!" ;;
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