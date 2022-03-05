# docker-images

Registry of docker containers and dockerfiles for any software that isn't available as a container publicly.

Any docker images you don't want to publish publicly:
https://gitlab-registry.internal.sanger.ac.uk/tol-it/software/docker-images  
Otherwise:
https://quay.io/organization/tol

For test docker images: https://gitlab-registry.internal.sanger.ac.uk/tol-it/software/docker-images-test

## Structure
Each application has a dedicated directory contaning a Dockerfile and anything else required to build the image.

To avoid you pass the docker build parameters from command line, you can create a file called ```docker_build_parameters```

When building the image, the argument TAG will be defined with the application version number required.  So the ```Dockerfile``` should contain ARG TAG and can rely on the value of $TAG to be populated with the version number.

The Dockerfile is versioned separartely from the application version number, in case the container needs to be changed independently from the application version; recommend you start at 1 and increment each time the Dockerfile is changed _without_ a change of application version.

Docker tags are based on the application version, with the container version as a suffix; e.g. the first version of a container for an an application v3.2 would be tagged `3.2-c1`.

## Prerequisite
The following environment variables need to be set to use the scripts below:
* DOCKER_USER this would be the GitLab or Quay login, ie your login
* DOCKER_TOKEN this would be access token with the right permission

## Docker image building for tests
The script ```test.sh``` will
* build the docker image
* push the image to our test remote gitlab docker registry
Usage:
```
./test.sh <application> [--app_version <app version>] [--container <container version>]
```
Example:
```
./test.sh arima
./test.sh arima --app_version 0.001
```
This will push the docker image `arima:0.001`.

Adding `--container 2` would add a container version suffix to the tag,
and push `arima:0.001-c2`.

## Docker image building for production
The script ```build.sh``` will
* build the docker image
* push the image to our remote gitlab or quay docker registry
* tag the git repo (so we could rebuild the image should we lose the registry)
* push the git tag to the remote git repository

*Important:* because this creates a git tag, make sure your merge request(s)
are completed before running this script.

Usage:
```
./build.sh <application> [--app_version <app version>] [--container <container version>] [--registry <registry name>]
```
Example:
```
./build.sh arima --app_version 0.001
```
This will push the docker image `arima:0.001`, and push the git tag `arima/0.001`

Adding `--container 2` would add container version suffixes, pushing
the docker image `arima:0.001-c2` and git tag `arima/0.001-c2`

## Passing extra docker build arguments
If `test.sh` or `build.sh` are run with additional arguments (i.e. following the
positional application), other than `--container`, `--app_version`, `--registry`
these additional arguments are passed to the `docker build` command.

Examples:
```
./build.sh arima --app_version 0.001 --no-cache --build-arg "BUILD_PARAM=whatever"
./build.sh arima --app_version 0.001 --container 2 --no-cache --build-arg "BUILD_PARAM=whatever"
./build.sh arima --app_version 0.001 --no-cache --build-arg "BUILD_PARAM=whatever --container 2"
```
These would all add `--no-cache --build-arg "BUILD_PARAM=whatever"` to the docker build command.  This is
useful if you have an arbitrary `ARG` in your Dockerfile that you want to be able to set at build time.
