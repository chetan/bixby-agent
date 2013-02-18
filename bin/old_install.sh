#!/usr/bin/env bash

set -e

# helpers
uname=$(uname)

is_mac() {
  [[ $uname == "Darwin" ]]
}

is_centos() {
  [[ -f /etc/centos-release ]]
}

is_ubuntu() {
  [[ -f /etc/lsb-release ]] &&
    GREP_OPTIONS="" \grep "DISTRIB_ID=Ubuntu" /etc/lsb-release >/dev/null
}

# install deps
if [[ is_ubuntu ]]; then
  DEBIAN_FRONTEND=noninteractive
  apt-get -yqq install build-essential ruby rubygems curl libcurl4-openssl-dev libopenssl-ruby > /dev/null
elif [[ is_centos ]]; then
  yum -q install ruby ruby-devel curl-devel rdoc ri zlib zlib-devel
fi

# grab bixby
wget -q http://192.168.80.99/~chetan/bixby/bixby-agent.tar.gz
tar -xzf bixby-agent.tar.gz
cd bixby/

# fix rubygems
gem install -q vendor/cache/rubygems-update*.gem --no-ri --no-rdoc > /dev/null
ruby /var/lib/gems/1.8/gems/rubygems-update-*/setup.rb > /dev/null

# install gems
bin/bundle install --deployment --local --without development test > /dev/null

# move into place
cd ..
mv bixby /opt/
