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

config_debian() {
  # virtual keyboard module need hunspell lib
  sudo apt install -y \
    libhunspell-dev \
    libxcb-xfixes0-dev

  # skip qtlocation 避免 debian qtmapboxgl 找不到
  ./configure -opensource \
    -prefix $installdir \
    -confirm-license \
    -nomake tests \
    -skip qtlocation \
    -shared
}

addenv2path() {
  local cfg=$HOME/.bashrc
  local b=$installdir/bin

  [ $(grep -cn $b $cfg) -eq 0 ] &&
    echo "export PATH=\$PATH:$b" | sudo tee -a $cfg

  local pc=$installdir/lib/pkgconfig
  [ $(grep -cn $pc $cfg) -eq 0 ] &&
    echo "PKG_CONFIG_PATH=\$PKG_CONFIG_PATH:$pc" |\
      sudo tee -a $cfg

  \. $cfg
}

# ---------- ---------- ---------- ----------
if [ -d ~/Desktop ]; then cd ~/Desktop; else
  cd $HOME
fi

pkg-config --modversion Qt5Core
test $? -eq 0 && exit

check_tools
download_pkg

cd /usr/local/src/qt*
fix_bug
config_debian

make
sudo make install
addenv2path
