;FreeOS-OS
;TAB=4

BOTPAK	EQU		0x00280000	;bootpackµÄ
DSKCAC	EQU		0x00100000	;´ÅÅÌ»º´æµÄµØ·½
DSKCAC0	EQU		0x00008000	;´ÅÅÌ»º´æµÄµØ·½£¨ÊµÄ£Ê½£©

;ÓÐ¹ØBOOT_INFO
CYLS	EQU		0x0ff0		;Éè¶¨Æô¶¯Çø
LEDS	EQU		0x0ff1
VMODE	EQU		0x0ff2		;¹ØÓÚÑÕÉ«ÊýÄ¿µÄÐÅÏ¢£¬ÑÕÉ«µÄÎ»Êý
SCRNX	EQU		0x0ff4		;·Ö±æÂÊµÄX(screen x)
SCRNY	EQU		0x0ff6		;·Ö±æÂÊµÄY(screen y)
VRAM	EQU		0x0ff8		;Í¼Ïñ»º³åÇøµÄ¿ªÊ¼µØÖ·

		org		0xc200		;³ÌÐòÔØÈë´ÅÅÌ0x4200ºÅµØÖ·£¬¼´ÄÚ´æ0xc200ºÅµØÖ·
		mov		AL,0x13		;VGAÏÔ¿¨£¬320*200*8Î»²ÊÉ«
		mov		AH,0x00		;µ÷ÓÃÏÔ¿¨BIOSµÄº¯Êý£¬ÇÐ»»ÏÔÊ¾Ä£Ê½
		int		0x10
		mov		byte[VMODE],8	;¼ÇÂ¼»­ÃæÄ£Ê½(cÓïÑÔ²ÎÕÕ)
		mov		word[SCRNX],320
		mov		word[SCRNY],200
		mov		dword[VRAM],0x000a0000
		
;ÓÃBIOSÈ¡µÃ¼üÅÌÉÏ¸÷ÖÖLEDÖ¸Ê¾µÆµÄ×´Ì¬
		mov		AH,0x02
		int		0x16		;keyboard BIOS
		mov		[LEDS],AL

;PICÊÇÒÔÃâ½ÓÊÜÈÎºÎÖÐ¶ÏµÄ
;AT¼æÈÝ»úµÄËµÃ÷ÊéÖÐ£¬ÔÚPICµÄ³õÊ¼»¯µÄ»°
;Èç¹ûÄã²»CLIÖ®Ç°×öÒ»¸ö¸ÃËÀµÄ¶«Î÷£¬Å¼¶ûËÀ»úµÄ
;PLCµÄ³õÊ¼»¯Ö®ºóÔÙ×ö

		mov		AL,0xff
		out		0x21,AL
		NOP					;outÖ¸ÁîÒ²²»ÄÜÁ¬ÐøÕý³£µÄ¹¤×÷
		out 	0xa1,AL
		CLI					;ÁíÍâÖÐ¶ÏÒ²ÔÚCPU¼¶±ð±»½ûÖ¹
		
;ÎªÁË´ÓCPU»ñµÃÔ½¶à³¬¹ý1MBµÄÄÚ´æ£¬ÉèÖÃA20GATE
		call	waitkbdout
		mov		AL,0xd1
		out		0x64,AL
		call	waitkbdout
		mov		AL,0xdf		;enable A20
		out		0x60,AL
		call	waitkbdout

;±£»¤Ä£Ê½×ª±ä
[INSTRSET"i486p"]			;ÉùÃ÷ÒªÊ¹ÓÃµ½µÄ486ÃüÁî
		LGDT	[GDTR0]		;ÔÝ¶¨GDTÉèÖÃ
		mov		EAX,CR0
		and		EAX,0x7fffffff	;Î»31Éè¶¨Îª0£¨Ñ°ºô½ûÖ¹£©
		or		EAX,0x00000001	;Î»0ÉèÖÃÎª1£¨Îª±£»¤Ä£Ê½Ç¨ÒÆ£©
		mov		CR0,EAX
		jmp		pipelineflush
pipelineflush:
		mov		AX,1*8			;¿ÉÒÔ¶ÁÐ´¶Î32Î»
		mov		DS,AX
		mov		ES,AX
		mov		FS,AX
		mov		GS,AX
		mov		SS,AX
;bootpackµÄ´«Êä
	
		mov		ESI,bootpack	;´«ÊäÔª
		mov		EDI,DSKCAC		;´«µÝµØÖ·
		mov		ECX,512*1024/4
		call	memcpy
;Ë³±ã°Ñ´ÅÅÌÊý¾ÝÒ²´«Êäµ½±¾À´µÄÎ»ÖÃ
;Ê×ÏÈ´ÓÆô¶¯ÉÈÇø¿ªÊ¼
		MOV		ESI,0x7c00		; ´«ÊäÔª
		MOV		EDI,DSKCAC		; ´«µÝµØÖ·
		MOV		ECX,512/4
		CALL	memcpy
;Ê£ÏÂÈ«²¿
		MOV		ESI,DSKCAC0+512	; ´«ÊäÔªª
		MOV		EDI,DSKCAC+512	; ´«µÝµØÖ·
		MOV		ECX,0
		MOV		CL,BYTE [CYLS]
		IMUL	ECX,512*18*2/4	; ´Ó×Ö½Ú/4¸×Êý×ª»»
		SUB		ECX,512/4		; ÓÉIPlµÄ²¿·Ö¿Û³ý
		CALL	memcpy
;asmhead²¿·ÖÍê³ÉÁË
;ÆäÓàÊÇÁô¸øbootpackµÄ

;bootpackÆô¶¯
		MOV		EBX,BOTPAK
		MOV		ECX,[EBX+16]
		ADD		ECX,3			; ECX += 3;
		SHR		ECX,2			; ECX /= 4;
		JZ		skip			; Ã»ÓÐ±»×ªÒÆµÄ
		MOV		ESI,[EBX+20]	;´«ÊäÔª
		ADD		ESI,EBX
		MOV		EDI,[EBX+12]	;´«µÝµØÖ·
		CALL	memcpy
skip:
		MOV		ESP,[EBX+12]	; ¶ÑÕ»³õÆÚÖµ
		JMP		DWORD 2*8:0x0000001b

waitkbdout:
		IN		 AL,0x64
		AND		 AL,0x02
		JNZ		waitkbdout		; andµÄ½á¹ûÎª0µÄ»°Ìø×ªµ½waitkbdout
		RET

memcpy:
		MOV		EAX,[ESI]
		ADD		ESI,4
		MOV		[EDI],EAX
		ADD		EDI,4
		SUB		ECX,1
		JNZ		memcpy			;¼õ·¨½á¹ûÎª0µÄ»°Ìø×ªµ½memcpy
		RET
; memcpyÊÇ±»ÒÅÍüµÄµØÖ·´óÐ¡Ç°×º£¬Ò²¿ÉÒÔÐ´³É×Ö·û´®Ö¸Áî

		ALIGNB	16
GDT0:
		RESB	8				; ¿ÕÑ¡ÔñÆ÷
		DW		0xffff,0x0000,0x9200,0x00cf	; ¿É¶ÁÐ´¶Î32Î»
		DW		0xffff,0x0000,0x9a28,0x0047	; ¿ÉÖ´ÐÐ²¿ÃÅ32bit£¨bootpackÓÃ£©

		DW		0
GDTR0:
		DW		8*3-1
		DD		GDT0

		ALIGNB	16
bootpack: