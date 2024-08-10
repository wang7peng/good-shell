#!/bin/bash

set -u

#  platform: ubuntu16

# ----- ----- version conf ----- -----
pjproject='2.14.1'

pkg="pjproject-$pjproject.tar.gz"
# ----- ----- -----  ----- ----- -----

download_pkg() {
  pkg_tag=${pjproject}.tar.gz
  url=https://github.com/pjsip/pjproject/archive/refs/tags/$pkg_tag

  sudo wget -nc $url 
  sudo mv -i $pkg_tag /opt/$pkg

  if [ ! -d ${pkg%.tar*} ]; then
    sudo tar -zxf /opt/$pkg -C /usr/local/src
  fi
}

#download_pkg

sudo apt install -y libssl-dev # install openssl

cd /usr/local/src/${pkg%.tar*}

# detect alsa condition
#
if [ ! -f res-runconfigure.txt ]; then
  sudo touch res-runconfigure.txt
  sudo chmod 777 res-runconfigure.txt
fi

# param disable-video will not to build libyuv
sudo ./configure CFLAGS="-O3" --disable-video --disable-ssl \
    > res-runconfigure.txt

# cat xxx.txt | grep aaa | awk '{ print $NF }'
str_cond=`cat res-runconfigure.txt | grep alsa/version` 
if [ $(echo $str_cond | awk '{print $NF }') == "no" ]; then
  echo $str_cond
  sudo apt install -y libasound2-dev
else
  echo "yes"
fi

op=0
read -p "start make? [Y/n]" op
case $op in 
  1 | y | Y) sudo make dep
    ;;
  *) 
esac

sudo make
sudo make install
