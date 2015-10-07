#!/bin/bash

# print syntax
function syntax {
    echo ""
    echo "The following environment variables are required:"
    echo "  \$REGISTRY_URL    - the registry to use [127.0.0.1:5000/user/image]"
    echo "  \$TAG             - the tag used to identify an image [latest]"
    echo "  \$CONTAINER_NAME  - the container name [test]"
    echo ""
}

function upload_pypi {
    echo ">>> Uploading to PyPi"
    python setup.py bdist_wheel upload -r internal
    if [ $? != 0 ]; then
	echo ""
        echo ">>> COMMAND: python setup.py bdist_wheel upload -r internal FAILED"
	echo ""
        exit 1
    fi
    echo ""
}

function clean_containers {
    echo ""
    echo '>>> Cleaning up containers'
    docker ps -a | grep "Exit" | awk '{print $1}' | while read -r id ; do
        echo ">>> COMMAND: docker rm $id"
        docker rm $id
    done
    echo ""
}

function clean_images {
    echo ""
    echo '>>> Cleaning up images'
    docker images | grep "^<none>" | head -n 1 | awk 'BEGIN { FS = "[ \t]+" } { print $3 }'  | while read -r id ; do
        docker rmi $id
    done
    echo ""
}

function get_container_id {
    docker ps | grep ${CONTAINER_NAME} | awk '{print $1}'
}

function get_application_port {

    if [ -z "$CONTAINER_NAME" ] || [ -z "$TAG" ]; then syntax; exit 1; fi

    if [ "$CONTAINER_NAME" = "test" ] ; then
    	if [ "$TAG" = "develop" ] ; then PORT=8090; elif [ "$TAG" = "master" ]; then PORT=8092; else PORT=8094; fi
    fi
    if [ "$CONTAINER_NAME" = "WEB" ] ; then
    	if [ "$TAG" = "develop" ] ; then PORT=8090; elif [ "$TAG" = "master" ]; then PORT=8092; else PORT=8094; fi
    fi
    if [ "$CONTAINER_NAME" = "API" ] ; then
    	if [ "$TAG" = "develop" ] ; then PORT=8091; elif [ "$TAG" = "master" ]; then PORT=8093; else PORT=8095; fi
    fi

}
function update_container {

    if [ -z "$TAG" ] || [ -z "CONTAINER_NAME" ] || [ -z "$REGISTRY_URL" ]; then syntax; exit 1; fi

    echo ""
    CURRENT_IMAGE_ID=`docker images | grep -w ${CONTAINER_NAME} | awk '{ print $3 }'`
    docker pull ${REGISTRY_URL}:${TAG}
    NEW_IMAGE_ID=`docker images | grep -w ${CONTAINER_NAME} | awk '{ print $3 }'`
    echo ""
    if [ "$CURRENT_IMAGE_ID" == "$NEW_IMAGE_ID" ]; then
        echo "Image IDs are equal. Therefore we have no new image."
        echo ""
    else
        echo "Image IDs are not equal. Therefore we should stop old image and start new one."
        echo ""
        echo ">>> COMMAND: docker kill ${CONTAINER_NAME}-${TAG}"
        docker kill ${CONTAINER_NAME}-${TAG}
        echo ""
        echo ">>> COMMAND: docker rm ${CONTAINER_NAME}-${TAG}"
        docker rm ${CONTAINER_NAME}-${TAG}
        echo ""
        get_application_port
        echo ">>> COMMAND: docker run --name ${CONTAINER_NAME}-${TAG} -d -p $PORT:80 ${REGISTRY_URL}:${TAG}"
        docker run --name ${CONTAINER_NAME}-${TAG} -d -p $PORT:80 ${REGISTRY_URL}:${TAG}
        echo ""
    fi
}
