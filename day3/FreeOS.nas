;FreeOS-OS
;TAB=4


;有关BOOT_INFO
CYLS	EQU		0x0ff0		;设定启动区
LEDS	EQU		0x0ff1
VMODE	EQU		0x0ff2		;关于颜色数目的信息，颜色的位数
SCRNX	EQU		0x0ff4		;分辨率的X(screen x)
SCRNY	EQU		0x0ff6		;分辨率的Y(screen y)
VRAM	EQU		0x0ff8		;图像缓冲区的开始地址

		org		0xc200		;程序载入磁盘0x4200号地址，即内存0xc200号地址
		mov		AL,0x13		;VGA显卡，320*200*8位彩色
		mov		AH,0x00		;调用显卡BIOS的函数，切换显示模式
		int		0x10
		mov		byte[VMODE],8	;记录画面模式(c语言参照)
		mov		word[SCRNX],320
		mov		word[SCRNY],200
		mov		dword[VRAM],0x000a0000
		
;用BIOS取得键盘上各种LED指示灯的状态
		mov		AH,0x02
		int		0x16		;keyboard BIOS
		mov		[LEDS],AL
fin:
		hlt
		jmp		fin