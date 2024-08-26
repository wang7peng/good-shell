一些第三库绑定的，在 `configure` 的时候会去检测下载，
`--with-xxx` 系列参数可以控制是用项目自带的第三方库还是用自己手动安装好了的。
（自己手动的都装在 `/usr/local/etc/xxx` ）

如果想用项目自带的，需要 `./configure -h` 看看，有的默认是 yes （pjproject），有的默认是 no (jansson)

如果系统中没有，它会自动将安装包下载好了存放到 `/tmp` 目录。
在脚本里专门用 `wget` 下载是没有意义的，
因为像含有 `raw.githubusercontent.xxx` 这种链接肯定下载失败。

**方法** 只能先跑一遍，把错误提示中的下载地址复制到 windows 浏览器，然后翻墙下载。再上传到 `tmp` 目录（xshell连接使用 `rz`）。
再次跑脚本，它在 `./configure` 的时候检测到了就不会去下载。

**库介绍**

speex 有消除回音的功能，必须安装
