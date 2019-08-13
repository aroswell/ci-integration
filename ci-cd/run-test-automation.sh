#!/bin/bash

# This script provides a way to run linting and test automation
# in a docker container. It particularly pertains to 
# developers working on non-Unix platforms locally. 
# Your continuous integration can be implemented using Docker
# in your pipeline.

# Exit immediately if any command returns with a non-zero status after it runs
set -e

# build image 
printf "Build Image:\n"
docker build -t gitrise-test-automation .

# run container and execute test automation
printf "Run test automation inside container:\n"
docker run -i --rm gitrise-test-automation /bin/bash << COMMANDS
set -e
echo 'Linting with shellcheck'
shellcheck gitrise.sh
COMMANDS
printf "\nTest run script ran with errors in the script execution\n"