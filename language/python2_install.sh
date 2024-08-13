#!/bin/bash
set -u

# Note: only install last one v2.7.18

installdir=/usr/local/etc/python2

check_tools() {
  if cat /proc/version | grep -q -E -i "debian|ubuntu"; then
    wget --version 1>/dev/null 2>&1
    [ $? -eq 127 ] && sudo apt install -y wget

    pkg-config --version 1> /dev/null
    [ $? -eq 127 ] && sudo apt install -y pkgconf

    return
  fi

  sudo yum install -y wget pkgconfig
}

download_pkg() {
  local pkg='Python-2.7.18.tgz'
  sudo wget -nc -P /opt \
    https://www.python.org/ftp/python/2.7.18/$pkg

  if [ ! -d /usr/local/src/Python-2.7.18 ]; then
    sudo tar -zxf /opt/$pkg -C /usr/local/src
  fi
}

# setpu location of bin/, lib/, pkgconfig/ 
addenv2path() {
  local cfg4lib=/etc/ld.so.conf.d/python2.conf
  [ ! -f $cfg4lib ] && sudo touch $cfg4lib
  if [ $(grep -c '$installdir/lib' $cfg4lib) -eq 0 ]; then
    echo "$installdir/lib" | sudo tee -a $cfg4lib
    sudo ldconfig
  fi

  local cfg4bin='/etc/profile.d/wangpeng.sh'
  [ ! -f $cfg4bin ] && sudo touch $cfg4bin

  if [ $(grep -cn '$installdir/bin' $cfg4bin) -eq 0 ]; then
    echo "export PATH=\$PATH:$installdir/bin" | \
      sudo tee -a $cfg4bin
    \. /etc/profile
  fi

  # pkg-config
  local pc=$installdir/lib/pkgconfig
  if [ $(grep -cn '$pc' ~/.bashrc) -eq 0 ]; then
    echo "export PKG_CONFIG_PATH=\$PKG_CONFIG_PATH:$pc" | \
      sudo tee -a ~/.bashrc
    \. ~/.bashrc
  fi

  echo "open a new terminal to run this script again!"
  exit
}

main() {
  check_tools
  download_pkg

  cd /usr/local/src/Python-2.7.18
  ./configure --prefix=$installdir \
    --build=x86_64-linux-gnu \
    --enable-optimizations \
    --enable-shared

  make -j4
  sudo make altinstall

  addenv2path
  # sudo ln -sfn '$installdir/bin/python2.7' /usr/bin/python2
  # sudo update-alternatives --config python
}

# ----- ----- ----- ----- ----- ----- -----
if [ $# -ge 1 ]; then
  if [ $1 == "clean" ]; then sudo rm -r /opt/Python*
  fi
  exit
fi

cd ~/Desktop

python2 -V 1> /dev/null
if [ $? -eq 127 ]; then
  pkg-config --cflags python2
  if (( $? == 0)) ; then
    echo "python2 is ok, just to restart system"
    exit
  fi
  main
fi

