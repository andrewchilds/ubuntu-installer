## Usage

### Setup

```bash
apt-get update
apt-get install aptitude
aptitude -y full-upgrade
aptitude -y install git-core
git clone git@github.com:andrewchilds/ubuntu-installer.git
cd ubuntu-installer
```

### Setup IPTables, SSH and bash aliases

```bash
./install_core.sh
```

### Install LAMP Stack and Plissken

```bash
./install_lamp.sh
```

## Plissken API

Create MySQL user

```bash
$ create_mysql_user username password databasename
```

Create SFTP user

```bash
$ create_sftp_user username domain
```

Create Apache virtualhost

```bash
$ create_apache_virtualhost domain
```

Create Apache virtualhost and SFTP user

```bash
$ create_apache_site domain username
```

Create Apache subdomain

```bash
$ create_apache_subdomain subdomain domain
```

Delete Virtualhost

```bash
$ delete_virtualhost domain
```

Delete subdomain

```bash
$ delete_subdomain subdomain domain
```

Password protect a directory

```bash
$ password_protect directory username
```

