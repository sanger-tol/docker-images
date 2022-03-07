#!/usr/bin/env bash

set -e

function usage() {
   cat <<EOT
Usage: $0 <application> [--app_version <application version>]  [--container <container version>] [--registry <registry name>] [<extra build args>]
       application        is the name of the directory containing your
                          Dockerfile. The name of the top level of your tree
                          will be used as image name.
       appliction version will be passed as argument TAG to the docker build,
                          and will be the basis for your docker image tag.
                          Optional, the value from file 'docker_build_parameters' will be used.
       container version  will be added as a suffix to your docker image tag
                          to allow container versioning, i.e. if you change the
                          Dockerfile without changing the application version.
                          Optional, the value from file 'docker_build_parameters' will be used.
       registry name      Docker registry name, gitlab or quay.
                          Optional, the value from file 'docker_build_parameters' will be used.
       extra build args   Optional, any extra arguments will be passed to the
                          docker build (e.g. '--build-arg "FOO=BAR"').
                          If working on a shared machine do not pass tokens,
                          passwords etc. like this!
EOT
}
GITLAB_GIT_URL="gitlab.internal.sanger.ac.uk/tol-it/software/docker-images.git"

GITLAB_REGISTRY_SERVER="gitlab-registry.internal.sanger.ac.uk"
GITLAB_REGISTRY_URL="gitlab-registry.internal.sanger.ac.uk/tol-it/software/docker-images"

QUAY_REGISTRY_SERVER="quay.io"
QUAY_REGISTRY_URL="quay.io/tol"

# get name used to invoke script
invoked_name=$(echo $0 | sed 's~.*/~~')
if [[ $invoked_name =~ ^build ]]; then
   building_not_testing=true
fi

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

cd $working_dir/$application
if [[ -f "docker_build_parameters" ]]; then
  source "docker_build_parameters"
fi

# remaining arguments are either --container followed by a container version
# OR --app_version followed by an application
# OR --registry followed by docker registry
# OR extra docker build args that should be saved to build_args
while [[ $# -gt 0 ]]; do
   if [[ $1 =~ ^\-\-container ]]; then
      shift
      container_version=$1
   elif [[ $1 =~ ^\-\-app_version ]]; then
      shift
      app_version=$1
   elif [[ $1 =~ ^\-\-registry ]]; then
       shift
       docker_registry=$1
   else
      extra_build_args="${extra_build_args:+${extra_build_args} }$1"
   fi
   shift
   if [[ "" == "$1" ]]; then break; fi
done

if [[ "" == "${app_version}" ]]; then
   echo "Please provide an app version!"
   usage
   exit 1
fi

echo "The following values being given:"
echo "building_not_testing=$building_not_testing"
echo "application=$application"
echo "app_version=$app_version"
echo "container_version=$container_version"
echo "docker_registry=$docker_registry"
echo "extra_build_args=$extra_build_args"

if [ -z ${DOCKER_USER+x} ]
then
  echo Please set your docker registry login into variable DOCKER_USER
  exit 1
fi

if [ -z ${DOCKER_TOKEN+x} ]
then
  echo Please set your personal docker registry token into variable DOCKER_TOKEN
  exit 1
fi

if [ -z ${GITLAB_USER+x} ]
then
  echo Please set your gitlab login into variable GITLAB_USER
  exit 1
fi

if [ -z ${GITLAB_TOKEN+x} ]
then
  echo Please set your personal token into variable GITLAB_TOKEN
  exit 1
fi

app_tag=$(echo "$app_version" | sed 's/=/--/g')
ctr_tag=$(echo "$container_version" | sed 's/=/--/g')
git_tag="${application}/${app_tag}"
docker_tag="${application}:${app_tag}"
if [[ "" != "${ctr_tag}" ]]; then
   git_tag="${git_tag}-c${ctr_tag}"
   docker_tag="${docker_tag}-c${ctr_tag}"
fi

docker_registry_server=$GITLAB_REGISTRY_SERVER
docker_registry_url="${GITLAB_REGISTRY_URL}-test"

if [[ ${building_not_testing} ]]; then
  if [[ "gitlab" == "$docker_registry" ]]; then
    docker_registry_server=$GITLAB_REGISTRY_SERVER
    docker_registry_url=$GITLAB_REGISTRY_URL
  elif [[ "quay" == "$docker_registry" ]]; then
    docker_registry_server=$QUAY_REGISTRY_SERVER
    docker_registry_url=$QUAY_REGISTRY_URL
  else
    echo "Given docker regisry $docker_registry NOT allowed!"
    usage
    exit 1
  fi
fi

remote_docker_tag="${docker_registry_url}/${docker_tag}"

echo "Docker building of ${docker_tag}"
docker build -t "${docker_tag}" --build-arg "TAG=${app_version}" ${extra_build_args} .

echo "Docker login"
echo "${DOCKER_TOKEN}" | docker login -u "${DOCKER_USER}" --password-stdin "${docker_registry_server}"

echo "Tagging gitlab docker registry"
docker tag "${docker_tag}" "${remote_docker_tag}"

echo "Pushing docker image to registry"
docker push "${remote_docker_tag}"

if [[ ${building_not_testing} ]]; then
   echo "Tagging the repository with tag ${git_tag}"
   git tag "${git_tag}"
   echo "Pushing the git tag ${git_tag} to origin"
   git push "https://${GITLAB_USER}:${GITLAB_TOKEN}@${GITLAB_GIT_URL}" "${git_tag}"
fi
