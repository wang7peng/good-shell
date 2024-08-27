# 脚本编写经验

有些工具，纯手工敲不用脚本也挺快的，有些编译好了的包直接 `wget`、`tar`、`ln -s` 一气呵成。
例如安装 `go` 语言：

```shell
cd ~/Desk*
wget https://go.dev/dl/go1.23.0.linux-amd64.tar.gz
sudo tar -C /usr/local/etc/ -zxf go1.2*
sudo ln -s /usr/local/etc/go/bin/* /usr/local/bin/
```

需要下载准备环境编译的，有 `cmake`、`meson` 提供的快捷参数也很快。而且利用星号自动识别，少写了不少字母。

但是在安装包比较灵活的时候，`configure --?` 的选项控制太多记不住。
而且没有脚本去设置路径修改 `$PATH` 中规中矩。

`wget` 加上参数 `-nc` 可以不用再自己判断本地有没有已经下载的情况，如果已经下载，它会自己跳过。

想把函数输出给变量，尽量不用 return $ 这种写法, 他返回的值只能是 0-255 的整数（实质是状态码），在最后一行打 echo 更好。return 可以用来截断方法，可以在编写将阶段当作行塞测试。

语句执行后的状态码 `$?` ，命令不存在 `=127` (命令前带 `sudo` 的话还是 `=1` )，命令参数不存在 `=2`

## 权限问题

**运行脚本不加 `sudo`** 直接以当前普通用户运行脚本，`bash xxx.sh` 或者 `./xxx.sh`。

脚本最好放在用户 “够得着” 的地方，推荐是桌面。但是在脚本里不要直接写 `cd ~/Desktop`，
因为如果在安装 linux 时选的装中文环境，那么此时没有 `Desktop`，只能 `cd ~/桌面`。
但是在路径含有中文的情形下，有时 python、qt 可能编译不过去。

```shell
if test -d ~/Desktop; then cd ~/Desktop; else
  cd ~ # cd $HOME
fi

pos=`pwd`
# ...
cd $pos
```

对于 `/opt`、`/usr/local/src/` 等很多目录，普通用户是不允许直接读写（只能 `ls` 访问），需要加 `sudo`。

``` shell
sudo ./configure --prefix=/usr/local/etc/xxx
make
sudo make install # 必须加
```

- 有时 `sudo app` 会提示找不到命令，但是先 `su root` 进入 root 用户状态再 `app ` 有起作用。
是因为加了 prefix , 没有安装在几个默认的路径（你像用 `apt` 安装的程序在这三种情形就都起作用）。
要么修改 `/etc/sudoers` 里面的变量，要么 `sudo env PATH=$PATH app ...` 。

### 版本号调取

安装的可执行程序都会提供参数让用户知道版本号，可以是 `app -v` 或者 `app -V` 以便查看更新。
有的库安装后没有 `bin`，但是一定会有 `pkgconfig` 目录。如果安装成功，可以利用 `pkg-config --modversion sdl` 查看。

**判断工具是否存在** 用  `app --version` 配合 `$?` 很方便。
在执行到核心步骤前先确认某些工具有没有，或者检查当前安装工具的版本新不新。
比较简洁的写法
``` shell
appA --version 
[ $? -eq 127] && sudo apt install -y appA

appB --version 1> /dev/null
test $? -eq 127 && sudo apt install -y appB
```

这样可以避免 `if` 使用过多。
- 但是此时不能用管道符。比如 `app --version | head -n 1` 即使此时命令不存在，`$?` 也是 0。

**只留有效信息**
shell运行时，应该尽量保持输出的信息简洁明了。
全的工具用 `app -v` 会显示一大堆的话，作者介绍、时间等（如 `cmake`, `wget -V`），可以配合 head 命令提取某一行

``` shell
app --version | head -n 1
app --version | head -1 
```

一般会在前两行提供版本信息。如果只像得到 `1.2.3` 这样的版本数字，还需要进一步配合 `awk` 命令进行字符串截取。

- gcc 额外提供了 `gcc -dumpfullversion` 

**版本号比较**
比如用户打算安装 `14.2.0`, 本地已经安装的是 `12.4.0`。
一种方法是设置 3 个变量 `{vMax, vMid, vMin}` 以此比较，
还有一种更好的，就是利用字符串替换的操作，`${v//./}` 这样方便当作两个大点的整数 1420 和 1240 进行比较。

### 数据库

`mysql -Ne "xxx;"` 去掉显示表格式的头行，必须先 `-N` 再 `-e`


### 环境问题

**更新路径变量**
安装完成后需要让命令能随处可用，可以用软链接，也可以更新路径变量。
最好先看一下新产生的 bin 目录，如果产生的命令少（如 `ffmpeg` 只有两个），就直接 `ln -s` ，
如果有很多新命令，就用 `export PATH=$PATH:xxx/bin` 方法。
这样可以避免 `/usr/local/bin` 内容较多，影响感观。不然过一段时间后，不知道这些东西怎么来的了。

```shell
# e.g 将这个 bin 目录加入到 $PATH
local b=/usr/local/etc/go/bin

# way1
echo 'export PATH=\$PATH:$b' >> /etc/profile

# way2 推荐
echo 'export PATH=\$PATH:$b' | sudo tee -a /etc/profile
echo 'export PATH=\$PATH:$b' | sudo tee -a ~/.bashrc

\. ~/.bashrc
```

语句 echo 部分的格式差不多，写法推荐第二个，后面存放的文件位置可换。

> `sudo echo "xxx" >> /x/file` 只在 root 用户或者 `sudo bash name.sh` 有用，不加 `sudo` 直接按普通用户 `bash name.sh` 运行就不行，要么 `sh -c` 将整体当作一个字符串命令执行；要么改成 `echo "xxx" | sudo tee -a /x/file`

路径变量 PATH 的更新位置有多个，可以是 `.bashrc`, `/etc/profile` 或者 `/etc/profile.d/` 子目录。
推荐 `.bashrc`。
如果写在 `profile` 相关的地方, 还需要重启系统，不然每次新开 terminal 都会失效。
因为使用 `. /etc/profile` 只在当前环境生效，新开一个终端就没有用了。
（关闭当前 terminal 或者退出脚本都会失效）只有重启系统才永久有效。

> **Warn** 中间的一个 `PATH` 前面要加上 `\$` ，不然最后在配置脚本中会将内容展开。
在脚本里面 . 要起和 source 相同的作用，也需要在前面加上 `\`

多次执行脚本，就需要防止重复将 `export` 语句写入。
可以用 `grep` 查找配置脚本中的内容，或者直接看变量的

```shell
grep 'xxx' filename

echo $PATH | tr ':' '\n' | grep xxx
```

grep 本身有 `-c` 选项去统计出现的行数，不使用 `grep xxx | wc -l` 多此一举。
它还有 `-n` 参数可以把找到的那些行显示出来，与 `if... ;then` 合理搭配，方便核实。

**TODO**
