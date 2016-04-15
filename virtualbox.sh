#!/usr/bin/env bash

#Installing virtualbox on ubuntu was a pita so it was added for convenience
#Not required to run the project, just very, very convenient since messing up upstart services bricks ubuntu

mkdir -p ~/.gnupg
chmod 700 ~/.gnupg
touch ~/.gnupg/gpg.conf
chmod 600 ~/.gnupg/gpg.conf
sudo sh -c "echo deb http://download.virtualbox.org/virtualbox/debian trusty contrib > /etc/apt/sources.list.d/virtualbox.list"
curl -s http://download.virtualbox.org/virtualbox/debian/oracle_vbox.asc | sudo apt-key add -
sudo apt-get -qq update
virtualbox_package=`apt-cache search virtualbox | tail -1 | awk '{print $1}'`
sudo apt-get -qqy install -qqy $virtualbox_package
