# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|
  config.vm.provider "virtualbox" do |v|
    v.memory = 1024
    v.cpus = 2
  end
  config.vm.box = "ubuntu/trusty64"
  config.vm.network "forwarded_port", guest: 80, host: 8080 # must match the port used for callback

  config.vm.provision :shell, inline: "sed -i 's/^mesg n$/tty -s \\&\\& mesg n/' /root/.profile"
  config.vm.provision :shell, path: 'linux-docker.sh', privileged: false

  ## run locally
  config.vm.provision :shell, inline: 'sg docker "docker-compose -f /vagrant/docker-compose.yml up -d"', privileged: false

  ## deploy as upstart service and security benchmark
  #config.vm.provision :shell, inline: 'sg docker "/vagrant/deploy.sh"'
  #config.vm.provision :shell, inline: 'sg docker "docker-compose -f /vagrant/docker-bench-security.yml up"'
end
