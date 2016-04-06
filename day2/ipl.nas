

		org		0x7c00
		jmp 	entry
		
;以下记述用于标准FAT12格式软盘

		db		0x90
		db		"helloipl"
		dw		512
		DB		1				
		DW		1				
		DB		2				
		DW		224				
		DW		2880		
		DB		0xf0			
		DW		9				
		DW		18				
		DW		2				
		DD		0				
		DD		2880			
		DB		0,0,0x29		
		DD		0xffffffff		
		DB		"HELLO-OS   "	
		DB		"FAT12   "		
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
