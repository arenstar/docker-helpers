#!/bin/bash

function clean_containers {
    echo '>>> Cleaning up containers'
    sudo docker ps -a | grep "Exit" | awk '{print $1}' | while read -r id ; do
        sudo docker rm $id
    done
}

function clean_images {
    echo '>>> Cleaning up images'
    sudo docker images | grep "^<none>" | head -n 1 | awk 'BEGIN { FS = "[ \t]+" } { print $3 }'  | while read -r id ; do
        sudo docker rmi $id
    done
}
