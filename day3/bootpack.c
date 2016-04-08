void io_hlt(void);//不用{}表明函数在其他文件中
void HariMain(void)
{
fin:
	io_hlt();
	goto fin;
}