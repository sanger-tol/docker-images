#!/usr/bin/env bash

set -e

compare_sha=""
if [[ $CI_PIPELINE_SOURCE == "push" ]]
then
   compare_sha="$CI_COMMIT_BEFORE_SHA $CI_COMMIT_SHA"
elif [[ $CI_PIPELINE_SOURCE == "merge_request_event" ]]
then
   compare_sha="$CI_MERGE_REQUEST_DIFF_BASE_SHA...HEAD"
else
   echo "Doing nothing this time"
   exit 0
fi

applications=()
for file in $(git diff --name-only $compare_sha); do
  echo $file
  if [[ $file == *\/* && $file != *\.github\/* ]]
  then
    applications+=(${file%%/*})
  fi

done
sorted_applications=($(printf "%s\n" "${applications[@]}" | sort -u))
printf "%s\n" "${sorted_applications[@]}"

for app in "${sorted_applications[@]}"; do
  echo "Building Docker images for $app"
  if [[ $CI_COMMIT_BRANCH == "main" ]]
  then
    echo "Building production images"
    ./build.sh $app
  else
    echo "Building testing images"
    ./test.sh $app
  fi
done
