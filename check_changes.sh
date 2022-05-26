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
echo "All changed files:"
for file in $(git diff --name-only $compare_sha); do
  echo $file
  if [[ $file == *\/* && $file != *\.github\/* ]]
  then
    applications+=(${file%%/*})
  fi

done

sorted_applications=($(printf "%s\n" "${applications[@]}" | sort -u))

echo "All changed applicatons:"
printf "%s\n" "${sorted_applications[@]}"

echo "Building images now:"
for app in "${sorted_applications[@]}"; do
  echo "Building Docker images for $app"
  if [[ $CI_COMMIT_BRANCH == "main" ]]
  then
    echo "production images"
    
    source "${app}/docker_build_parameters"
    # change DOCKER_USER and DOCKER_TOKEN if not gitlab's default ones
    if [ ${docker_registry} == "quay" ]; then
      export DOCKER_USER=${QUAY_DOCKER_USER};
      export DOCKER_TOKEN=${QUAY_DOCKER_TOKEN};
    elif [ ${docker_registry} == "github" ]; then
      export DOCKER_USER=${GITHUB_DOCKER_USER};
      export DOCKER_TOKEN=${GITHUB_DOCKER_TOKEN};
    elif [ ${docker_registry} == "gitlab" ]; then
       export DOCKER_USER=${CI_REGISTRY_USER};
       export DOCKER_TOKEN=${CI_REGISTRY_PASSWORD};
    fi

    ./build.sh $app

  else
    echo "testing images"
    # Dont't use default GITLAB Token for testing images because different repository
    export DOCKER_USER=${GITLAB_DOCKER_USER}
    export DOCKER_TOKEN=${GITLAB_DOCKER_TOKEN}
    ./test.sh $app
  fi
done
