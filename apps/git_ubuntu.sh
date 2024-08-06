#!/bin/bash
set -u

# Desc: install latest git
# Platform: ubuntu

git --version 2> /dev/null
[ $? -ne 127 ] && exit

sudo add-apt-repository ppa:git-core/ppa

sudo apt update 
sudo apt install -y git

sudo add-apt-repository -r ppa:git-core/ppa

