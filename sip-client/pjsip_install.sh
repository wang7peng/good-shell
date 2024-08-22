#!/bin/bash

set -u

#  platform: ubuntu22

# ----- ----- version conf ----- -----
pjproject='2.14.1'
opus='1.4'

pkg=pjproject-${pjproject}.tar.gz # 9.8M
pkg_opus=opus-$opus.tar.gz        # 1M
# ----- ----- -----  ----- ----- -----

# install latest gnu make
install_make() {
  if [ ! -f make.tar.gz ]; then
    wget --no-verbose --tries=1	-O 'make.tar.gz' \
      https://ftp.gnu.org/gnu/make/make-4.4.1.tar.gz # 2.2M
  fi
  tar -zxf make.tar.gz
  cd make-*
  ./configure
  make
  sudo make install
  make -v
}

check_env() {
  sudo apt-get install -y libasound2-dev
  sudo apt install -y libssl-dev libgl-dev

  # check gnu C
  gcc 2> /dev/null
  if [ $? -eq 127 ];then sudo apt install -y gcc g++
  fi
  gcc --version | head -n 1

  # check gnu make
  make -v 1> /dev/null 2> /dev/null
  [ $? -eq 127 ] && sudo apt install -y make

  # make -v | head -n 1
  local ver=$(make --version | head --lines=1 | awk '{print $3}')
  if [ ${ver%%.*} -lt 4 ]; then install_make
  fi  
}

# opus 源码编译
# 安装完成会在源码总目录产生 opus_demo, 没有额外bin目录
install_opus() {
  local url=https://downloads.xiph.org/releases/opus/$pkg_opus

  # 不能在终端直接使用 opus_demo 命令, 因为没有自动装到 /xxx/bin
  local c=`sudo find /usr/local -name opus_demo | wc -l`
  [ $c -gt 0 ] && return 0

  sudo wget --directory-prefix='/opt' --no-verbose -nc \
    $url

  sudo rm -rf /usr/local/src/opus-$opus
  sudo tar -xzf /opt/$pkg_opus -C /usr/local/src

  cd /usr/local/src/opus-$opus
  # 生成的两个目录 include 和 lib 直接和 /usr/local 下的合并
  # 如果单独存放到其他地方，需要额外设置环境变量
  ./configure --prefix=/usr/local/
  make
  sudo make install
}

# get pkg or repo of pjsip
#
download_pj() {
  local url=https://github.com/pjsip/pjproject
  if [ $1 == 'repo' ]; then
    cd /usr/local/src
    sudo git clone --depth 1 -b ${pjproject} ${url}.git
    return
  fi

  # wget -nc 已存在文件不下载, 只要包名中含有对应版本号, 不用担心新旧包重名
  sudo wget --no-clobber -O /opt/$pkg \
    ${url}/archive/refs/tags/${pjproject}.tar.gz
  ls -h -og --color=auto /opt

  if [ ! -d /usr/local/src/${pjproject%.tar*} ]; then
    sudo tar -zxf /opt/$pkg -C /usr/local/src
  fi
}

config_pj() {
  loc=`pwd`
  install_opus # must
  cd $loc

  ./configure --prefix=/usr/local/etc/pjsip \
    --disable-speex-aec \
    --disable-gsm-codec \
    --disable-speex-codec \
    --with-sdl=/usr/local/etc/sdl
}

# ----- ----- main ----- -----
check_env

#step1 download
download_pj 'pkg'

#step2 configure
cd /usr/local/src/pjproject*
sudo chmod -R 777 .
config_pj

#step3 build
sudo make dep
sudo make

sudo make install
echo "install ok, clear yourself"
