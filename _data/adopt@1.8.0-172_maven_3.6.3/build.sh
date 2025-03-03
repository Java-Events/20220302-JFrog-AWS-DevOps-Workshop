##!/bin/bash
#function docker_tag_exists() {
#    EXISTS=$(curl -s  https://hub.docker.com/v2/repositories/$1/tags/?page_size=10000 | jq -r "[.results | .[] | .name == \"$2\"] | any")
#    test $EXISTS = true
#}

#if docker_tag_exists svenruppert/maven-3.6.1-adopt 1.8.0-172; then
#    echo skip building, image already existing - svenruppert/maven-3.6.1-adopt 1.8.0-172
#else
    echo start building the images
    docker build -t svenruppert/maven-3.6.3-adopt .
    docker tag svenruppert/maven-3.6.3-adopt:latest svenruppert001.jfrog.io/docker/svenruppert/maven-3.6.3-adopt:1.8.0-172
    docker push svenruppert001.jfrog.io/docker/svenruppert/maven-3.6.3-adopt:1.8.0-172
#fi
#    docker image rm svenruppert/maven-3.6.1-adopt:latest
#    docker image rm svenruppert/maven-3.6.1-adopt:1.8.0-172