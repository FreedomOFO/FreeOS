

		org		0x7c00
		jmp 	entry
		
;���¼������ڱ�׼FAT12��ʽ����

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
		
;�������

entry:
		mov		AX,0		;��ʼ���Ĵ���
		mov		SS,AX
		mov		SP,0x7c00
		mov		DS,AX
		mov		ES,AX
		
		mov		SI,msg
putloop:
		mov		AL,[SI]
		add		si,1		;��si+1
		cmp		AL,0
		je		fin
		mov		AH,0x0e		;��ʾһ������
		mov		BX,15		;ָ���ַ���ɫ
		int		0x10		;�����Կ�BIOS
		jmp		putloop
fin:
		hlt					;��cpuֹͣ���ȴ�ָ��
		jmp 	fin
		
msg:	
		db		0x0a,0x0a	;��������
		db		"hello,FREE "
		db		0x0a
		db		0
		
		RESB	0x7dfe-$
		
		DB		0x55, 0xaa
