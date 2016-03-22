# -*- mode: ruby -*-
# vi: set ft=ruby :

require 'yaml'
vagrant_root = File.dirname(__FILE__)  # Vagrantfile location

Vagrant.configure(2) do |config|
  config.vm.provider "virtualbox" do |v|
    v.memory = 1024
    v.cpus = 2
  end

  files = Dir.glob("#{vagrant_root}/*.yml")
    files.each do |file|
    yml = YAML::load_file(file)
    yml['services'].each do |service|
      ports = service[1]['ports'].each do |port|
        if port =~ /:/
          host, guest, protocol = port.split(/[\/:]/)
          config.vm.network "forwarded_port", guest: host, host: host, protocol: protocol ||= 'tcp'
        end
      end unless service[1]['ports'].nil?
    end unless yml.nil?
  end unless files.nil?

  config.vm.box = "ubuntu/trusty64"
  config.vm.box_check_update = true

  ## fix "stdin: is not a tty"
  config.vm.provision :shell, inline: "sed -i 's/^mesg n$/tty -s \\&\\& mesg n/' /root/.profile"
  ## install docker, machine and compose
  config.vm.provision :shell, path: 'linux-docker.sh', privileged: false

  ## run the service
  #config.vm.provision :shell, inline: 'sg docker "docker-compose -f /vagrant/docker-compose.yml -f /vagrant/docker-bench-security.yml"'

  ## deploy as upstart service and benchmark security
  config.vm.provision :shell, inline: 'sg docker "/vagrant/deploy.sh"'
end
