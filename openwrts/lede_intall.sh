#!/bin/bash

set -u

# Desc: compile lede from repo
# Platform: ubuntu

check_env() {
  install_gnu

  cmake -version 2> /dev/null
  [ $? -eq 127 ] && sudo apt install -y cmake

  # 合起来只用一个 apt 显示读取软件包列表的提示更简洁
  # note1 一开始不装 swig 也通过验证, 在后期 make 的时候才被检测到, 不装不行
  sudo apt install -y tree gawk swig \
    libncurses5-dev libz-dev

  bash ../language/python2_install.sh

  # python3 relate
  # python3-dev exists <Python.h>
  sudo apt install -y python-dev python3-dev \
    python3-distutils python-setuptools
  sudo apt autoremove -y
}

# gnu: gcc g++, default v13.2 in ubuntu2404
install_gnu() {
  # ignore the prompt (fatal error: not input files)
  gcc 2> /dev/null
  if [ $? -eq 127 ]; then
    local op=0
    read -p "no C/C++ env yet, install them by default? [Y/n] " op
    case $op in
      Y | y | 1) sudo apt install -y gcc g++ ;;
      * ) echo "Abort."; exit
    esac
  fi

  gcc --version | head -n 1
}

# v23.6+
download_lede() {
  local op=0
  if [ -d lede ]; then
    read -p "lede repo have exist, need download it again? [Y/n] " op
    case $op in 
      Y | y | 1) sudo rm -rf lede ;; 
      *) return
    esac
  fi

  # 85M 不一定能 clone 下来
  sudo git clone --depth 1 -b $tag https://github.com/coolsnowwolf/lede.git
  sudo chmod 777 lede
}

# add new lib in openwrt (insert link in the first row)
update_lede() {
  local op=0
  local content="libqt"
  # qt env
  read -p "add qt5? [Y/n] " op
  case $op in
    Y | y | 1) content=`head --lines=1 feeds.conf.* | awk '{print $2}'`
    # 在首行插入 libqt 的连接
      if [ $content == 'libqt' ]; then
        echo "libqt ok"
      else
        sed -i '1 i src-git libqt https://github.com/qianlue123/qt5-openwrt.git' feeds.conf.default
      fi;;
    *)
  esac

  ./scripts/feeds update -a
  ./scripts/feeds install -a
}

# ----- -----  main()  ----- -----

check_env

# step 1 select special version
tag="20230609"
op=1
read -p  "which version?
  [1] 20230609  [2] 20221001  [3] 20211107
  [n] cancel
select (default $tag) > " op
case $op in 
  n) echo "not installed"; exit;;
  3) tag="20211107";;
  2) tag="20221001";;
  *) tag="20230609"
esac

# step 2 download_lede 20230609
download_lede $tag

cd lede
# step 3 update packages
update_lede

# step 4 config it with a UI menu
make menuconfig

# step 5 download them and make
make download -j1

op=0
read -p "start make -jx? [Y/n] " op 
case $op in
  # must to set up thread (-j1), otherwise this script will stuck.
  Y | y | 1) make -j1 V=s;;
  2) make -j2;;
  *) echo "config ok, you can make now!"
esac

cd ..
# step last, check
numbers_pkg=`ls lede/dl/ | wc -l`
# after build, total 173 packages will show up in this dl directory
if [ $numbers_pkg -ge 173 ]; then echo "build ok!"
else
  echo "build failure, pkgs in dl/: $numbers_pkg"
fi

tree -C -sh -L 2 lede/bin/targets/x86
