#!/usr/bin/env bash


# Bixby Agent install script
#
# Usage: \curl -sL https://get.bixby.io | bash -s [<tenant> <manager url>]
# Beta:  \curl -sL https://get.bixby.io | BETA=1 bash -s [<tenant> <manager url>]
#
# Params can be excluded when upgrading
#
# Currently supported platforms:
#
#   Ubuntu 10.04, 12.04
#   CentOS or RHEL 5, 6
#   x86 and x64



################################################################################
# package repository
url="https://s3.bixby.io"
latest="latest"

if [[ "$BETA" == "1" ]]; then
  latest="latest-beta"
fi

# seed with current build version
bixby_version=`\\curl -sL $url/$latest`

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

function escape_url() {
  # beta builds may have a + char which needs to be replaced
  echo $1 | sed -e 's/\+/%2B/'
}

# Test for interactive shell
function is_interactive() {
  # check for 'i' flag in bash env
  # http://stackoverflow.com/a/16935422/102920
  [[ ${-#*i} != ${-} ]]
}

if [[ -f /etc/issue ]]; then
  issue=`cat /etc/issue`
fi

if [[ $issue =~ ^"CentOS" ]]; then

  # check if upgrade
  rpm -qa bixby | grep bixby >/dev/null
  if [[ $? -eq 0 && -f /opt/bixby/etc/bixby.yml ]]; then
    UPGRADE=1
  fi

  # select package
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

  # download and install
  if [[ ! `yum -q info bixby 2>/dev/null` ]]; then
    cmd="install"
  else
    cmd="upgrade"
  fi
  as_root yum -y $cmd $(escape_url $url/$pkg)
  ret=$?
  if [[ $ret -ne 0 ]]; then
    echo "ERROR: installing $pkg: $ret"
    exit 1
  fi

elif [[ $issue =~ ^"Ubuntu" ]]; then

  # check if upgrade
  dpkg -l bixby >/dev/null 2>&1
  if [[ $? -eq 0 && -f /opt/bixby/etc/bixby.yml ]]; then
    UPGRADE=1
  fi

  # select package
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

  # download and install
  cd /tmp

  echo "downloading $url/$pkg ..."
  if is_interactive; then
    curl -L# $(escape_url "$url/$pkg") -o "$pkg"
  else
    curl -sL $(escape_url "$url/$pkg") -o "$pkg"
  fi

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


if [[ "$UPGRADE" == "1" ]]; then
  echo
  echo "bixby upgraded to ${bixby_version}"
  exit
fi


tenant="<TENANT>"
if [[ -n "$1" ]]; then
  tenant="$1"
fi

mgr_url="<MANAGER URL>"
if [[ -n "$2" ]]; then
  mgr_url="$2"
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
