#!/bin/bash

set -u

# 
# qt5 need prec2-16
#

# ----- ----- version config ----- -----
tag=10.44
repo=https://github.com/PCRE2Project/pcre2

download_repo() {
  local t=master
  [ $# -ge 1 ] && t=pcre2-$1

  cd /usr/local/src
  if [ ! -d pcre2 ]; then 
    git clone --branch $t --depth 1 \
      https://github.com/PCRE2Project/pcre2.git
  fi
}

install_pcre2() {
  local ver="10.42"
  [ $# -ge 1 ] && ver=$1

  local pkgDir="pcre2-$ver"
  local pkg=pcre2-$ver.tar.bz2

  sudo wget --no-verbose --directory-prefix='/opt' \
    --no-clobber $repo/releases/download/$pkgDir/$pkg # 1.8M

  if [ ! -d /usr/local/src/$pkgDir ]; then
    sudo tar -jxf /opt/$pkg -C /usr/local/src
  fi
  cd /usr/local/src/$pkgDir

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

#download_repo $tag
install_pcre2 $tag

# config
echo "export LD_LIBRARY_PATH=\$LD_LIBRARY_PATH:/usr/local/lib" >> ~/.bashrc
source ~/.bashrc

