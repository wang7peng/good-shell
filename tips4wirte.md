## 脚本编写经验

有些工具，纯手工敲不用脚本也挺快的，直接 `wget`、`tar`、`ln -s` 一气呵成。例如安装 `go` 语言：

```shell
sudo wget https://go.dev/dl/go1.23.0.linux-amd64.tar.gz
sudo tar -C /usr/local/etc/ -zxf go1.2*
sudo ln -s /usr/local/etc/go/bin/* /usr/local/bin/
```

但是没有脚本去设置路径修改 `$PATH` 中规中矩。

想把函数输出给变量，尽量不用 return $ 这种写法, 他返回的值只能是 0-255 的整数（实质是状态码），在最后一行打 echo 更好。return 可以用来截断方法，可以在编写将阶段当作行塞测试。

语句执行后的状态码 `$?` ，命令不存在 `=127` (命令前带 `sudo` 的话还是 `=1` )，命令参数不存在 `=2`

查看版本信息，有的默认显示一大堆的话，可以用 `head -n` 提取某一行

- 用来检查 `app --version` 的存在很方便，但是此时不能用管道符。`app --version | head -n 1` 如果命令不存在时，这样写的 `$?` 也是 0。

- 比较简洁的写法
  ```shell
  app --version 
  [ $? -eq 127] && sudo apt install -y app
  ```
  这样可以避免 `if` 使用过多。同样的地方，`wget` 加上参数 `-nc` 可以不用再自己判断本地有没有已经下载的情况，如果已经下载，它会自己跳过。

`sudo echo "xxx" >> /x/file` 只在 root 用户或者 `sudo bash name.sh` 有用，不加 `sudo` 直接按普通用户 `bash name.sh` 运行就不行，要么 `sh -c` 将整体当作一个字符串命令执行；要么改成 `echo "xxx" | sudo tee -a /x/file`

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
grep ‘xxx’ filename

echo $PATH | tr ':' '\n' | grep xxx
``

grep 本身有 `-c` 选项去统计出现的行数，不使用 `grep xxx | wc -l` 多此一举。
它还有 `-n` 参数可以把找到的那些行显示出来，与 `if... ;then` 合理搭配，方便核实。

**TODO**
