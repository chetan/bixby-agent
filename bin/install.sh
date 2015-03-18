#!/usr/bin/env bash


# Bixby Agent install script
#
# Usage: \curl -sL https://get.bixby.io | bash -s -- --register <manager url> --token <token> [--tags tag1,tag2]
# Beta:  \curl -sL https://get.bixby.io | BETA=1 bash -s ...
#
# Params can be excluded when upgrading
#
# Currently supported platforms:
#
#   Ubuntu 10.04, 12.04
#   CentOS or RHEL 5, 6
#   Amazon Linux
#   x86, x64



################################################################################
# package repository
url="https://s3.bixby.io"
latest="latest"

if [[ "$1" == "--" ]]; then
  # strip -- from args
  args="${@:2}"
else
  args="$@"
fi

UPGRADE=0
if [[ "$BETA" == "1" ]]; then
  latest="latest-beta"
fi

is_64() {
  [[ `uname -p` == "x86_64" ]]
}

as_root() {
  path="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:$PATH"
  if [[ `whoami` == root ]]; then
    env PATH="$path" $*
  else
    sudo env PATH="$path" $*
  fi
}

fetch() {
  if [[ -n `which curl 2>/dev/null` ]]; then
    if [[ -n "$2" ]]; then
      \curl -sL $1 -o "$2"
    else
      \curl -sL $1
    fi
  elif [[ -n `which wget 2>/dev/null` ]]; then
    if [[ -n "$2" ]]; then
      \wget -q $1 -O "$2"
    else
      \wget -q $1 -O -
    fi
  else
    echo "neither curl or wget are available?!"
    exit 1
  fi
}

escape_url() {
  # beta builds may have a + char which needs to be replaced
  echo $1 | sed -e 's/\+/%2B/'
}

# Test for interactive shell
is_interactive() {
  # check for 'i' flag in bash env
  # http://stackoverflow.com/a/16935422/102920
  [[ ${-#*i} != ${-} ]]
}

# seed with current build version
bixby_version=$(fetch $url/$latest)

if [[ -f /etc/issue ]]; then
  issue=`cat /etc/issue`
fi

install_centos() {
  # grab cent ver
  ver=$(echo $issue | head -n 1 | sed -E 's/.*?([0-9]+)\.[0-9]+.*/\1/')
  if [[ $ver != "5" && $ver != "6" ]]; then
    echo "ERROR: only Centos 5 & 6 are currently supported!"
    exit 1
  fi

  # check if upgrade
  rpm -qa bixby | grep bixby >/dev/null
  if [[ $? -eq 0 && -f /opt/bixby/etc/bixby.yml ]]; then
    UPGRADE=1
  fi

  # select package
  pkg="bixby-${bixby_version}.el$ver"

  if is_64; then
    pkg="$pkg.x86_64"
  else
    pkg="$pkg.i686"
  fi
  pkg="$pkg.rpm"
  pkg_url="$url/agent/centos/$ver/$pkg"

  # download and install
  if [[ ! `yum -q info bixby 2>/dev/null` ]]; then
    cmd="install"
  else
    cmd="upgrade"
  fi

  as_root yum -y $cmd $(escape_url $pkg_url)
  ret=$?
  if [[ $ret -ne 0 ]]; then
    echo "ERROR: installing $pkg: $ret"
    exit 1
  fi
}

install_amazon() {
  # grab amazon ver
  ver=$(echo $issue | head -n 1 | sed -E 's/.*? ([0-9]+\.[0-9]+).*/\1/')

  # check if upgrade
  rpm -qa bixby | grep bixby >/dev/null
  if [[ $? -eq 0 && -f /opt/bixby/etc/bixby.yml ]]; then
    UPGRADE=1
  fi

  pkg="bixby-${bixby_version}"
  if is_64; then
    pkg="$pkg.x86_64"
  else
    pkg="$pkg.i686"
  fi
  pkg="$pkg.rpm"
  pkg_url="$url/agent/amazon/$ver/$pkg"

  # download and install
  if [[ ! `yum -q info bixby 2>/dev/null` ]]; then
    cmd="install"
  else
    cmd="upgrade"
  fi

  as_root yum -y $cmd $(escape_url $pkg_url)
  ret=$?
  if [[ $ret -ne 0 ]]; then
    echo "ERROR: installing $pkg: $ret"
    exit 1
  fi
}

install_ubuntu() {
  # grab ubuntu ver
  ver=$(echo $issue | head -n 1 | egrep -o '([0-9]+\.[0-9]+)')

  supported_versions="10.04 12.04 13.04 13.10"
  if [[ 0 -ne `echo $supported_versions | grep $ver >/dev/null` ]]; then
    echo "ERROR: Only the following versions of Ubuntu are currently supported by this installer:"
    echo $supported_versions
    exit 1
  fi

  # check if upgrade
  dpkg -l bixby >/dev/null 2>&1
  if [[ $? -eq 0 && -f /opt/bixby/etc/bixby.yml ]]; then
    UPGRADE=1
  fi

  # select package
  pkg="bixby_${bixby_version}"
  if is_64; then
    pkg="${pkg}_amd64"
  else
    pkg="${pkg}_i386"
  fi
  pkg="$pkg.deb"
  pkg_url="$url/agent/ubuntu/$ver/$pkg"

  # download and install
  cd /tmp

  echo "downloading $pkg_url ..."
  fetch $(escape_url "$pkg_url") "$pkg"

  as_root dpkg -i $pkg
  if [[ $? -ne 0 ]]; then
    echo "ERROR: installing $pkg"
    exit 1
  fi
  rm -f /tmp/$pkg
  cd -
}

install_help() {
  echo
  echo
  echo "bixby ${bixby_version} has been successfully installed! to register this node, run:"
  echo "sudo /opt/bixby/bin/bixby-agent --register <url> --token <token>"
  echo
  echo "or optionally add some tags while registering:"
  echo "sudo /opt/bixby/bin/bixby-agent --register <url> --token <token> --tags tag1,tag2"
  echo
  echo "or to see all available options:"
  echo "/opt/bixby/bin/bixby-agent --help"
  echo
}

install() {

  amzn='^Amazon Linux AMI'
  centos='^CentOS'
  ubuntu='^Ubuntu'

  if [[ $issue =~ $centos ]]; then
    # e.g., CentOS release 5.10
    install_centos;

  elif [[ $issue =~ $amzn ]]; then
    # e.g., Amazon Linux AMI 2013.09
    install_amazon;

  elif [[ $issue =~ $ubuntu ]]; then
    # e.g., Ubuntu 13.04
    install_ubuntu;

  else
    echo
    echo "ERROR: only Ubuntu, CentOS and Amazon Linux are currently supported!"
    echo
    exit 1
  fi


  if [[ "$UPGRADE" == "1" ]]; then
    echo
    echo "bixby upgraded to ${bixby_version}"
    echo
    echo "to restart agent now, run: sudo /etc/init.d/bixby restart"
    exit
  fi

  if [[ "$args" == "" ]]; then
    install_help
    exit
  fi

  as_root /opt/bixby/bin/bixby-agent $args
  if [[ $? -eq 0 ]]; then
    # finally, start god service also
    as_root /etc/init.d/bixby start >/dev/null
  fi
}

install;
