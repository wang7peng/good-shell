#!/bin/bash

set -u

if cat /proc/version | grep -q -E -i "debian|ubuntu"; then
  echo "Only used in CentOS."; exit
fi

install_unixodbc() {
  odbcinst --version
  if [ $? -eq 0 ]; then return 0
  fi

  local pkgName=unixODBC-2.3.12.tar.gz
  if [ ! -f $pkgName ]; then wget --no-verbose \
    https://www.unixodbc.org/$pkgName
  fi
  tar -zxf $pkgName
  cd ${pkgName%.tar*}
  ./configure
  make 
  sudo make install
  sudo ldconfig
  cd ..
}

check_env() {
  sudo yum -y update
  sudo yum -y install epel-release
  sudo yum -y install vim wget dnf python-pip

  # update_python3, default v3.6 not enough
  bash ../language/python3_centos.sh

  # pip only support py2 before v21.0
  sudo pip3 install --upgrade pip
  sudo pip3 install alembic ansible
}

# ----- ----- ----- -----

check_env

install_unixodbc
sudo yum install -y mysql-connector-odbc

sudo rm -rf /etc/ansible&&
sudo mkdir /etc/ansible
sudo chown wangpeng:wangpeng /etc/ansible

#sudo rm -rf /etc/ansible/hosts
sudo echo "[starfish]" >> /etc/ansible/hosts
sudo echo "localhost ansible_connection=local" >> /etc/ansible/hosts

mkdir -p ~/ansible/playbooks

op=0
read -p "have starfish.yml? [Y/n] " op
case $op in
  Y | y | 1) ;;
  *) exit
esac

cp starfish.yml ~/ansible/playbooks/starfish.yml

ansible-playbook ~/ansible/playbooks/starfish.yml
# 出现 bug
