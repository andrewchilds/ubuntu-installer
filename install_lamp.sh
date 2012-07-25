#!/bin/bash

set -e

MY_PATH="$( cd "$( dirname "$0" )" && pwd )"

read -p "What path would you like to use for Apache virtualhosts? (For example, /srv or /var/www)" VHOST_PATH

echo
echo Install Apache & PHP5
echo

aptitude -y install apache2 php5 php5-mysql libapache-mod-ssl libapache2-mod-php5 php5-curl

echo
echo Set up self-signed SSL certificate
echo

mkdir /etc/apache2/ssl
openssl req -new -x509 -days 365 -nodes -out /etc/apache2/ssl/apache.pem -keyout /etc/apache2/ssl/apache.key

echo
echo Set Hostname
echo

read -p "What hostname would you like to use? " MY_HOSTNAME
echo $MY_HOSTNAME > /etc/hostname
hostname -F /etc/hostname
echo "ServerName $MY_HOSTNAME" >> /etc/apache2/httpd.conf

echo
echo Install MySQL
echo

sudo DEBIAN_FRONTEND=noninteractive aptitude -q -y install mysql-server libmysqld-dev

echo
echo Disable default Apache virtualhost
echo

a2dissite default

echo
echo PHP configuration
echo

sed -i'-orig' 's/memory_limit = [0-9]\+M/memory_limit = 128M/' /etc/php5/apache2/php.ini

echo
echo Apache configuration
echo

a2enmod rewrite ssl
/etc/init.d/apache2 restart

echo
echo Set up Apache virtualhost directory structure at $VHOST_PATH
echo

mkdir -p $VHOST_PATH/www $VHOST_PATH/logs $VHOST_PATH/auth

echo
echo Apache virtualhost logrotate config
echo

cat > /etc/logrotate.d/virtualhosts << EOF
$VHOST_PATH/logs/*.log {
  weekly
  missingok
  rotate 3
  nocompress
  notifempty
  create 644 root root
  sharedscripts
  postrotate
    if [ -f "`. /etc/apache2/envvars ; echo ${APACHE_PID_FILE:-/var/run/apache2.pid}`" ]; then
      /etc/init.d/apache2 reload > /dev/null
    fi
  endscript
}
EOF

echo
echo Install Plissken utility
echo

cp ~/.bashrc ~/.bashrc.`date +%s`.bak
cat >> ~/.bashrc << EOF

export VHOST_PATH=$VHOST_PATH

if [ -f $MY_PATH/plissken.sh ]; then
  source $MY_PATH/plissken.sh
fi

EOF

echo
echo Done!
echo

