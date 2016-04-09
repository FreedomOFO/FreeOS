;nakfunc
;TAB=4

[FORMAT "WCOFF"]		;制作目标文件的模式
[INSTRSET "i486p"]		;使用到486为止的指令
[BITS 32]				;制作32位模式用的机器语言

;制作目标文件的信息

[FILE "naskfunc.nas"]	;源程序文件名
		GLOBAL	_io_hlt,_io_cli,_io_sti,_io_stihlt	;程序中包含的函数名
		GLOBAL	_io_in8,_io_in16,_io_in32
		GLOBAL	_io_out8,_io_out16,_io_out32
		GLOBAL	_io_load_eflags,_io_store_eflags
		global	_load_gdtr,_load_idtr
;以下是实际的函数
[SECTION .text]			;目标文件中写了这些后再写程序

_io_hlt:				;void io_hlt(void);
		HLT
		RET
		
_io_cli:
		CLI				;中断标志设为0
		RET
_io_sti:
		STI				;中断标志设为1
		RET				
_io_stihlt:
		STI
		HLT
		RET
_io_in8:
		mov		EDX,[ESP+4]			;port
		mov		EAX,0
		in		AL,DX
		RET
_io_in16:
		mov		EDX,[ESP+4]			;port
		mov		EAX,0
		in		AX,DX
		RET
_io_in32:
		mov		EDX,[ESP+4]			;port
		in		EAX,DX
		RET
_io_out8:
		mov		EDX,[ESP+4]			;port
		mov		AL,[ESP+8]			;data
		out		DX,AL
		ret
_io_out16:
		mov		EDX,[ESP+4]			;port
		mov		EAX,[ESP+8]			;data
		out		DX,AX
		ret
_io_out32:
		mov		EDX,[ESP+4]			;port
		mov		EAX,[ESP+8]			;data
		out		DX,EAX
		ret
_io_load_eflags:
		PUSHFD						;指PUSH EFLAGS
		POP		EAX
		RET
_io_store_eflags:
		mov 	EAX,[ESP+4]
		PUSH	EAX					
		POPFD						;指POP EFLAGS
		RET
_load_gdtr:
		mov		AX,[ESP+4]			;limit
		mov		[ESP+6],AX
		LGDT	[ESP+6]
		RET
_load_idtr:
		mov		AX,[ESP+4]			;limit
		mov		[ESP+6],AX
		LIDT	[ESP+6]
		RET
	