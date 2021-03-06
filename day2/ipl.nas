

		org		0x7c00
		jmp 	entry
		
;以下记述用于标准FAT12格式软盘

		db		0x90
		db		"HelloIPL"	;启动区名称（8字节）
		dw 		512			;扇区（sector）大小（必须为512字节）
		db 		1 			;簇（cluster）的大小（必须为1个扇区）
		dw 		1			;FAT的起始位置（一般从第一个扇区开始）
		db 		2			;FAT的个数（必须为2）
		dw 		224			;根目录的大小（一般设置为224项）
		dw 		2880		;该磁盘的大小（必须为2880扇区）
		db		0xf0		;磁盘种类（必须为0xf0）
		dw		9			;FAT的长度（必须为9扇区）
		dw		18			;1个磁道
		dw		2			;磁头数（必须是2）
		dd		0			;不使用分区，必须是0
		dd		2880		;重写一次磁盘大小
		db		0,0,0x29	;意义不明，固定
		dd		0xffffffff	;可能为卷标号码		
		DB		"FREE-OS    "	;磁盘名称（11字节）	
		DB		"FAT12   "		;磁盘格式名称（8字节）	
		RESB	18				
		
;程序核心

entry:
		mov		AX,0		;初始化寄存器
		mov		SS,AX
		mov		SP,0x7c00
		mov		DS,AX
		mov		ES,AX
		
		mov		SI,msg
putloop:
		mov		AL,[SI]
		add		si,1		;给si+1
		cmp		AL,0
		je		fin
		mov		AH,0x0e		;显示一个文字
		mov		BX,15		;指定字符颜色
		int		0x10		;调用显卡BIOS
		jmp		putloop
fin:
		hlt					;让cpu停止，等待指令
		jmp 	fin
		
msg:	
		db		0x0a,0x0a	;换行两次
		db		"hello,FREE "
		db		0x0a
		db		0
		
		RESB	0x7dfe-$
		
		DB		0x55, 0xaa
