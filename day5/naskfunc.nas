;nakfunc
;TAB=4

[FORMAT "WCOFF"]		;����Ŀ���ļ���ģʽ
[INSTRSET "i486p"]		;ʹ�õ�486Ϊֹ��ָ��
[BITS 32]				;����32λģʽ�õĻ�������

;����Ŀ���ļ�����Ϣ

[FILE "naskfunc.nas"]	;Դ�����ļ���
		GLOBAL	_io_hlt,_io_cli,_io_sti,_io_stihlt	;�����а����ĺ�����
		GLOBAL	_io_in8,_io_in16,_io_in32
		GLOBAL	_io_out8,_io_out16,_io_out32
		GLOBAL	_io_load_eflags,_io_store_eflags
		global	_load_gdtr,_load_idtr
;������ʵ�ʵĺ���
[SECTION .text]			;Ŀ���ļ���д����Щ����д����

_io_hlt:				;void io_hlt(void);
		HLT
		RET
		
_io_cli:
		CLI				;�жϱ�־��Ϊ0
		RET
_io_sti:
		STI				;�жϱ�־��Ϊ1
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
		PUSHFD						;ָPUSH EFLAGS
		POP		EAX
		RET
_io_store_eflags:
		mov 	EAX,[ESP+4]
		PUSH	EAX					
		POPFD						;ָPOP EFLAGS
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
	