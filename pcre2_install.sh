#!/bin/bash

set -u

# 
# qt5 need prec2-16
#

install_pcre2() {
  cd /usr/local/src

  local ver="10.42"
  local pkgDir="pcre2-$ver"
  if [ ! -f $pkgDir.tar.bz2 ]; then sudo wget --no-verbose \
	  https://github.com/PCRE2Project/pcre2/releases/download/$pkgDir/$pkgDir.tar.bz2 # 1.8M
  fi
  sudo tar -jxf $pkgDir.tar.bz2

  cd $pkgDir

  # default only have pcre2-8
  sudo ./configure \
	  --enable-pcre2-16 --enable-pcre2-32 \
	  --enable-jit=auto \
	  --enable-pcre2grep-libz \
	  --enable-valgrind

  sudo make
  sudo make check
  sudo make install
  cd ..

  sudo rm -rf $pkgDir
}


# ----- ----- main ----- -----
sudo apt install -y gawk
sudo apt install -y valgrind # check memory tool

pos=`pwd`
install_pcre2
cd $pos

# config
echo "export LD_LIBRARY_PATH=\$LD_LIBRARY_PATH:/usr/local/lib" >> ~/.bashrc
source ~/.bashrc

