#!/bin/bash

set -u

# ----- ----- ----- ----- ----- -----
#  platform: centos7 (with base tools)
#  Desc: 安装完 freepbx.iso 后增加设置
#        root运行
#  Date: 2023.12.28
# ----- ----- ----- ----- ----- -----

replace_gcc() {
  local infoGCC=$(gcc --version | head --lines=1 | awk '{print $3}')
  local verMax=${infoGCC%%.*}
  if [ $verMax -gt 9 ]; then 
    gcc --version | head --lines=1; return 0; 
  fi

  local op=0
  read -p "start update gcc? [Y/n] " op
  case $op in
    Y | y | 1) ;;
    *) return 0;
  esac

  yum install -y centos-release-scl
  yum install -y devtoolset-11-binutils devtoolset-11-gcc* 
  scl enable devtoolset-11 bash

  source /opt/rh/devtoolset-11/enable
  echo "source /opt/rh/devtoolset-11/enable" >> /etc/profile

  rm -rf /usr/bin/gcc /usr/bin/g++
  ln -s /opt/rh/devtoolset-11/root/bin/gcc /usr/bin/gcc
  ln -s /opt/rh/devtoolset-11/root/bin/g++ /usr/bin/g++

  echo "please source /etc/profile , then run this script again!"
  exit
}

install_git() {
  git -v 2> /dev/null
  if [ $? -ne 127 ]; then return 0; fi

  cd /opt
  local pkgName=git-2.43.0.tar.gz
  if [ ! -f $pkgName ]; then wget --no-verbose \
    https://mirrors.edge.kernel.org/pub/software/scm/git/$pkgName
  fi
  # 安装 openssl 时会顺带自动安装 zlib-devel 等其他依赖库
  yum -y install curl-devel expat-devel openssl-devel 
  tar -C /usr/local/src -zxvf git-2.4*
  cd /usr/local/src/git-2.4*
  make
  make install 
}

install_go() {
  go version 2> /dev/null
  if [ $? -ne 127 ]; then return 0; fi

  cd /opt
  local pkgName=go1.21.5.linux-amd64.tar.gz
  if [ ! -f $pkgName ]; then
    wget --no-verbose https://go.dev/dl/$pkgName
  fi
  rm -rf /usr/local/etc/go
  tar -C /usr/local/etc -xzf go1.21* 

  echo 'export PATH=$PATH:/usr/local/etc/go/bin' >> /etc/profile
  echo "remember source /etc/profile, then run this script again!"
  exit
}

# ----- ----- main ----- -----
sudo yum install -y lrzsz

replace_gcc

install_git

git config --global user.name "wangpeng"
git config --global user.email "18795975517@163.com"
git config --global http.sslVerify "false"
git config --global core.autocrlf input

install_go

go env -w GOPRIVATE=https://go.pfgit.cn
go env -w GOPROXY=https://proxy.golang.com.cn,direct
go env -w GO111MODULE=on
go env -w GOSUMDB=off
