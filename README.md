# docker-images

Here we include some Dockerfiles, each in a subdirectory, for example, `arima`.

The GitHub workflow will build the Docker images when a pull request made and push the images in GitHub container registry:

https://github.com/orgs/sanger-tol/packages

### GITHUB_TOKEN
1. GITHUB_TOKEN recommanded to be used in GitHub actions, it is a temp one only exists when the pipeline run.
2. You can create a personal access token and add as a secret of your repository, but it is a perment one.
3. Make sure GITHUB_TOKEN have the write permission to the package and contents.
4. You can change the permssion either in UI or in the workflow ymal file.
### Docker image visibility
By default, the docker image is private. You can change it in the Package settings
