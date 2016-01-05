#!/usr/bin/env bash

# deploys a docker-compose orchestration as an upstart service
# with the name of the directory this script is placed in,
# usually the name of the cloned repository.

path="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
name=${path##*/}
compose_files=(docker-compose.yml oauth.yml apibackup.yml)
compose_file_args=$(echo "${compose_files[@]/#/-f ${path}/}")

useradd -G docker $name

sudo service ${name} stop 2> /dev/null
#logging sugar to prevent people from thinking it doesn't work if it's done quietly by the first up command
docker-compose ${compose_file_args} pull && \
docker-compose ${compose_file_args} build

sudo sh -c "echo '
description \"A job for running the ${name} docker-compose service\"

setuid $name

start on filesystem and started docker on runlevel [2345]
stop on shutdown

post-stop script
	docker-compose ${compose_file_args} stop
end script

exec sh -c \"docker-compose ${compose_file_args} up\"
respawn' > /etc/init/${name}.conf"

sudo init-checkconf /etc/init/${name}.conf || exit 1
sudo service ${name} start

echo "Service ${name} successfully deployed"
echo "See /var/log/upstart/${name}.log for logs"
