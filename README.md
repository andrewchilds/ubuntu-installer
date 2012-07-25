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

### Setup IPTables, SSH, bash aliases and Plissken

```bash
./install_core.sh
```

### Install LAMP Stack

```bash
./install_lamp.sh
```

