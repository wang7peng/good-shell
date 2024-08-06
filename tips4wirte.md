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


**TODO**
