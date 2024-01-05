#!/bin/bash

# Cause: need libiconv for maridab (sql module)
#

set -u

install_libiconv() {
  local pkgDir=libiconv-1.17
  if [ ! -d $pkgDir ]; then
    wget --no-verbose https://ftp.gnu.org/pub/gnu/libiconv/$pkgDir.tar.gz # 5.2M
    tar -zxf $pkgDir.tar.gz
  fi

  cd $pkgDir
  if [ $# -gt 0 ]; then sudo make distclean
  fi

  ./configure --prefix=/usr/local
  make
  sudo make install
  cd ..
}

install_gettext() {
  local pkgDir=gettext-0.22.4
  if [ ! -f $pkgDir ]; then
    wget --no-verbose https://ftp.gnu.org/pub/gnu/gettext/$pkgDir.tar.gz # 25M
    tar -zxf $pkgDir.tar.gz
  fi

  cd $pkgDir
  du -sh .
  if [ $# -gt 0 ]; then sudo make distclean
  fi

  ./configure --prefix=/usr/local
  make
  sudo make install
  cd ..
}

clear_src() {
  local dirName=$1
  if [ -f $dirName* ]; then
    sudo mv $dirName*.tar.gz /usr/local/src
  fi

  if [ -d $dirName* ]; then sudo rm -rf $dirName*
  fi
}

op=0
read -p "install from head? [Y/n] " op
case $op in
  Y | y | 1) install_libiconv; install_gettext
install_libiconv again;;
  *)
esac

clear_src gettext
clear_src libiconv
