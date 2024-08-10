#!/bin/bash

# TODO
# 弃用，朱工说 U-BOOT 是板子出厂自带的, 不需要再改
# ----- ----- ----- ----- ----- -----

set -u

# ----- ----- version conf ----- -----
buildroot='2024.08.1'
uboot='2024.10'

check_env() {
  # menuconfig need flex+bison
  flex --version
  if [ $? -eq 127 ]; then sudo apt install -y bison flex 
  fi
  bison --version | head --lines=1

  # buildroot dependencies
  sudo apt install -y ncurses-dev rsync
}

buildroot_comiple() {
  local v="2024.02.4" # lts
  [ $# -eq 1 ] && v=$1

  local pkg=buildroot-$v.tar.gz
  sudo wget -nc -P /opt \
    https://buildroot.org/downloads/$pkg
  if [ ! -d /usr/local/etc/buildroot-$v ]; then
    sudo tar -zxf /opt/$pkg -C /usr/local/src/
  fi

  cd /usr/local/src/${pkg%.tar*}
  make menuconfig
  make
}

download_pkg() {
  local verYM=$uboot
  local op=1
  read -p  "which uboot? 
	  1 u-boot-2018.09  # 12M
	  2 u-boot-2021.10  # 17M
	  3 u-boot-2024.10  # 25M
select (default $uboot) > " op

  case $op in 
    1) verYM="2018.09";;
    2) verYM="2021.10";;
    3) verYM="2024.10";;
    *)
  esac 

  pkg=u-boot-$verYM.tar.bz2
  sudo wget -nc -P /opt https://ftp.denx.de/pub/u-boot/$pkg
}

# ----- ----- main ----- -----
check_env

# step 1 get buildroot 
#
op=0
read -p "no buildroot? [Y/n] " op
case $op in
  Y | y | 1) buildroot_comiple $buildroot;; 
  *)
  # -g: not owner, -o: not group
  ls -og -h --color=auto \
    /usr/local/src/buildroot-$buildroot/output/host/bin
esac

# set up env of mips
export ARCH=mips
export CROSS_COMPILE=/usr/local/src/buildroot-$buildroot/output/host/bin/mipsel-linux-

# step 2 get u-boot
download_pkg

cd ~/Desktop
if [ ! -d u-boot-$verYM ]; then
  tar jxf /opt/$pkg -C .
fi

# step 3 configure
cd u-boot-$verYM
make menuconfig

export ARCH=mips
#export STAGING_DIR=$HOME/Desktop/openwrt-22.03.6/staging_dir/toolchain-mipsel_24kc_gcc-11.2.0_musl/
#export CROSS_COMPILE=$HOME/Desktop/openwrt-22.03.6/staging_dir/toolchain-mipsel_24kc_gcc-11.2.0_musl/bin/mipsel-openwrt-linux-

make 

cd ..
