#!/bin/bash
# setting exit on error
set -e

VERSION=$(< ./gitrise.sh grep -o "VERSION='[0-9]\{1,\}.[0-9]\{1,\}.[0-9]\{1,\}.*'" \
| grep -o "[0-9]\{1,\}.[0-9]\{1,\}.[0-9]\{1,\}.*[^']")

# logging
git tag -l
echo "Parsed version was $VERSION"

# turning off exit on error
set +e

if ! git tag "$VERSION"
then 
  echo ":> Build was tagged."
else 
  echo ":> Build was previously tagged."
fi
