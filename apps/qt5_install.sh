#!/bin/bash
set -u

# Desc: build qt5 with source (v5.9)
# platform: debian 12
#
# Note: 编译 qml 相关模块需要 python 
############################################

qt=5.9.9

installdir=/usr/local/etc/qt5
mirror=https://download.qt.io
# ---------- ---------- ---------- config ok

# QtQml module need python
check_tools() {
  gcc --version
  if [ $? -eq 127 ]; then echo "Abort."; exit 
  fi

  python --version 1> /dev/null
  if [ $? -eq 127 ]; then
    # need command python even if exist python3
    if [ -f /usr/bin/python3 ]; then
      sudo cp /usr/bin/python3 /usr/bin/python
    else
      echo "need python first. Abort."; exit
    fi
  fi
}
 
# default not access to dir /new_archive/, need vpn
download_pkg() {
  local v=$qt
  pkg=qt-everywhere-opensource-src-$v.tar.xz # 439M

  sudo wget --directory-prefix='/opt' -nc \
    $mirror/new_archive/qt/${v%.*}/$v/single/$pkg

  [ ! -d /usr/local/src/${pkg%.tar*} ] &&
    sudo tar -xJf /opt/$pkg -C /usr/local/src  
}

fix_bug() {
  # numeric_limits 
  local f=qtbase/src/corelib/tools/qbytearraymatcher.h
  if [[ `sed -n 44p $f` == "" ]]; then
    sed -i '44i\\#include <limits>' $f
  fi

  f=qtserialbus/src/plugins/canbus/socketcan/socketcanbackend.cpp
  if [[ `sed -n 52p $f` == "" ]]; then
    sed -i '52i\\#include <linux/sockios.h>' $f
  fi
}

# ---------- ---------- ---------- ----------
if [ -d ~/Desktop ]; then cd ~/Desktop; else
  cd $HOME
fi

check_tools
download_pkg

cd /usr/local/src/qt*
fix_bug

./configure -opensource \
  -prefix $installdir \
  -confirm-license \
  -shared

make
sudo make install

