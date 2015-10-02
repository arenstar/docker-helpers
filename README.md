docker-helpers
=========

A suite of shortcut tools to help use and manage docker in continuos integration

## Configuration

Environment variables, notably:

Variable | Description
--- | ---
REGISTRY_URL | The docker registry URL/USER/IMAGE endpoint to use (e.g 127.0.0.1:5000/username/test )
TAG | The docker tag to use ( e.g 1.1.2 or develop )
CONTAINER_NAME | The docker container name to create from an image ( e.g test )

## Examples

##########################
REGISTRY_URL="127.0.0.1:5000/username/test"
TAG${GIT_BRANCH##origin/}
CONTAINER_NAME=test
##########################

upload_pypi

docker build -t ${CONTAINER_NAME} .
docker tag -f ${CONTAINER_NAME} ${REGISTRY_URL}:${TAG}
docker push ${REGISTRY_URL}:${TAG}

update_container 

clean_containers

clean_images
