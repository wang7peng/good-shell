#!/bin/bash

# ----- ----- ----- ----- ----- -----
#  platform: ubuntu22 (with base tools)
#  Desc: openwrt2203 + mt7621 
#
#  Note: v22.03.7 is EOL of v22.03
# ----- ----- ----- ----- ----- -----

set -u

# ----- ----- version conf ----- -----
ver='22.03.7'
######################################

update_env() {
  local op=0
  read -p "update env again? [Y/n] " op 
  case $op in
    Y | y | 1)
     ./scripts/feeds update -a
     ./scripts/feeds install -a
     if [ $? -ne 0 ]; then exit;
     fi
     ;;
    *)
  esac
}

check_sys() {
  # cat /proc/version | grep -q -i "ubuntu"
  grep -i ubuntu --silent /proc/version
  if [ $? -eq 0 ]; then echo "ubuntu"
  else echo "unknown"
  fi
}

config_git() {
  git config --global http.postBuffer 524288000
  git config --global http.lowSpeedLimit 1000
  git config --global http.lowSpeedTime 600
}

# get tar.gz (7.7M) from github
download_pkg() {
  local v=22.03.7
  local pkgName=openwrt-$v.tar.gz

  sudo wget -nc -O /opt/$pkgName \
    https://github.com/openwrt/openwrt/archive/refs/tags/v$v.tar.gz

  # tar -> /usr/local/src/openwrt-22.03.7
  if [ ! -d /usr/local/src/${pkgName%.tar*} ]; then
    sudo tar -zxf /opt/$pkgName -C /usr/local/src
  fi
}

# ----- ----- main ----- -----
config_git

op=0
read -p "Let's compile openwrt in `check_sys`? [Y/n] " op
case $op in
  Y | y | 1) ;;
  *) exit
esac


# download
download_pkg $ver

# get official conf file with special version
wget -nc --no-verbose -O $ver.config \
	https://downloads.openwrt.org/releases/$ver/targets/ramips/mt7621/config.buildinfo

if [ $? -eq 8 ]; then rm $ver.config; exit
else
  checkit=`sha256sum $ver.config`
  [ ${checkit:0:6} != "5a959a" ] && exit
fi
dirSrc=/usr/local/src/openwrt-$ver

op=0
read -p "official conf $ver have get! use it? [Y/n] " op 
case $op in
  Y | y | 1) sudo cp $ver.config $dirSrc/.config;;
  *)
esac

# into dir of source
cd $dirSrc
update_env

make menuconfig

op=0
read -p "make download -j1? [Y/n] " op 
case $op in
  Y | y | 1) make download -j1 V=s
    echo $?
    ;;
  *)
esac

op=0
read -p "start make -jx? [Y/n] " op 
case $op in
  Y | y | 1) make -j1 V=s;;
  2) make -j2;;
  *) echo "config ok, you can make now!"
esac

cd ..
