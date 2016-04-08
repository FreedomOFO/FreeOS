;FreeOS-OS
;TAB=4

BOTPAK	EQU		0x00280000	;bootpack��
DSKCAC	EQU		0x00100000	;���̻���ĵط�
DSKCAC0	EQU		0x00008000	;���̻���ĵط���ʵģʽ��

;�й�BOOT_INFO
CYLS	EQU		0x0ff0		;�趨������
LEDS	EQU		0x0ff1
VMODE	EQU		0x0ff2		;������ɫ��Ŀ����Ϣ����ɫ��λ��
SCRNX	EQU		0x0ff4		;�ֱ��ʵ�X(screen x)
SCRNY	EQU		0x0ff6		;�ֱ��ʵ�Y(screen y)
VRAM	EQU		0x0ff8		;ͼ�񻺳����Ŀ�ʼ��ַ

		org		0xc200		;�����������0x4200�ŵ�ַ�����ڴ�0xc200�ŵ�ַ
		mov		AL,0x13		;VGA�Կ���320*200*8λ��ɫ
		mov		AH,0x00		;�����Կ�BIOS�ĺ������л���ʾģʽ
		int		0x10
		mov		byte[VMODE],8	;��¼����ģʽ(c���Բ���)
		mov		word[SCRNX],320
		mov		word[SCRNY],200
		mov		dword[VRAM],0x000a0000
		
;��BIOSȡ�ü����ϸ���LEDָʾ�Ƶ�״̬
		mov		AH,0x02
		int		0x16		;keyboard BIOS
		mov		[LEDS],AL

;PIC����������κ��жϵ�
;AT���ݻ���˵�����У���PIC�ĳ�ʼ���Ļ�
;����㲻CLI֮ǰ��һ�������Ķ�����ż��������
;PLC�ĳ�ʼ��֮������

		mov		AL,0xff
		out		0x21,AL
		NOP					;outָ��Ҳ�������������Ĺ���
		out 	0xa1,AL
		CLI					;�����ж�Ҳ��CPU���𱻽�ֹ
		
;Ϊ�˴�CPU���Խ�೬��1MB���ڴ棬����A20GATE
		call	waitkbdout
		mov		AL,0xd1
		out		0x64,AL
		call	waitkbdout
		mov		AL,0xdf		;enable A20
		out		0x60,AL
		call	waitkbdout

;����ģʽת��
[INSTRSET "i486p"]			;����Ҫʹ�õ���486����
		LGDT	[GDTR0]		;�ݶ�GDT����
		mov		EAX,CR0
		and		EAX,0x7fffffff	;λ31�趨Ϊ0��Ѱ����ֹ��
		or		EAX,0x00000001	;λ0����Ϊ1��Ϊ����ģʽǨ�ƣ�
		mov		CR0,EAX
		jmp		pipelineflush
pipelineflush:
		mov		AX,1*8			;���Զ�д��32λ
		mov		DS,AX
		mov		ES,AX
		mov		FS,AX
		mov		GS,AX
		mov		SS,AX
;bootpack�Ĵ���
	
		mov		ESI,bootpack	;����Ԫ
		mov		EDI,BOTPAK		;���ݵ�ַ
		mov		ECX,512*1024/4
		call	memcpy
;˳��Ѵ�������Ҳ���䵽������λ��
;���ȴ�����������ʼ
		MOV		ESI,0x7c00		; ����Ԫ
		MOV		EDI,DSKCAC		; ���ݵ�ַ
		MOV		ECX,512/4
		CALL	memcpy
;ʣ��ȫ��
		MOV		ESI,DSKCAC0+512	; ����Ԫ?
		MOV		EDI,DSKCAC+512	; ���ݵ�ַ
		MOV		ECX,0
		MOV		CL,BYTE [CYLS]
		IMUL	ECX,512*18*2/4	; ���ֽ�/4����ת��
		SUB		ECX,512/4		; ��IPl�Ĳ��ֿ۳�
		CALL	memcpy
;asmhead���������
;����������bootpack��

;bootpack����
		MOV		EBX,BOTPAK
		MOV		ECX,[EBX+16]
		ADD		ECX,3			; ECX += 3;
		SHR		ECX,2			; ECX /= 4;
		JZ		skip			; û�б�ת�Ƶ�
		MOV		ESI,[EBX+20]	;����Ԫ
		ADD		ESI,EBX
		MOV		EDI,[EBX+12]	;���ݵ�ַ
		CALL	memcpy
skip:
		MOV		ESP,[EBX+12]	; ��ջ����ֵ
		JMP		DWORD 2*8:0x0000001b

waitkbdout:
		IN		 AL,0x64
		AND		 AL,0x02
		JNZ		waitkbdout		; and�Ľ��Ϊ0�Ļ���ת��waitkbdout
		RET

memcpy:
		MOV		EAX,[ESI]
		ADD		ESI,4
		MOV		[EDI],EAX
		ADD		EDI,4
		SUB		ECX,1
		JNZ		memcpy			;�������Ϊ0�Ļ���ת��memcpy
		RET
; memcpy�Ǳ������ĵ�ַ��Сǰ׺��Ҳ����д���ַ���ָ��

		ALIGNB	16
GDT0:
		RESB	8				; ��ѡ����
		DW		0xffff,0x0000,0x9200,0x00cf	; �ɶ�д��32λ
		DW		0xffff,0x0000,0x9a28,0x0047	; ��ִ�в���32bit��bootpack�ã�

		DW		0
GDTR0:
		DW		8*3-1
		DD		GDT0

		ALIGNB	16
bootpack: