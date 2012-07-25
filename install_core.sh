#!/bin/bash

set -e

MY_DIR="$( cd "$( dirname "$0" )" && pwd )"

echo
echo Updating system...
echo

apt-get update
apt-get install aptitude
aptitude -y full-upgrade
aptitude -y install wget vim less

# Install Git
aptitude -y install git-core

echo
echo Add filetransfer group...
echo

addgroup filetransfer

echo
echo Configure SSH
echo

read -p "What SSH port would you like to use? " my_ssh_port

cp /etc/ssh/sshd_config /etc/ssh/sshd_config.`date +%s`.bak
sed -i"-orig" "s/Port [0-9]\+/Port $my_ssh_port/" /etc/ssh/sshd_config
sed -i"-orig" "s/LoginGraceTime [0-9]\+/LoginGraceTime 30/" /etc/ssh/sshd_config
sed -i"-orig" "s/Subsystem sftp \/usr\/lib\/openssh\/sftp\-server/# Subsystem sftp \/usr\/lib\/openssh\/sftp-server/" /etc/ssh/sshd_config
cat >> /etc/ssh/sshd_config << EOF

Subsystem sftp internal-sftp

Match group filetransfer
  ChrootDirectory %h
  X11Forwarding no
  AllowTcpForwarding no
  ForceCommand internal-sftp
EOF

service ssh restart

echo
echo Install IPTables firewall...
echo

$MY_DIR/firewall.sh $my_ssh_port

echo
echo Install Bash Aliases and Plissken...
echo

cp ~/.bashrc ~/.bashrc.`date +%s`.bak
cat >> ~/.bashrc << EOF

if [ -f $MY_DIR/bashrc.sh ]; then
  source $MY_DIR/bashrc.sh
fi

if [ -f $MY_DIR/plissken.sh ]; then
  source $MY_DIR/plissken.sh
fi

EOF

echo
echo Done! You can now run ./install_lamp.sh to continue setting up your LAMP environment.
echo

