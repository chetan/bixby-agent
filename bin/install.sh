#!/usr/bin/env bash


# Bixby Agent install script
#
# Usage: \curl -sL https://get.bixby.io | bash -s [<tenant> <manager url>]
#
# Currently supported platforms:
#
#   Ubuntu 10.04, 12.04
#   CentOS or RHEL 5, 6
#   x86 and x64



################################################################################
# package repository
url="https://s3.bixby.io"

# seed with current build version
bixby_version=`\\curl -sL $url/latest`

function is_64() {
  [[ `uname -p` == "x86_64" ]]
}

function as_root() {
  if [[ `whoami` == root ]]; then
    $*
  else
    sudo env PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin" $*
  fi
}

if [[ -f /etc/issue ]]; then
  issue=`cat /etc/issue`
fi

if [[ $issue =~ ^"CentOS" ]]; then

  pkg="bixby-${bixby_version}"

  if [[ $issue =~ " 5" ]]; then
    pkg="$pkg.el5"
  elif [[ $issue =~ " 6" ]]; then
    pkg="$pkg.el6"
  else
    echo "ERROR: only Centos 5 & 6 are currently supported!"
    exit 1
  fi

  if is_64; then
    pkg="$pkg.x86_64"
  else
    pkg="$pkg.i686"
  fi
  pkg="$pkg.rpm"

  # install or upgrade
  if [[ ! `yum -q info bixby 2>/dev/null` ]]; then
    cmd="install"
  else
    cmd="upgrade"
  fi
  as_root yum -y $cmd $url/$pkg
  ret=$?
  if [[ $ret -ne 0 ]]; then
    echo "ERROR: installing $pkg: $ret"
    exit 1
  fi


elif [[ $issue =~ ^"Ubuntu" ]]; then

  pkg="bixby_${bixby_version}.ubuntu"

  if [[ $issue =~ "10.04" ]]; then
    pkg="$pkg.10.04"
  elif [[ $issue =~ "12.04" ]]; then
    pkg="$pkg.12.04"
  else
    echo "ERROR: only Ubuntu 10.04 & 12.04 are currently supported!"
    exit 1

  fi

  if is_64; then
    pkg="${pkg}_amd64"
  else
    pkg="${pkg}_i386"
  fi
  pkg="$pkg.deb"

  cd /tmp
  wget "$url/$pkg"
  as_root dpkg -i $pkg
  if [[ $? -ne 0 ]]; then
    echo "ERROR: installing $pkg"
    exit 1
  fi
  rm -f /tmp/$pkg
  cd -

else
    echo
    echo "ERROR: only Ubuntu and CentOS are currently supported!"
    echo
    exit 1
fi

tenant="<TENANT>"
if [[ -n "$1" ]]; then
  tenant="$1"
else
  tenant="<tenant>"
fi

mgr_url="<MANAGER URL>"
if [[ -n "$2" ]]; then
  mgr_url="$2"
else
  mgr_url="<manager url>"
fi

echo
echo
echo "bixby ${bixby_version} has been successfully installed! to get started, run:"
echo "sudo /opt/bixby/bin/bixby-agent -P -t ${tenant} -- ${mgr_url}"
echo
echo "or optionally add some tags while registering:"
echo "sudo /opt/bixby/bin/bixby-agent -P -t ${tenant} --tags tag1,tag2 -- ${mgr_url}"
echo
echo "or to see all available options:"
echo "/opt/bixby/bin/bixby-agent --help"
echo
