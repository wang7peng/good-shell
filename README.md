# 搭环境脚本

![Ubuntu](https://img.shields.io/badge/Ubuntu-24.04+-E95420?style=social&logo=ubuntu&logoColor=E95420)
![Debian](https://img.shields.io/badge/Debian-12.6+-E95420?style=social&logo=debian&logoColor=red)

在通信软件开发公司工作半年（23.12-24.6），凝练出的搭环境相关的脚本集合。
主要是 x86 系列，不包含交叉编译。

## structure

组织结构

```
.
├── apps          存放独立的模块程序
├── language
├── openwrts
├── prere_*       使用各种发行版前先检查
├── sip-client    pjsip
├── sip-server    asterisk
├── ...
└── tips4write.md
```

openwrt 的编译都要花费数个小时，要有耐心。
`freepbx` 的安装有官方的脚本，不再自己写。

## Usage

存在调用其他脚本文件的情况（部分必备工具的安装用了单独脚本文件），
建议将整个 repo 都下载下来, 使用 `bash xxx.sh` 运行具体的脚本。

除了 `gcc` 和 `python3` 手动安装，其他工具都是脚本自动安装。
其中 `python3` 在 ubuntu 上默认安装为好了，还需要额外安装一些包。

``` sh
sudo apt install -y \
  python3-distutils python3-setuptools
```

虽然脚本里有使用工具前的检查, 还是推荐提前安装好一些命令, 因为可能有的在下载途中失败: 
`make`、`wget`、`tree`、`pkg-config`

脚本编写参考 [Tips for Writing Shell](tips4write.md)
