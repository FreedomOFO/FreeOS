# FreeOS
###	关于
学着操作系统总觉得不动手做点什么敲点代码不踏实，遂买了《30天自制操作系统》，开始动手。
想记录一下制作过程，顺便熟悉github操作，于是乎有了这个代码仓库
### day1
第一天，就做了个简单的能在boot后，能用软驱启动所谓的“操作系统”的一个小程序（事实上这个操作系统还什么都没有），恩只能打印hello world，还不能自己结束关机。
先用的机器码后来又改用简单汇编命令db，dd，dw写的。
### day2
改为使用一些汇编命令如标签、mov、jmp、add、cmp、je，新增makefile辅助编译
### day3
启动区ipl.nas文件加入更多汇编命令，基本完善，开始载入操作系统，进入图形显示界面，暂时只能显示黑屏，开始加入一些C语言编写的内容
### day4
今天做的事情真是满满的成就感呢，超级开森！不光是黑屏白屏了，还试着做了各种简单图案！忍不住截图留恋啦！所以新增“效果”文件夹专门放截图！一开始的条纹图案其实就是用C语言的指针放入该地址和某个数的与运算来实现不同0、1排列形成条纹图案，不同的0,1排列方式会组成不同的图。后来又写了个调色板函数，只设定了15种颜色，用嵌套循环像画实心盒子一样给画面涂色。→_→果然还是对c比较熟点，吃得比较透……顺便通过书中作者想解释c语言某些语句时拿之前的汇编语句来类比，把前面一部分似懂非懂的汇编弄懂了……
### day5
今天把写的画图的函数充分利用上了，画了个丑丑的方块人，唔，还画了鼠标，和一个字库连接上了，可以打字了，丧病的用颜文字加抽方块人卖萌Orz→_→为了显示鼠标对内存分段和中断进行了简单设定。