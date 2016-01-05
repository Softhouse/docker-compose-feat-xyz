#!/usr/bin/env bash

#installs latest docker, docker-machine and docker-compose

#prerequisites
sudo apt-get update -qqy && sudo apt-get install -qqy curl cgroup-lite apparmor

#docker
curl -s https://get.docker.com/ | sudo sh
sudo usermod -a -G docker `id -g -n` # requires relogin. Need to manually set group docker, "sg docker" until you do.

#Compose
compose_version=`curl -sw %{redirect_url} https://github.com/docker/compose/releases/latest`
compose_version=`echo ${compose_version##*/}`
sudo bash -c "curl -sL https://raw.githubusercontent.com/docker/compose/${compose_version}/contrib/completion/bash/docker-compose > /etc/bash_completion.d/docker-compose"
sudo bash -c "curl -sL https://github.com/docker/compose/releases/download/${compose_version}/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose"
sudo chmod +rx /usr/local/bin/docker-compose

#Machine
machine_version=`curl -sw %{redirect_url} https://github.com/docker/machine/releases/latest`
machine_version=`echo ${machine_version##*/}`
sudo bash -c "curl -sL https://github.com/docker/machine/releases/download/${machine_version}/docker-machine_`uname -s`-`uname -m` > /usr/local/bin/docker-machine"
sudo chmod +rx /usr/local/bin/docker-machine