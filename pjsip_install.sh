#!/bin/bash

set -u

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
  if [ $? -eq 127 ]; then sudo apt install -y make
  fi

  # make -v | head -n 1
  local ver=$(make --version | head --lines=1 | awk '{print $3}')
  if [ ${ver%%.*} -lt 4 ]; then install_make
  fi  
}

# opus v1.4
install_opus() {
  if [ ! -f 'opus-1.4.tar.gz' ]; then
    wget --no-verbose --tries=1	-O 'opus.tar.gz' \
      https://downloads.xiph.org/releases/opus/opus-1.4.tar.gz # 1.1M
  else
    echo "pkg opus-1.4 have downloaded!"
  fi

  tar -xzf opus.tar.gz
  cd opus-1.4
  # 生成的两个目录 include 和 lib 直接和 /usr/local 下的合并
  # 如果单独存放到其他地方，需要额外设置环境变量
  ./configure --prefix=/usr/local/
  make
  sudo make install
  cd ..
}

# ----- ----- main ----- -----
check_env

dirSrc="pjproject-2.14"

op=0
read -p "add additional lib opus? [Y/n] " op
case $op in
  Y | y | 1) install_opus;;
  *)
esac 

# get pkg of pjsip
if [ ! -f ${dirSrc}.tar.gz ]; then
  wget --no-verbose --tries=2	-O pjproject-2.14.tar.gz \
    https://github.com/pjsip/pjproject/archive/refs/tags/2.14.tar.gz # 9.8M
else
  echo "pkg pjsip have download!"
fi

tar -zxf ${dirSrc}.tar.gz

cd $dirSrc
./configure --prefix=/usr/local/pjsip
make
sudo make install
cd ..

echo "install ok, clear yourself"
