#!/bin/bash

set -u

# need meson, ninja
check_env() {
  pip3 -V 
  if [ $? -eq 127 ]; then sudo apt install -y python3-pip
  fi

  ninja --version 1> /dev/null 2> /dev/null
  if [ $? -eq 127 ]; then sudo apt install -y  ninja-build
  fi

  local pkgVersion=1.3.0
  meson --version 1> /dev/null 2> /dev/null
  if [[ $? -eq 127 || `meson -v` != $pkgVersion ]]; then 
    # only v0.53 in ubuntu2004, not enough
    local pkgName=meson-$pkgVersion.tar.gz # 2.1 M
    if [ ! -f $pkgName ]; then wget --no-verbose \
      https://github.com/mesonbuild/meson/releases/download/$pkgVersion/$pkgName
    fi
    tar -xf $pkgName
    cd ${pkgName%.tar*}
    pip3 install ./
    cd ..
  fi
}

download_pkgs() {
  local pkgVersion=4.12.4
  local pkgName=gtk-$pkgVersion.tar.xz
  if [ ! -f $pkgName ]; then wget --no-verbose \
    https://download.gnome.org/sources/gtk/4.12/$pkgName
  fi

  tar -xJf $pkgName
  cd ${pkgName%.tar*}
  meson _build
  cd _build
  sudo ninja
  sudo ninja install
  cd ..
}

# ----- ----- ----- -----

# e.g 23.04
verLinux=$(lsb_release -r | awk '{print $2}')

# exist pkg in ubuntu22+
if [ ${verLinux%.*} -ge 22 ]; then sudo apt install -y \
  libgtk-4-1 libgtk-4-dev gtk-4-examples
  exit
fi

op=0
read -p "install gtk3? [Y/n] " op
case $op in 
  Y | y | 1) sudo apt install -y \
    libgtk-3-0 libgtk-3-dev gtk-3-examples
    exit;;
  *)
esac

check_env
echo "ninja $(ninja --version)"
echo "meson $(meson --version)"

op=0
read -p "build from source? [Y/n] " op
case $op in
  Y | y | 1) download_pkgs;;
  *)
esac

TODO

