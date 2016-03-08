# xyz-deploy

Orchestrates a open web platform that deploys docker based web services on any endpoint using github hooks.

## Usage

### prerequisites

In order to protect against unauthorized containers being deployed using github hooks a preshared secret needs to be configured for this service and every repository hook. See https://developer.github.com/webhooks/securing/ how to configure hooks and hook secrets for a repository.

Create the preshared key file by executing the following command:

```
echo "GITHUB_SECRET=your_secret_here" > github_secret.env
```

If the oauth service is to be used, a similar file needs to be created for oauth configuration. See the oauth service below.

### Using docker Machine

Requires [docker toolbox](https://www.docker.com/docker-toolbox) to run.

Start git bash and execute the following commands to start the service:

1. clone this repo
1. ```cd xyz-deploy```
1. ```source docker-machine.sh```
1. ```docker-compose up -d```

The service is deployed to the ip address, port 80, listed in the docker-machine step.

The ```docker-machine.sh``` script defaults to creating a new machine using the virtualbox driver. See https://docs.docker.com/machine/drivers/ for how to deploy to a cloud service. Due to limitations in docker and docker-compose, the service can only be deployed to a single host until the docker networking support overhaul is fully implemented.

### Windows Vagrant installation

Requires [Vagrant](https://www.vagrantup.com/downloads.html) and [Virtualbox](https://www.virtualbox.org/wiki/Downloads) to run.

Perform the following steps to start the service:

1. clone this repo
1. ```cd RemoteGamingServer-Deploy```
1. ```vagrant up```

The service is deployed on port 80. Change the host port in docker-compose.yml to change the port mapped by vagrant/virtualbox.

### Linux Development installation with vagrant

1. clone this repo
1. ```cd RemoteGamingServer-Deploy```
1. ```bash vagrant.sh```
1. ```sudo vagrant up```

The service is deployed on port 80. Running vagrant as root is required to bind ports below 1024. Change the host port in docker-compose.yml to change the port mapped by vagrant/virtualbox.

### Linux Deployment installation

1. clone this repo
1. ```cd RemoteGamingServer-Deploy```
1. ```bash linux-docker.sh``` to install/upgrade latest docker and docker-compose
1. ```bash deploy.sh``` to install as an ubuntu upstart service

deploy.sh defaults to installing the optional ```oauth``` and ```apibackup``` services, see Services below.

The service is deployed on port 80.

## Services

The following services are defined in ```docker-compose.yml``` unless specified otherwise:

### mongodb

A [mongodb](https://hub.docker.com/_/mongodb/) image with data retained at the host path ```/var/mongo/db```

the mongodb service is used by the api and builder services. Optionally it can be periodically backed up by the apibackup service.

### katalog

A [katalog](https://hub.docker.com/r/joakimbeng/katalog/) image with data retained at the host path ```/var/lib/mysql```

Katalog is a service catalog and discovery application for use with Docker containers

Katalog listens on Docker events, like container starts and stops.
It looks for environment variables in containers with names KATALOG_VHOSTS and KATALOG_SERVICES and automatically adds them to its service and virtual host catalog. It also generates an nginx reversed proxy config for all virtual hosts.

### sitewatcher

An [nginx](https://hub.docker.com/_/nginx/) Docker container which automatically reloads nginx when sites-enabled configs change.

### api

A docker image built from [Softhouse/laughing-batman](https://github.com/Softhouse/laughing-batman)

Dynamic Restful ExpressJS And MongoDB Service

This is a REST API server built using ExpressJS and MongoDB. It has dynamic endpoints, e.g. POST /item will create a MongoDB collection called item and insert the posted body into the collection. The stored "item" can then be retreived by GET /item.

### builder

A docker image built from [Softhouse/flaming-computing-machine](https://github.com/Softhouse/flaming-computing-machine.git)

Build docker containers from GitHub repositories
The build queue

This service reads from the build queue stored by the api service and triggers docker build for them

To enable builds from private repositories you need to put ssh keys and config (id_rsa, id_rs.pub, ssh_config) in the builder/ssh folder

### proxy

An [nginx](https://hub.docker.com/_/nginx/) image responsible for filtering github requests if the optional oauth service is enabled.

### apibackup

A docker image built from [Softhouse/docker-mongodump](https://github.com/Softhouse/docker-mongodump.git)

The apibackup service creates backups of the mongodb service data at regular intervals.

This service is optional. To include this service, add ```-f apibackup.yml``` to the docker-compose command, ie. ```docker-compose -f docker-compose.yml -f apibackup.yml```.

TODO restore?

### oauth

An [a5huynh/oauth2_proxy](https://hub.docker.com/r/a5huynh/oauth2_proxy) image which is a dockerized version of an oauth2 proxy implementation by [bitly](https://bitly.com). This service is currently configured to use google as oauth provider and limit access to members of the softhouse organization.
See github [README](https://github.com/bitly/oauth2_proxy/blob/master/README.md) for how to configure the plugin.

The oauth service adds oauth perimiter securcurity to the service.

The oauth service requires a google client id, client secret and optionally a cookie secret salt random string. See https://developers.google.com/identity/protocols/OAuth2 on how to obtain a client id and client secret.

Execute the following commands to create an google auth environment file.

```
echo "OAUTH2_PROXY_CLIENT_ID==default_client_id > oauth_proxy.env
echo "OAUTH2_PROXY_CLIENT_SECRET=default_client_secret >> oauth_proxy.env
echo "OAUTH2_PROXY_COOKIE_SECRET=default_cookie_secret >> oauth_proxy.env
```

This service is optional. To include this service, add ```-f oauth.yml``` to the docker-compose command, ie. ```docker-compose -f docker-compose.yml -f oauth.yml```.


### docker-bench-security

An optional service that performs a security benchmark of the deployed services using a [docker-bench-security](https://github.com/docker/docker-bench-security) image. The results of the audit is printed to console and the service terminates.

To perform a security benchmark either include this service, by adding ```-f docker-bench-security.yml``` to the docker-compose command, or start the service separately by specifying ```docker-bench-security.yml``` as the only file argument.
