#!/bin/bash

set -u

# ----- ----- version conf ----- -----
go='1.22.6'
######################################

# need tools to download and display, wget tree
function check_tools {
  # in debian
  if cat /proc/version | grep -q -E -i "debian|ubuntu"; then
    wget --version | head --lines=1  2> /dev/null
    [ $? -eq 127 ] && sudo apt install -y wget
    tree --version 1> /dev/null
    [ $? -eq 127 ] && sudo apt install -y tree

    return
  fi

  # in centos7
  sudo yum install -y wget tree
}

# download tar
# e.g wget -nc -P /opt go.dev/dl/xxx.tar.gz
function download_pkg {
  local v='go1.23.0'
  [ $# -eq 1 ] && v=$1

  local pkg=${v}.src.tar.gz
  if [[ `arch` == 'x86_64' ]]; then pkg=${v}.linux-amd64.tar.gz
  fi

  sudo wget --no-clobber --directory-prefix='/opt' \
    https://go.dev/dl/$pkg

  ls -h -og --color=auto /opt 
}

# tar pkg to solid path
# e.g tar -zxf xxx.tar.gz -C /usr/local/src
function tar2pos {
  local pos='/usr/local/etc'
  if [ $# -eq 1 ]; then pos=$1
  fi

  # check whether go dir exist or not in dst pos
  if [ -d $pos/go ]; then
    local oldver=`$pos/go/bin/go env GOVERSION`

    if [[ $oldver == go$go ]]; then
      echo "$oldver don't need update!"; return 0
    fi
  fi 

  sudo rm -rf $pos/go;
  sudo tar -xzf /opt/go$go.*.tar.gz -C $pos
  ls -h -og --color=auto $pos
}

# add a item value to PATH
function addenv2path {
  local confFile='/etc/profile.d/wangpeng.sh'
  [ ! -f $confFile ] && sudo touch $confFile
 
  if [ $(grep -cn 'go/bin' $confFile) -eq 0 ]; then
    echo "export PATH=\$PATH:$1" | sudo tee -a $confFile
    echo $PATH | tr ':' '\n'
  fi

  if [ $(echo $PATH | tr ':' '\n' | grep -c 'go/bin') -eq 0 ]; then
    # source /etc/profile
    \. /etc/profile
    echo "remember source /etc/profile, then run this script again!"
    exit 
  fi
}

# ----- ----- main ----- -----
if [ $# -ge 1 ]; then
  if [ $1 == "clean" ]; then sudo rm -r /opt/go$go*.tar.gz
  fi
  exit
fi

# step1 get tar
check_tools
download_pkg go$go # go1.23.0

# step2
tar2pos "/usr/local/etc"

# step3
addenv2path "/usr/local/etc/go/bin"

# step 4
go env -w GOPRIVATE=https://go.pfgit.cn
go env -w GOPROXY=https://proxy.golang.com.cn,direct
go env -w GO111MODULE=on
go env -w GOSUMDB=off

