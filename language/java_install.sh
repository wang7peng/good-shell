#!/bin/bash
set -u

java=21.0.5 # LTS 21
#--------------------------------
[ $# -eq 1 ] && java=$1

check_tool() {
  wget --version 1> /dev/null
  if [ $? -eq 127 ]; then 
    if cat /proc/version | grep -q -E -i "debian|ubuntu"; then
      sudo apt install -y wget
    else 
      sudo yum install -y wget
    fi
  fi
}

install_java() {
  local v=${java:0:2}
  if [ $v -lt 21 ]; then
    echo "version too old: $java, use default v21"
    v=21
  fi

  pkg=jdk-${v}_linux-x64_bin.deb # 160M
  url=https://download.oracle.com/java/$v/latest/$pkg

  check_tool
  sudo wget -nc -P /opt $url
  sudo dpkg --install /opt/$pkg
}

java --version 2> /dev/null 
if [ $? -eq 127 ]; then
  install_java
else
  vCurr=$(java --version | awk {'print $2'} | head -n 1)
  if [ ${vCurr//./} -lt ${java//./} ]; then 
    op=0
    read -p "update java -> $java? (default not) [Y/n] " op
    case $op in
      Y | y | 1) install_java ;;
      *) echo "not update"; exit
    esac
  fi
fi

