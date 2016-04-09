;FreeOS-IPL
;TAB=4

CYLS	equ	10
		
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

;读取磁盘
	
		mov		AX,0x0820
		mov		ES,AX
		mov		CH,0		;柱面0
		mov		DH,0		;磁头0
		mov		CL,2 		;扇区2
readloop:
		mov		SI,0		;记录失败次数的寄存器
retry:
		mov		AH,0x02		;AH=0x02:读入磁盘
		mov		AL,1 		;1个扇区
		mov		BX,0		
		mov		DL,0x00		;A驱动器
		int		0x13		;调用磁盘BIOS
		jnc		next		;没出错的话跳转到next
		add		si,1		;往si加1
		cmp		si,5 		;比较si和5
		jae		error		;si>=5时，跳转到error
		mov		AH,0x00
		mov 	DL,0x00		;A驱动器
		int		0x13		;重置驱动器
		jmp		retry
next:
		mov		AX,ES		;把内存地址后移0x200
		add		AX,0x0020
		mov		ES,AX		;因为没有add ES,0x020指令，所以这里稍微绕个弯
		add		CL,1 		;往CL里加1
		cmp		CL,18 		;比较CL与18
		jbe		readloop	;如果CL<=18 跳转至readloop
		mov		CL,1
		add		DH,1 
		cmp		DH,2
		jb		readloop
		mov 	DH,0
		add		CH,1 
		cmp		CH,CYLS
		jb		readloop	;如果CH<CYLS，则跳转到readloop  常数CYLS代表cylinders柱面
		
;读完启动区10柱面18扇区载入运行操作系统
		mov		[0x0ff0],CH
		jmp		0xc200

error:
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
		db		"load error"
		db		0x0a
		db		0
		
		RESB	0x7dfe-$
		
		DB		0x55, 0xaa
