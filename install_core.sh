#!/bin/bash

set -e

MY_PATH="$( cd "$( dirname "$0" )" && pwd )"

echo
echo Updating system...
echo

apt-get update
apt-get install aptitude
aptitude -y full-upgrade
aptitude -y install git-core wget vim less

echo
echo Add SFTP filetransfer group...
echo

addgroup filetransfer

echo
echo Configure SSH
echo

read -p "What SSH port would you like to use? " MY_SSH_PORT

cp /etc/ssh/sshd_config /etc/ssh/sshd_config.`date +%s`.bak
sed -i"-orig" "s/Port [0-9]\+/Port $MY_SSH_PORT/" /etc/ssh/sshd_config
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

$MY_PATH/firewall.sh $MY_SSH_PORT

echo
echo Install Bash Aliases...
echo

cp ~/.bashrc ~/.bashrc.`date +%s`.bak
cat >> ~/.bashrc << EOF

if [ -f $MY_PATH/bashrc.sh ]; then
  source $MY_PATH/bashrc.sh
fi

EOF

echo
echo Done! You can now run ./install_lamp.sh to continue setting up your LAMP environment.
echo

