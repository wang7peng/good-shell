#!/bin/bash
set -u

# Desc: 源码安装最新版 git
#
# Note: ppa只能在 ubuntu 环境用，不能用在 debian
#       git config --global 设置手动，不写在这里

git=2.46.0

installdir=/usr/local/etc/git
# ---------- ---------- ---------- ----------

check_tools() {
  sudo apt install -y wget make autoconf

  cc --version
  [ $? -eq 127 ] && sudo apt install -y gcc g++
}

check_env() {
  # git-gui 子模块有 de.msg, 需要 gettext
  sudo apt install -y gettext \
    libexpat1-dev libssl-dev libz-dev
}

download_repo() {
  local v=2.46.0
  [ $# -eq 1 ] && v=$1

  sudo wget --directory-prefix='/opt' -nc \
    https://github.com/git/git/archive/v$v.tar.gz

  if [ ! -d /usr/local/src/git-$v ]; then
    sudo tar -zxf /opt/v$v* -C /usr/local/src
  fi
  sudo chmod -R 777 /usr/local/src/git-$v
}

# bin 目录命令较多, 直接增加到 PATH 更好
add2path() {
  # 不能直接 ~/.bashrc 要把 ~ 换掉
  local cfg=$HOME/.bashrc
  # 查找的子串要么加双引号，要么不加，不能用单引号
  if [ $(grep -c "$1" $cfg) -eq 0 ]; then
    echo "export PATH=\$PATH:$1" | sudo tee -a $cfg
  fi
  \. $cfg

  [ -f /usr/bin/git ] && sudo apt remove -y git
}

main() {
  download_repo $git

  cd /usr/local/src/git-$git
  check_env
  make configure
  ./configure --prefix=$installdir

  # 忽略编译文档网页等杂项
  make -j`nproc`
  sudo make install
  add2path $install/bin
}

# ---------- ---------- ----------
[ $# -eq 1 ] &&  git=$1

git --version
if [ $? -ne 127 ]; then
  vCurr=`git --version | awk '{print $3}'`
  # 将版本中的小数点去除，当作纯数字比大小
  [ ${vCurr//./} -ge ${git//./} ] && exit 

  op=0
  read -p "update git -> $git? (default not) [Y/n] " op
  case $op in
    Y | y | 1) ;;
    *) exit
  esac
fi

op=0
# default v2.39 in debian 12
read -p "install git$git quickly with apt? [y/N] " op
case $op in
  Y | y | 1) sudo apt install -y git ;;
  c | e | s) echo "Abort."; exit ;;
  *) check_tools; 
     main
esac

