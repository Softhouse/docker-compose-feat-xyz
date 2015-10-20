#!/usr/bin/env bash

#Installing vagrant on ubuntu was a pita so it was added for convenience
#Not required to run the project, just very, very convenient since messing up upstart services bricks ubuntu

sudo apt-get -qqy purge virtualbox

vagrant_version=`curl -w %{redirect_url} https://bintray.com/mitchellh/vagrant/vagrant/_latestVersion`
vagrant_version=`echo ${vagrant_version##*/vagrant/}`
vagrant_version=`echo ${vagrant_version%/*}`
vagrant_url=https://dl.bintray.com/mitchellh/vagrant/vagrant_${vagrant_version}_x86_64.deb

curl -JLOs $vagrant_url

sudo dpkg -i ${vagrant_url##*/}
rm -f ${vagrant_url##*/}

mkdir -p ~/.gnupg
chmod 700 ~/.gnupg
touch ~/.gnupg/gpg.conf
chmod 600 ~/.gnupg/gpg.conf
sudo sh -c "echo deb http://download.virtualbox.org/virtualbox/debian trusty contrib > /etc/apt/sources.list.d/virtualbox.list"
curl -s http://download.virtualbox.org/virtualbox/debian/oracle_vbox.asc | sudo apt-key add -
sudo apt-get -qq update
sudo apt-get -qqy install -qqy virtualbox
