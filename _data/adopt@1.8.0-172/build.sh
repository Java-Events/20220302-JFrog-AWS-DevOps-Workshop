#!/bin/bash
#function docker_tag_exists() {
#    EXISTS=$(curl -s  https://hub.docker.com/v2/repositories/$1/tags/?page_size=10000 | jq -r "[.results | .[] | .name == \"$2\"] | any")
#    test $EXISTS = true
#}

#if docker_tag_exists svenruppert/adopt 1.8.0-172; then
#    echo skip building, image already existing - svenruppert/adopt:1.8.0-172
#else
    echo start building the image
    docker build -t svenruppert/adopt .

    docker tag svenruppert/adopt:latest javahow.jfrog.io/docker/svenruppert/adopt:1.8.0-272
    docker push javahow.jfrog.io/docker/svenruppert/adopt:1.8.0-272

#fi
#    docker image rm svenruppert/adopt:latest
#    docker image rm svenruppert/adopt:1.8.0-172