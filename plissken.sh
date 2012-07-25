#!/bin/bash

function create_mysql_user {
    [ $# -lt 3 ] && { echo "Usage: create_mysql_user username password databasename"; return; }

    mysqladmin create $3
    mysql -u root -e "GRANT ALL ON $3.* TO '$1'@localhost IDENTIFIED BY '$2';"
}

function create_sftp_user {
    [ $# -lt 2 ] && { echo "Usage: create_sftp_user username domain"; return; }

    useradd -d $VHOST_PATH/www/$2 $1
    passwd $1
    usermod -G filetransfer $1
    chown -R $1:$1 $VHOST_PATH/www/$2/*
}

function create_apache_virtualhost {
    [ $# -lt 1 ] && { echo "Usage: create_apache_virtualhost domain"; return; }

    if [ -e "/etc/apache2/sites-available/$1" ]; then
        echo /etc/apache2/sites-available/$1 already exists
        return;
    fi

    mkdir -p $VHOST_PATH/www/$1/pub

    cat > /etc/apache2/sites-available/$1 << EOF
<VirtualHost *:80>
    ServerName $1
    ServerAlias www.$1
    DocumentRoot $VHOST_PATH/www/$1/pub
    ErrorLog $VHOST_PATH/logs/all.error.log
    CustomLog $VHOST_PATH/logs/all.access.log vhost_combined
</VirtualHost>
<VirtualHost *:443>
    SSLEngine On
    SSLCertificateFile /etc/apache2/ssl/apache.pem
    SSLCertificateKeyFile /etc/apache2/ssl/apache.key
    ServerAdmin admin@$1
    ServerName $1
    ServerAlias www.$1
    DocumentRoot $VHOST_PATH/www/$1/pub
    ErrorLog $VHOST_PATH/logs/secure.error.log
    CustomLog $VHOST_PATH/logs/secure.access.log vhost_combined
</VirtualHost>
EOF

    a2ensite $1
    /etc/init.d/apache2 reload

}

function create_apache_site {
    [ $# -lt 2 ] && { echo "Usage: create_apache_site domain username"; return; }

    create_apache_virtualhost $1
    create_sftp_user $2 $1
}

function create_apache_subdomain {
    [ $# -lt 2 ] && { echo "Usage: create_apache_subdomain subdomain domain"; return; }

    if [ -e "/etc/apache2/sites-available/$1.$2" ]; then
        echo /etc/apache2/sites-available/$1.$2 already exists
        return;
    fi

    local DOMAINOWNER=`ls -l $VHOST_PATH/www/$2 | grep pub | awk '{print $3}'`

    mkdir -p $VHOST_PATH/www/$2/subdomains/$1/pub

    chown $DOMAINOWNER:$DOMAINOWNER $VHOST_PATH/www/$2/subdomains $VHOST_PATH/www/$2/subdomains/$1 $VHOST_PATH/www/$2/subdomains/$1/pub

    cat > /etc/apache2/sites-available/$1.$2 << EOF
<VirtualHost *:80>
    ServerName $1.$2
    DocumentRoot $VHOST_PATH/www/$2/subdomains/$1/pub
    ErrorLog $VHOST_PATH/logs/all.error.log
    CustomLog $VHOST_PATH/logs/all.access.log vhost_combined
</VirtualHost>
<VirtualHost *:443>
    SSLEngine On
    SSLCertificateFile /etc/apache2/ssl/apache.pem
    SSLCertificateKeyFile /etc/apache2/ssl/apache.key
    ServerAdmin admin@$1
    ServerName $1.$2
    DocumentRoot $VHOST_PATH/www/$2/subdomains/$1/pub
    ErrorLog $VHOST_PATH/logs/secure.error.log
    CustomLog $VHOST_PATH/logs/secure.access.log vhost_combined
</VirtualHost>
EOF

    a2ensite $1.$2
    /etc/init.d/apache2 reload

}

function delete_virtualhost {
    [ $# -lt 1 ] && { echo "Usage: delete_virtualhost domain"; return; }

    if [ ! -e "/etc/apache2/sites-available/$1" ]; then
        echo /etc/apache2/sites-available/$1 does not exist
        return;
    fi

    a2dissite $1
    /etc/init.d/apache2 reload

    rm -f /etc/apache2/sites-available/$1
    rm -rf $VHOST_PATH/www/$1

}

function delete_subdomain {
    [ $# -lt 2 ] && { echo "Usage: delete_subdomain subdomain domain"; return; }

    if [ ! -e "/etc/apache2/sites-available/$1.$2" ]; then
        echo /etc/apache2/sites-available/$1.$2 does not exist
        return;
    fi

    a2dissite $1.$2
    /etc/init.d/apache2 reload

    rm -f /etc/apache2/sites-available/$1.$2
    rm -rf $VHOST_PATH/www/$2/subdomains/$1

}

function password_protect {
    [ $# -lt 2 ] && { echo "Usage: password_protect directory username"; return; }

    cat > $1/.htaccess << EOF
AuthType Basic
AuthUserFile $VHOST_PATH/auth/.htpasswd
AuthName "Authorized Access Only"
Require valid-user
EOF

    if [ -e "$VHOST_PATH/auth/.htpasswd" ];
        then htpasswd -s $VHOST_PATH/auth/.htpasswd $2
        else htpasswd -cs $VHOST_PATH/auth/.htpasswd $2
    fi

}

