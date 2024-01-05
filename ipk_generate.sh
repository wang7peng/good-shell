#!/bin/bash

# ----- ----- ----- ----- ----- -----
#  platform: ubuntu22 (with base tools)
#  Desc: ipk 软件包生成
#  Date: 2023.12.07
# 
#  在 openwrt 同级目录新建 wp_packages, 将项目存放进去
#  构建前需要在复制具体的项目到 ../openwrt/package/ 里
# ----- ----- ----- ----- ----- -----

set -u

# all proj put them in wp_packages
run_feeds() {
  # e.g. xxx/feeds update wp_packages
  ./scripts/feeds update $1
  ./scripts/feeds install -a -p $1
}

buildC() {
  local arr=(`echo "$@"`)
  for val in ${arr[*]}
  do
    # make 
    make package/$val/compile -j1 V=s
    make package/$val/clean -j1 V=s
  done
  echo "build ok"
}

# ----- ----- start ----- -----

pathProj=`pwd`
DirProj=`basename $pathProj`
echo "my projects all in: $pathProj"

# src openwrt and our proj have same level
cd ../openwrt-22.03.6

# create and check feeds.conf
if [ ! -f feeds.conf ]; then touch feeds.conf
fi
lineWrite="src-link $DirProj $pathProj"
if [[ `tail -n 1 feeds.conf` != $lineWrite ]]; then
  echo ${lineWrite} >> feeds.conf
fi

rm -rf feeds/wp_*
run_feeds $DirProj

make menuconfig

# ----- ----- start compile ----- -----

# add here
projMore=("example1" "example2" "example3" "hello_world")
buildC `echo ${projMore[*]}`

cd ..
