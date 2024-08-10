# qianlueDev

![Ubuntu](https://img.shields.io/badge/Ubuntu-24.04+-E95420?style=social&logo=ubuntu&logoColor=E95420)
![Debian](https://img.shields.io/badge/Debian-12.6+-E95420?style=social&logo=debian&logoColor=red)


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
└── tips4wirte.md
```


## Usage

将文件下载下来, 使用 `bash xxx.sh` 即可。

除了 `gcc` 和 `python3` 手动安装，其他工具都是脚本自动安装。
其中 `python3` 在 ubuntu 上默认安装为好了，还需要额外安装一些包。

``` sh
sudo apt install -y \
  python3-distutils python3-setuptools
```

虽然脚本里有使用工具前的检查, 还是推荐提前安装好一些命令, 因为可能有的在下载途中失败: 
`make`、`wget`、`tree`、`pkg-config`

脚本编写参考 [Tips for Write](tips4wirte.md)
