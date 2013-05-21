#!/bin/bash

function logger() {

  local log_level=$1
  local message=$2
  local log_date=$(date '+%Y-%m-%d-%H:%M:%S')

  echo "$log_date : $log_level : [$stage] : $message"
}

function error() {
  local err=$?
  current_dir=$(pwd -P)

  logger "ERROR" "************************************"
  logger "ERROR" "Info:"
  logger "ERROR" " * Current dir : $current_dir"
  logger "ERROR" " * Command     : $BASH_COMMAND"
  logger "ERROR" " * Error       : $err"
  logger "ERROR" " * Line        : $BASH_LINENO"
  logger "ERROR" "************************************"
  logger "ERROR" "Exit"

  exit 1
}

function _pass() {
  echo "PASS errors"
}


# Create USER/GROUP
logger "INFO" "Create user and group"
if [ -z $ALCO_USER ]; then
  echo "ALCO_USER not set, using default setting"
  ALCO_USER='devel'
fi
if [ -z $ALCO_GROUP ]; then
  echo "ACLO_GROUP is not set, using default settings"
  ALCO_GROUP='development'
fi
if [ -z $ALCO_PASSWD ]; then
  echo "ALCO_PASSWD is not set, using default settings"
  ALCO_PASSWD='Ly5rouBFQZ'
fi

getent group $ALCO_GROUP || groupadd $ALCO_GROUP
getent passwd $ALCO_USER || useradd -m -s /bin/bash -g $ALCO_GROUP $ALCO_USER

echo "$ALCO_USER:$ALCO_PASSWD" | chpasswd

# RVM URI
[ -z $RVM_URI ] && RVM_URI="https://get.rvm.io"


# Trap all errors
trap error ERR

#
logger "INFO" "Setup apt"
rm -f /etc/apt/sources.list.d/*
install -m 0644 cookbooks/alco/files/default/squeeze.list /etc/apt/sources.list.d/squeeze.list

logger "INFO" "Install packages"

PACKAGES="  patch bzip2 ca-certificates gawk g++ gcc make libc6-dev patch"
PACKAGES+=" openssl ca-certificates libreadline6 libreadline6-dev curl zlib1g"
PACKAGES+=" zlib1g-dev libssl-dev libyaml-dev libsqlite3-dev sqlite3 libxml2-dev"
PACKAGES+=" libxslt1-dev autoconf libc6-dev libgdbm-dev libncurses5-dev automake"
PACKAGES+=" libtool bison pkg-config libffi-dev"
PACKAGES+=" curl git-core less runit bzip2 ntpdate rsync"

export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get -y --force-yes install $PACKAGES -o DPkg::Options::="--force-confold"

logger "INFO" "Install rvm"
curl -L $RVM_URI | bash -s stable

. /usr/local/rvm/scripts/rvm
rvm install ruby-1.9.3-p194
rvm use ruby-1.9.3-p194 --default

logger "INFO" "Install necessary gems"
gem install chef
gem install capistrano-node-deploy

logger "INFO" "Add $ALCO_USER to rvm group"
usermod -a -G rvm $ALCO_USER

# Dirty hack, yea
trap _pass ERR
logger "INFO" "Install nodejs"
dpkg -i ./node_v0.10.6-1_i386.deb || apt-get -f install
trap error ERR

# Settings for chef
mkdir -p /etc/chef/
cat > /etc/chef/solo.rb <<'EOF'
log_level          :info
log_location       STDOUT
file_cache_path    "/var/cache/chef"
file_backup_path   "/var/lib/chef/backup"
cache_options({ :path => "/var/cache/chef/checksums", :skip_expires => true})
signing_ca_user "chef"

cookbook_path [ "/var/chef-solo/current/cookbooks" ]

Mixlib::Log::Formatter.show_time = true
Gem.Deprecate.skip = true
EOF

# Sync cookbooks
version="$(date +%Y%m%d%H%M%S)"
mkdir -p /var/chef-solo/releases/${version}
rsync -avzlp cookbooks /var/chef-solo/releases/${version}/
ln -nsf /var/chef-solo/releases/${version} /var/chef-solo/current

# Run chef-solo
logger "INFO" "Run chef-solo"
cp "./bootstrap.json" /var/chef-solo/current/
chef-solo -c /etc/chef/solo.rb -j "/var/chef-solo/current/bootstrap.json" -l info

logger "INFO" "Congratulations! All done."
