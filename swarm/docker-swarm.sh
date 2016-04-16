#!/usr/bin/env bash

driver="${1:-virtualbox}"
path="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
machine_prefix=${path##*/}

for label in {1..2} ;do
  export machine_name=${machine_prefix}-consul-${label}
  docker-machine create \
      -d ${driver} \
      --${driver}-memory 512 \
      ${machine_name}
  export advertise_ip="$(docker-machine ip ${machine_name})"
  eval $(docker-machine env ${machine_name})
  if [ "${label}" -eq "1" ];then
    compose_file_args="-f consul.yml"
    export consul_ip="$(docker-machine ip ${machine_name})"
  else
    compose_file_args="-f consul.yml -f manager-join.yml"
  fi
  docker-compose ${compose_file_args} stop
  docker-compose ${compose_file_args} rm -fv --all
  docker-compose ${compose_file_args} up -d

  export machine_name=${machine_prefix}-master-${label}
  master_name="${machine_name}"
  docker-machine create \
      -d ${driver} \
      --${driver}-memory 512 \
      --swarm \
      --swarm-master \
      --swarm-discovery="consul://${consul_ip}:8500" \
      --engine-opt="cluster-store=consul://${consul_ip}:8500" \
      --engine-opt="cluster-advertise=eth1:2376" \
      --swarm-opt replication \
      ${machine_name}
  export advertise_ip="$(docker-machine ip ${machine_name})"
  eval $(docker-machine env ${machine_name})
  compose_file_args="-f consul.yml -f agent-join.yml"
  docker-compose ${compose_file_args} stop
  docker-compose ${compose_file_args} rm -fv --all
  docker-compose ${compose_file_args} up -d

  export machine_name=${machine_prefix}-slave-${label}
  docker-machine create \
      -d ${driver} \
      --${driver}-memory 512 \
      --swarm \
      --swarm-discovery="consul://${consul_ip}:8500" \
      --engine-opt="cluster-store=consul://${consul_ip}:8500" \
      --engine-opt="cluster-advertise=eth1:2376" \
      ${machine_name}
  export advertise_ip="$(docker-machine ip ${machine_name})"
  eval $(docker-machine env ${machine_name})
  compose_file_args="-f consul.yml -f agent-join.yml"
  docker-compose ${compose_file_args} stop
  docker-compose ${compose_file_args} rm -fv --all
  docker-compose ${compose_file_args} up -d
done

eval $(docker-machine env --swarm $master_name)
