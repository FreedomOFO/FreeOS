;FreeOS-OS
;TAB=4

BOTPAK	EQU		0x00280000	;bootpack的
DSKCAC	EQU		0x00100000	;磁盘缓存的地方
DSKCAC0	EQU		0x00008000	;磁盘缓存的地方（实模式）

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

;PIC是以免接受任何中断的
;AT兼容机的说明书中，在PIC的初始化的话
;如果你不CLI之前做一个该死的东西，偶尔死机的
;PLC的初始化之后再做

		mov		AL,0xff
		out		0x21,AL
		NOP					;out指令也不能连续正常的工作
		out 	0xa1,AL
		CLI					;另外中断也在CPU级别被禁止
		
;为了从CPU获得越多超过1MB的内存，设置A20GATE
		call	waitkbdout
		mov		AL,0xd1
		out		0x64,AL
		call	waitkbdout
		mov		AL,0xdf		;enable A20
		out		0x60,AL
		call	waitkbdout

;保护模式转变
[INSTRSET "i486p"]			;声明要使用到的486命令
		LGDT	[GDTR0]		;暂定GDT设置
		mov		EAX,CR0
		and		EAX,0x7fffffff	;位31设定为0（寻呼禁止）
		or		EAX,0x00000001	;位0设置为1（为保护模式迁移）
		mov		CR0,EAX
		jmp		pipelineflush
pipelineflush:
		mov		AX,1*8			;可以读写段32位
		mov		DS,AX
		mov		ES,AX
		mov		FS,AX
		mov		GS,AX
		mov		SS,AX
;bootpack的传输
	
		mov		ESI,bootpack	;传输元
		mov		EDI,BOTPAK		;传递地址
		mov		ECX,512*1024/4
		call	memcpy
;顺便把磁盘数据也传输到本来的位置
;首先从启动扇区开始
		MOV		ESI,0x7c00		; 传输元
		MOV		EDI,DSKCAC		; 传递地址
		MOV		ECX,512/4
		CALL	memcpy
;剩下全部
		MOV		ESI,DSKCAC0+512	; 传输元?
		MOV		EDI,DSKCAC+512	; 传递地址
		MOV		ECX,0
		MOV		CL,BYTE [CYLS]
		IMUL	ECX,512*18*2/4	; 从字节/4缸数转换
		SUB		ECX,512/4		; 由IPl的部分扣除
		CALL	memcpy
;asmhead部分完成了
;其余是留给bootpack的

;bootpack启动
		MOV		EBX,BOTPAK
		MOV		ECX,[EBX+16]
		ADD		ECX,3			; ECX += 3;
		SHR		ECX,2			; ECX /= 4;
		JZ		skip			; 没有被转移的
		MOV		ESI,[EBX+20]	;传输元
		ADD		ESI,EBX
		MOV		EDI,[EBX+12]	;传递地址
		CALL	memcpy
skip:
		MOV		ESP,[EBX+12]	; 堆栈初期值
		JMP		DWORD 2*8:0x0000001b

waitkbdout:
		IN		 AL,0x64
		AND		 AL,0x02
		JNZ		waitkbdout		; and的结果为0的话跳转到waitkbdout
		RET

memcpy:
		MOV		EAX,[ESI]
		ADD		ESI,4
		MOV		[EDI],EAX
		ADD		EDI,4
		SUB		ECX,1
		JNZ		memcpy			;减法结果为0的话跳转到memcpy
		RET
; memcpy是被遗忘的地址大小前缀，也可以写成字符串指令

		ALIGNB	16
GDT0:
		RESB	8				; 空选择器
		DW		0xffff,0x0000,0x9200,0x00cf	; 可读写段32位
		DW		0xffff,0x0000,0x9a28,0x0047	; 可执行部门32bit（bootpack用）

		DW		0
GDTR0:
		DW		8*3-1
		DD		GDT0

		ALIGNB	16
bootpack: