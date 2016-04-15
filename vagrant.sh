#!/usr/bin/env bash

#Installing vagrant on ubuntu was a pita so it was added for convenience
#Not required to run the project, just very, very convenient since messing up upstart services bricks ubuntu

sudo apt-get -qqy purge virtualbox

vagrant_version=`curl -sL https://releases.hashicorp.com/vagrant/ | sed -n -e 's#.*/vagrant/\([^/]*\).*#\1#p' | head -1`
vagrant_url=https://releases.hashicorp.com/vagrant/${vagrant_version}/vagrant_${vagrant_version}_x86_64.deb
curl -JLOs $vagrant_url
sudo dpkg -i ${vagrant_url##*/}
rm -f ${vagrant_url##*/}
