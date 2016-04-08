void io_hlt(void);//不用{}表明函数在其他文件中
void io_cli(void);
void io_out8(int port,int data);
int io_load_eflags(void);
void io_store_eflags(int eflags);

//写在同文件，在定义前使用也要先声明
void boxfill8(unsigned char *vram,int xsize,unsigned char c,int x0,int y0,int x1,int y1);
void init_palette(void);
void set_palette(int start,int end,unsigned char *rgb);

#define BLACK 		0;
#define	LIGHTRED	1;
#define LIGHTGREEN	2;
#define LIGHTYELLOW	3;
#define	LIGHTBLUE	4;
#define LIGHTPUPPLE 5;
#define	SLIGHTBLUE	6;
#define	WHITE		7;
#define	LIGHTGREY	8;
#define	DARKRED		9;
#define	DARKGREEN	10;
#define	DARKYELLOW	11;
#define	DARKGGREEN	12;
#define	DARKPUPPLE	13;
#define	SDARKBLUE	14;
#define	DARKGREY	15;

void HariMain(void)
{
	char *p;
	
	init_palette();				//设定调色板
	
	p=(char *)0xa0000;			//指定地址
	
	boxfill8(p,320,BLACK,20,20,120,120);
	boxfill8(p,320,LIGHTGREEN,20,20,120,120);
	boxfill8(p,320,LIGHTBLUE,20,20,120,120);
	for(;;){
		io_hlt();
		}
}
void boxfill8(unsigned char *vram,int xsize,unsigned char c,int x0,int y0,int x1,int y1){
	int x,y;
	for(y=y0;y<=y1;y++){
		for(x=x0;x<=x1;x++)
			vram[y*xsize+x]=c;
	}
	return;
}
void init_palette(void){
	static unsigned char table_rgb[16*3]={
		0x00,0x00,0x00,			//0:黑
		0xff,0x00,0x00,			//1:亮红
		0x00,0xff,0x00,			//2:亮绿
		0xff,0xff,0x00,			//3:亮黄
		0x00,0x00,0xff,			//4:亮蓝
		0xff,0x00,0xff,			//5:亮紫
		0x00,0xff,0xff,			//6:浅亮蓝
		0xff,0xff,0xff,			//7:白
		0xc6,0xc6,0xc6,			//8:亮灰
		0x84,0x00,0x00,			//9:暗红
		0x00,0x84,0x00,			//10:暗绿
		0x84,0x84,0x00,			//11:暗黄
		0x00,0x00,0x84,			//12:暗青
		0x84,0x00,0x84,			//13:暗紫
		0x00,0x84,0x84,			//14:浅暗蓝
		0x84,0x84,0x84			//15:暗灰
	};
	set_palette(0,15,table_rgb);
	return ;
	//C语言中的static char语句只能用于数据，相当于汇编中的DB指令
}
void set_palette(int start,int end,unsigned char*rgb){
		int i,eflags;
		eflags=io_load_eflags();	//记录中断许可标志的值
		io_cli();					//将中断许可标志置为0，禁止中断
		io_out8(0x03c8,start);
		for(i = start;i <= end; i++){
			io_out8(0x03c9,rgb[0] / 4);
			io_out8(0x03c9,rgb[1] / 4);
			io_out8(0x03c9,rgb[2] / 4);
			rgb += 3;
		}
		io_store_eflags(eflags);	//复原中断许可标志
		return;
}