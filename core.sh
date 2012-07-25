#!/bin/bash

set -e

MY_DIR="$( cd "$( dirname "$0" )" && pwd )"

apt-get update
apt-get install aptitude
aptitude -y full-upgrade
aptitude -y install wget vim less

# Install Git
aptitude -y install git-core

# Set Hostname
read -p "What hostname would you like to use?" my_hostname
echo $my_hostname > /etc/hostname
hostname -F /etc/hostname
echo "ServerName $my_hostname" >> /etc/apache2/httpd.conf

# Add SFTP group
addgroup filetransfer

# Config SSH
read -p "What SSH port would you like to use?" my_ssh_port

cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak
sed -i'-orig' 's/Port [0-9]\+/Port $my_ssh_port/' /etc/ssh/sshd_config
sed -i'-orig' 's/LoginGraceTime [0-9]\+/LoginGraceTime 30/' /etc/ssh/sshd_config
cat > /etc/ssh/sshd_config << EOF

Subsystem sftp internal-sftp

Match group filetransfer
  ChrootDirectory %h
  X11Forwarding no
  AllowTcpForwarding no
  ForceCommand internal-sftp
EOF

# Install Firewall
$MY_PATH/firewall.sh $my_ssh_port

# Install Bash Aliases and Functions
cat > ~/.bashrc << EOF

if [ -f $MY_DIR/bashrc.sh ]; then
  source $MY_DIR/bashrc.sh
fi

if [ -f $MY_DIR/plissken.sh ]; then
  source $MY_DIR/plissken.sh
fi

EOF

