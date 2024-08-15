#!/bin/bash
set -u

# ----- ----- config ----- -----
py=3.14.0

installdir=/usr/local/etc/python3
# ------------------------------

# only used in centos | sangoma
check_sys() {
  local n=`uname --nodename`
  [ $(echo $n | grep -i 'Sangoma') ] && return

  local txt=/proc/version
  if cat $txt |  grep -q -E -i "red hat"; then return
  fi

  echo "$(uname --nodename) can not use this script."
  exit  
}

download_pkg() {
  local v=3.14.0
  [ $# -eq 1 ] && v=$1

  local pkg=Python-$v.tar.xz
  sudo wget -nc -P /opt \
    https://www.python.org/ftp/python/$v/$pkg

  if [ ! -d /usr/loca/src/${pkg%.tar*} ]; then
    sudo tar -xf /opt/$pkg -C /usr/local/src
  fi
}

config_py() {
  yum install -y \
    zlib-devel bzip2-devel ncurses-devel \
    openssl-devel sqlite readline-devel tk-devel

  ./configure --prefix=$installdir \
    --enable-shared \
    --with-ssl
}

addenv2path() {
  if [ $(grep -c '$installdir/lib' ~/.bashrc) -eq 0 ]; then
    echo "export LD_LIBRARY_PATH=\$LD_LIBRARY_PATH:=$installdir/lib" |\
      tee -a ~/.bashrc
  fi
  \. ~/.bashrc

  sudo ln -s $installdir/bin/python${py:0:4} /usr/bin/python3 
  sudo ln -s $installdir/bin/pip${py:0:4} /usr/bin/pip3
}

python3 --version 1>/dev/null 2>&1
if [ $? -ne 127 ]; then
  verMid=$(python3 --version | tr '.' ' ' | awk '{print $3}')
  [ $verMid -ge 12 ] && exit
fi 
check_sys

# ---------- ----------
pos=`pwd`

download_pkg $py
cd /usr/local/src/Python-3*

config_py
make
sudo make install
addenv2path

cd $pos

