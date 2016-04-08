;FreeOS-IPL
;TAB=4

CYLS	equ	10
		
		org		0x7c00
		jmp 	entry
		
;���¼������ڱ�׼FAT12��ʽ����

		db		0x90
		db		"HelloIPL"	;���������ƣ�8�ֽڣ�
		dw 		512			;������sector����С������Ϊ512�ֽڣ�
		db 		1 			;�أ�cluster���Ĵ�С������Ϊ1��������
		dw 		1			;FAT����ʼλ�ã�һ��ӵ�һ��������ʼ��
		db 		2			;FAT�ĸ���������Ϊ2��
		dw 		224			;��Ŀ¼�Ĵ�С��һ������Ϊ224�
		dw 		2880		;�ô��̵Ĵ�С������Ϊ2880������
		db		0xf0		;�������ࣨ����Ϊ0xf0��
		dw		9			;FAT�ĳ��ȣ�����Ϊ9������
		dw		18			;1���ŵ�
		dw		2			;��ͷ����������2��
		dd		0			;��ʹ�÷�����������0
		dd		2880		;��дһ�δ��̴�С
		db		0,0,0x29	;���岻�����̶�
		dd		0xffffffff	;����Ϊ������		
		DB		"FREE-OS    "	;�������ƣ�11�ֽڣ�	
		DB		"FAT12   "		;���̸�ʽ���ƣ�8�ֽڣ�	
		RESB	18				
		
;�������

entry:
		mov		AX,0		;��ʼ���Ĵ���
		mov		SS,AX
		mov		SP,0x7c00
		mov		DS,AX

;��ȡ����
	
		mov		AX,0x0820
		mov		ES,AX
		mov		CH,0		;����0
		mov		DH,0		;��ͷ0
		mov		CL,2 		;����2
readloop:
		mov		SI,0		;��¼ʧ�ܴ����ļĴ���
retry:
		mov		AH,0x02		;AH=0x02:�������
		mov		AL,1 		;1������
		mov		BX,0		
		mov		DL,0x00		;A������
		int		0x13		;���ô���BIOS
		jnc		next		;û����Ļ���ת��next
		add		si,1		;��si��1
		cmp		si,5 		;�Ƚ�si��5
		jae		error		;si>=5ʱ����ת��error
		mov		AH,0x00
		mov 	DL,0x00		;A������
		int		0x13		;����������
		jmp		retry
next:
		mov		AX,ES		;���ڴ��ַ����0x200
		add		AX,0x0020
		mov		ES,AX		;��Ϊû��add ES,0x020ָ�����������΢�Ƹ���
		add		CL,1 		;��CL���1
		cmp		CL,18 		;�Ƚ�CL��18
		jbe		readloop	;���CL<=18 ��ת��readloop
		mov		CL,1
		add		DH,1 
		cmp		DH,2
		jb		readloop
		mov 	DH,0
		add		CH,1 
		cmp		CH,CYLS
		jb		readloop	;���CH<CYLS������ת��readloop  ����CYLS����cylinders����
		
;����������10����18�����������в���ϵͳ
		mov		[0x0ff0],CH
		jmp		0xc200

error:
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
		db		"load error"
		db		0x0a
		db		0
		
		RESB	0x7dfe-$
		
		DB		0x55, 0xaa
