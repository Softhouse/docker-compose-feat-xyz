#!/usr/bin/env bash

# deploys a docker-compose orchestration as an upstart service
# with the name of the directory this script is placed in,
# usually the name of the cloned repository.

path="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
name=${path##*/}

#check prerequisites
if [ ! -f ${path}/github_secret.env ]; then
	echo "creating default github_secret.env file"
	echo "This secret should match the configuration set in your github hooks"
	echo "GITHUB_SECRET=default_secret" > ${path}/github_secret.env
fi
source ${path}/github_secret.env
if [ -z $GITHUB_SECRET ]; then
	echo "Invalid github_secret.env file, should set environment variable"
	echo "GITHUB_SECRET=<your secret here>"
	exit 1
fi

if [ ! -f ${path}/google_auth_proxy.env ]; then
	echo "creating default google_auth_proxy.env file"
	echo "For instructions how to obtain client id and client secret, see"
	echo "https://github.com/bitly/google_auth_proxy#oauth-configuration"
	echo "GOOGLE_AUTH_PROXY_CLIENT_ID=default_client_id
GOOGLE_AUTH_PROXY_CLIENT_SECRET=default_client_secret
GOOGLE_AUTH_PROXY_COOKIE_SECRET=default_cookie_secret" > ${path}/google_auth_proxy.env
fi
source ${path}/google_auth_proxy.env
if [ -z $GOOGLE_AUTH_PROXY_CLIENT_ID ] || [ -z $GOOGLE_AUTH_PROXY_CLIENT_SECRET ] || [ -z $GOOGLE_AUTH_PROXY_COOKIE_SECRET ]; then
	echo "Invalid google_auth_proxy.env file, should set the environment variables"
	echo "GOOGLE_AUTH_PROXY_CLIENT_ID=<your client id here>"
	echo "GOOGLE_AUTH_PROXY_CLIENT_SECRET=<your client secret here>"
	echo "GOOGLE_AUTH_PROXY_COOKIE_SECRET=<your cookie secret here>"
	exit 1
fi

useradd -G docker $name

sudo service ${name} stop 2> /dev/null
#logging sugar to prevent people from thinking it doesn't work if it's done quietly by the first up command
docker-compose -f ${path}/docker-compose.yml pull && \
docker-compose -f ${path}/docker-compose.yml build

sudo sh -c "echo '
description \"A job for running the ${name} docker-compose service\"

setuid $name

start on filesystem and started docker on runlevel [2345]
stop on shutdown

post-stop script
	docker-compose -f ${path}/docker-compose.yml stop
end script

exec sh -c \"docker-compose -f ${path}/docker-compose.yml up\"
respawn' > /etc/init/${name}.conf"

sudo init-checkconf /etc/init/${name}.conf || exit 1
sudo service ${name} start

echo "Service ${name} successfully deployed"
echo "See /var/log/upstart/${name}.log for logs"
