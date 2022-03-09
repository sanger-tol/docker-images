#!/usr/bin/env bash

set -e

function usage() {
   cat <<EOT
Usage: $0 <application>
       application        is the name of the directory containing your
                          Dockerfile. The name of the top level of your tree
                          will be used as image name.
EOT
}

working_dir=$(dirname $0)

application=$1
if [[ "" == "${application}" ]]; then
   echo "Please provide the application directory name!"
   usage
   exit 1
fi
shift

if [[ ! -d "$working_dir/$application" ]]; then
    echo "$application directory does not exist!"
    usage
    exit 1
fi

if [[ -f "$working_dir/$application/docker_build_parameters" ]]; then
  source "$working_dir/$application/docker_build_parameters"
fi

# This script is only supposed to be used in GitLab CI/CD environment
# DOCKER_USER and DOCKER+TOKEN being pre-set there for gitlab
# set to quay only in this condition
if [ ${docker_registry} == "quay" ]; then
  export DOCKER_USER=${QUAY_DOCKER_USER};
  export DOCKER_TOKEN=${QUAY_DOCKER_TOKEN};
fi
