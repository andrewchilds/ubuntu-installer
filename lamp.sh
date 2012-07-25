#!/bin/bash

set -e

# Install Apache & PHP5
aptitude -y install apache2 php5 php5-mysql libapache2-mod-php5 php5-curl

# Install MySQL
sudo DEBIAN_FRONTEND=noninteractive aptitude -q -y install mysql-server libmysqld-dev

# Disable default virtualhost
a2dissite default

# PHP config
sed -i'-orig' 's/memory_limit = [0-9]\+M/memory_limit = 128M/' /etc/php5/apache2/php.ini

# Apache config
a2enmod rewrite ssl
/etc/init.d/apache2 restart

# Set up Virtualhost directory structure
mkdir -p /srv/www /srv/logs

# Virtualhost logrotate config
cat > /etc/logrotate.d/virtualhosts << EOF
/srv/logs/*.log {
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
