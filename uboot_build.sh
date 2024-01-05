#!/bin/bash

# TODO
# 弃用，朱工说 U-BOOT 是板子出厂自带的, 不需要再改
# ----- ----- ----- ----- ----- -----

set -u

check_env() {
  # menuconfig need flex+bison
  flex --version
  if [ $? -eq 127 ]; then sudo apt install -y bison flex 
  fi
  bison --version | head --lines=1
}

buildroot_comiple() {
  # option: "2023.02.8"
  local verYM="2023.11"

  if [ ! -d buildroot-$verYM ]; then
    wget https://buildroot.org/downloads/buildroot-$verYM.tar.gz
    tar -xzf buildroot-$verYM.tar.gz
    rm buildroot-$verYM.tar.gz
  fi
  cd buildroot-$verYM

  make menuconfig
  make

  cd ..
}

# ----- ----- main ----- -----

check_env

# step 1 get buildroot 
#
op=0
read -p "no buildroot? [Y/n] " op
case $op in
  Y | y | 1) buildroot_comiple;; 
  *)
  # -g: not owner, -o: not group
  ls -og -h --color=auto \
    /home/wangpeng/Desktop/buildroot-2023.11/output/host/bin
esac 

# set up env of mips
export ARCH=mips
export CROSS_COMPILE=/home/wangpeng/Desktop/buildroot-2023.11/output/host/bin/mipsel-linux-

# step 2 get u-boot
verYM="2023.10"
op=1
read -p  "which uboot? 
          1 u-boot-2018.09  # 12M
	  2 u-boot-2023.10
	  3 u-boot-2024.01  # 19M
select (default 2023.10) > " op

case $op in 
  1) verYM="2018.09";;
  3) verYM="2024.01";;
  *)
esac 

if [ ! -f u-boot-$verYM.tar.bz2 ]; then
  wget https://ftp.denx.de/pub/u-boot/u-boot-$verYM.tar.bz2
fi

if [ ! -d u-boot-$verYM ]; then
  tar jxf u-boot-$verYM.tar.bz2
fi

cd u-boot-$verYM

make menuconfig

export ARCH=mips
#export STAGING_DIR=/home/wangpeng/Desktop/openwrt-22.03.6/staging_dir/toolchain-mipsel_24kc_gcc-11.2.0_musl/
#export CROSS_COMPILE=/home/wangpeng/Desktop/openwrt-22.03.6/staging_dir/toolchain-mipsel_24kc_gcc-11.2.0_musl/bin/mipsel-openwrt-linux-

make 

cd ..
