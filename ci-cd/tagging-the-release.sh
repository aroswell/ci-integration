#!/bin/bash
# setting exit on error
set -e

VERSION=$(< ./gitrise.sh grep -o "VERSION='[0-9]\{1,\}.[0-9]\{1,\}.[0-9]\{1,\}.*'" \
| grep -o "[0-9]\{1,\}.[0-9]\{1,\}.[0-9]\{1,\}.*[^']")

# logging
echo "Verifying parsed version identifier was $VERSION"

# turning off exit on error
set +e

if git tag "$VERSION"; then 
  echo ":> Build was tagged"
  echo ":> List of tags is: $(git tag -l)"
else 
  echo ":> For some reason - git tag $VERSION failed."
fi
