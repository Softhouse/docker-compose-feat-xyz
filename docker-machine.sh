#!/usr/bin/env bash

# Provisions a virtualbox docker machine.
# Needs to be sourced for the exported variables to be available in the current shell

path="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
MACHINE_NAME=${path##*/}
if [ `docker-machine ls | awk 'NR > 1 { print $1 }' | grep $MACHINE_NAME | wc -l` -eq 0 ];then
	docker-machine create --driver virtualbox $MACHINE_NAME
fi
eval "$(docker-machine env $MACHINE_NAME)"

docker-machine scp -r builder ${MACHINE_NAME}:~/
docker-machine scp -r oauth ${MACHINE_NAME}:~/
docker-machine scp -r proxy ${MACHINE_NAME}:~/

echo $DOCKER_HOST  | sed 's#^tcp:#http#'