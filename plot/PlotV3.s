
.global		RESTART

VIC						= $9000
VIC_COLUMNS 			= VIC+$02
VIC_ROWS 				= VIC+$03
VIC_RASTER 				= VIC+$04
VIC_SCR_CHR_MAP_ADDR	= VIC+$05
COLUMNS 				= 20
ROW						= 12
ROWS					= ROW+ROW ;(12x2)
CHAR16 					= 1 				; 16 character charset
CHARSZ					= 16 				; LINES PER CHAR

BITMAP = $1100
BM = BITMAP
VIDEO = $1000
COLOURRAM = $9400

SCN = 253
SCN_LO	= SCN
SCN_HI	= SCN_LO +1

		.segment "CODE"

RESTART:	JSR		CLEAR

MAINLOOP:	JSR		VBL
			LDX		#10
			JSR		CLR_PNTS
			
			LDX		#10
			JSR		MOVE_PNTS

			LDX		#10
			JSR		PLOT_PNTS
			JMP		MAINLOOP

	ldy		#0
	ldx		#0
	jsr		PLOT

	ldy		#0
	ldx		#159
	jsr		PLOT

	ldy		#191
	ldx		#0
	jsr		PLOT

	ldy		#191
	ldx		#159
	jsr		PLOT

STOP:		JMP		STOP

CLR_PNTS:		STX		CLR_X +1
				LDY		PV,X
				LDA		PH,X
				TAX
				JSR		CLR
CLR_X:			LDX		#0
				DEX
				BPL		CLR_PNTS
			RTS

MOVE_PNTS:		STX		MOVE_X +1
				LDA		PH,X
				CLC
				ADC		MH,X
				STA		PH,X

				BEQ		REV_H
				CMP		#159
				BCC		MOVE_V
				
REV_H:				LDA		MH,X
					EOR		#255	; reverse
					CLC
					ADC		#1
					STA		MH,X

MOVE_V:			LDA		PV,X
				CLC
				ADC		MV,X
				STA		PV,X

				BEQ		REV_V
				CMP		#191
				BCC		MOVE_X
				
REV_V:				LDA		MV,X
					EOR		#255	; reverse
					CLC
					ADC		#1
					STA		MV,X

MOVE_X:			LDX		#0
				DEX
				BPL		MOVE_PNTS

			RTS
			
PLOT_PNTS:		STX		PLOT_X +1
				LDY		PV,X
				LDA		PH,X
				TAX
				JSR		PLOT
PLOT_X:			LDX		#0
				DEX
				BPL		PLOT_PNTS
			RTS

			RTS

CLEAR:	LDA		#0
		TAX		; LDX		#0

CLRLOOP:		STA		BM+(256*0),X
				STA		BM+(256*1),X
				STA		BM+(256*2),X
				STA		BM+(256*3),X
				STA		BM+(256*4),X
				STA		BM+(256*5),X
				STA		BM+(256*6),X
				STA		BM+(256*7),X
				STA		BM+(256*8),X
				STA		BM+(256*9),X
				STA		BM+(256*10),X
				STA		BM+(256*11),X
				STA		BM+(256*12),X
				STA		BM+(256*13),X
				STA		BM+(256*14),X
				DEX
				BNE		CLRLOOP
		RTS

VBL:		LDA		VIC_RASTER
			BNE		VBL			; NOT AT 0
		RTS

PLOT:	LDA   HORHI,X
        STA   SCN_HI
        LDA   HORLO,X
        STA   SCN_LO
		LDA   (SCN),Y
		EOR   EORTAB,X
		STA   (SCN),Y
		RTS

CLR:	LDA   HORHI,X
        STA   SCN_HI
        LDA   HORLO,X
        STA   SCN_LO
		LDA   #0
CLRSCN:	STA   (SCN),Y
		RTS

HORHI:	.HIBYTES	(BM +(ROW*CHARSZ*0)),(BM +(ROW*CHARSZ*0)),(BM +(ROW*CHARSZ*0)),(BM +(ROW*CHARSZ*0)),(BM +(ROW*CHARSZ*0)),(BM +(ROW*CHARSZ*0)),(BM +(ROW*CHARSZ*0)),(BM +(ROW*CHARSZ*0))
		.HIBYTES	(BM +(ROW*CHARSZ*1)),(BM +(ROW*CHARSZ*1)),(BM +(ROW*CHARSZ*1)),(BM +(ROW*CHARSZ*1)),(BM +(ROW*CHARSZ*1)),(BM +(ROW*CHARSZ*1)),(BM +(ROW*CHARSZ*1)),(BM +(ROW*CHARSZ*1))
		.HIBYTES	(BM +(ROW*CHARSZ*2)),(BM +(ROW*CHARSZ*2)),(BM +(ROW*CHARSZ*2)),(BM +(ROW*CHARSZ*2)),(BM +(ROW*CHARSZ*2)),(BM +(ROW*CHARSZ*2)),(BM +(ROW*CHARSZ*2)),(BM +(ROW*CHARSZ*2))
		.HIBYTES	(BM +(ROW*CHARSZ*3)),(BM +(ROW*CHARSZ*3)),(BM +(ROW*CHARSZ*3)),(BM +(ROW*CHARSZ*3)),(BM +(ROW*CHARSZ*3)),(BM +(ROW*CHARSZ*3)),(BM +(ROW*CHARSZ*3)),(BM +(ROW*CHARSZ*3))
		.HIBYTES	(BM +(ROW*CHARSZ*4)),(BM +(ROW*CHARSZ*4)),(BM +(ROW*CHARSZ*4)),(BM +(ROW*CHARSZ*4)),(BM +(ROW*CHARSZ*4)),(BM +(ROW*CHARSZ*4)),(BM +(ROW*CHARSZ*4)),(BM +(ROW*CHARSZ*4))
		.HIBYTES	(BM +(ROW*CHARSZ*5)),(BM +(ROW*CHARSZ*5)),(BM +(ROW*CHARSZ*5)),(BM +(ROW*CHARSZ*5)),(BM +(ROW*CHARSZ*5)),(BM +(ROW*CHARSZ*5)),(BM +(ROW*CHARSZ*5)),(BM +(ROW*CHARSZ*5))
		.HIBYTES	(BM +(ROW*CHARSZ*6)),(BM +(ROW*CHARSZ*6)),(BM +(ROW*CHARSZ*6)),(BM +(ROW*CHARSZ*6)),(BM +(ROW*CHARSZ*6)),(BM +(ROW*CHARSZ*6)),(BM +(ROW*CHARSZ*6)),(BM +(ROW*CHARSZ*6))
		.HIBYTES	(BM +(ROW*CHARSZ*7)),(BM +(ROW*CHARSZ*7)),(BM +(ROW*CHARSZ*7)),(BM +(ROW*CHARSZ*7)),(BM +(ROW*CHARSZ*7)),(BM +(ROW*CHARSZ*7)),(BM +(ROW*CHARSZ*7)),(BM +(ROW*CHARSZ*7))
		.HIBYTES	(BM +(ROW*CHARSZ*8)),(BM +(ROW*CHARSZ*8)),(BM +(ROW*CHARSZ*8)),(BM +(ROW*CHARSZ*8)),(BM +(ROW*CHARSZ*8)),(BM +(ROW*CHARSZ*8)),(BM +(ROW*CHARSZ*8)),(BM +(ROW*CHARSZ*8))
		.HIBYTES	(BM +(ROW*CHARSZ*9)),(BM +(ROW*CHARSZ*9)),(BM +(ROW*CHARSZ*9)),(BM +(ROW*CHARSZ*9)),(BM +(ROW*CHARSZ*9)),(BM +(ROW*CHARSZ*9)),(BM +(ROW*CHARSZ*9)),(BM +(ROW*CHARSZ*9))
		.HIBYTES	(BM +(ROW*CHARSZ*10)),(BM +(ROW*CHARSZ*10)),(BM +(ROW*CHARSZ*10)),(BM +(ROW*CHARSZ*10)),(BM +(ROW*CHARSZ*10)),(BM +(ROW*CHARSZ*10)),(BM +(ROW*CHARSZ*10)),(BM +(ROW*CHARSZ*10))
		.HIBYTES	(BM +(ROW*CHARSZ*11)),(BM +(ROW*CHARSZ*11)),(BM +(ROW*CHARSZ*11)),(BM +(ROW*CHARSZ*11)),(BM +(ROW*CHARSZ*11)),(BM +(ROW*CHARSZ*11)),(BM +(ROW*CHARSZ*11)),(BM +(ROW*CHARSZ*11))
		.HIBYTES	(BM +(ROW*CHARSZ*12)),(BM +(ROW*CHARSZ*12)),(BM +(ROW*CHARSZ*12)),(BM +(ROW*CHARSZ*12)),(BM +(ROW*CHARSZ*12)),(BM +(ROW*CHARSZ*12)),(BM +(ROW*CHARSZ*12)),(BM +(ROW*CHARSZ*12))
		.HIBYTES	(BM +(ROW*CHARSZ*13)),(BM +(ROW*CHARSZ*13)),(BM +(ROW*CHARSZ*13)),(BM +(ROW*CHARSZ*13)),(BM +(ROW*CHARSZ*13)),(BM +(ROW*CHARSZ*13)),(BM +(ROW*CHARSZ*13)),(BM +(ROW*CHARSZ*13))
		.HIBYTES	(BM +(ROW*CHARSZ*14)),(BM +(ROW*CHARSZ*14)),(BM +(ROW*CHARSZ*14)),(BM +(ROW*CHARSZ*14)),(BM +(ROW*CHARSZ*14)),(BM +(ROW*CHARSZ*14)),(BM +(ROW*CHARSZ*14)),(BM +(ROW*CHARSZ*14))
		.HIBYTES	(BM +(ROW*CHARSZ*15)),(BM +(ROW*CHARSZ*15)),(BM +(ROW*CHARSZ*15)),(BM +(ROW*CHARSZ*15)),(BM +(ROW*CHARSZ*15)),(BM +(ROW*CHARSZ*15)),(BM +(ROW*CHARSZ*15)),(BM +(ROW*CHARSZ*15))
		.HIBYTES	(BM +(ROW*CHARSZ*16)),(BM +(ROW*CHARSZ*16)),(BM +(ROW*CHARSZ*16)),(BM +(ROW*CHARSZ*16)),(BM +(ROW*CHARSZ*16)),(BM +(ROW*CHARSZ*16)),(BM +(ROW*CHARSZ*16)),(BM +(ROW*CHARSZ*16))
		.HIBYTES	(BM +(ROW*CHARSZ*17)),(BM +(ROW*CHARSZ*17)),(BM +(ROW*CHARSZ*17)),(BM +(ROW*CHARSZ*17)),(BM +(ROW*CHARSZ*17)),(BM +(ROW*CHARSZ*17)),(BM +(ROW*CHARSZ*17)),(BM +(ROW*CHARSZ*17))
		.HIBYTES	(BM +(ROW*CHARSZ*18)),(BM +(ROW*CHARSZ*18)),(BM +(ROW*CHARSZ*18)),(BM +(ROW*CHARSZ*18)),(BM +(ROW*CHARSZ*18)),(BM +(ROW*CHARSZ*18)),(BM +(ROW*CHARSZ*18)),(BM +(ROW*CHARSZ*18))
		.HIBYTES	(BM +(ROW*CHARSZ*19)),(BM +(ROW*CHARSZ*19)),(BM +(ROW*CHARSZ*19)),(BM +(ROW*CHARSZ*19)),(BM +(ROW*CHARSZ*19)),(BM +(ROW*CHARSZ*19)),(BM +(ROW*CHARSZ*19)),(BM +(ROW*CHARSZ*19))

HORLO:	.LOBYTES	(BM +(ROW*CHARSZ*0)),(BM +(ROW*CHARSZ*0)),(BM +(ROW*CHARSZ*0)),(BM +(ROW*CHARSZ*0)),(BM +(ROW*CHARSZ*0)),(BM +(ROW*CHARSZ*0)),(BM +(ROW*CHARSZ*0)),(BM +(ROW*CHARSZ*0))
		.LOBYTES	(BM +(ROW*CHARSZ*1)),(BM +(ROW*CHARSZ*1)),(BM +(ROW*CHARSZ*1)),(BM +(ROW*CHARSZ*1)),(BM +(ROW*CHARSZ*1)),(BM +(ROW*CHARSZ*1)),(BM +(ROW*CHARSZ*1)),(BM +(ROW*CHARSZ*1))
		.LOBYTES	(BM +(ROW*CHARSZ*2)),(BM +(ROW*CHARSZ*2)),(BM +(ROW*CHARSZ*2)),(BM +(ROW*CHARSZ*2)),(BM +(ROW*CHARSZ*2)),(BM +(ROW*CHARSZ*2)),(BM +(ROW*CHARSZ*2)),(BM +(ROW*CHARSZ*2))
		.LOBYTES	(BM +(ROW*CHARSZ*3)),(BM +(ROW*CHARSZ*3)),(BM +(ROW*CHARSZ*3)),(BM +(ROW*CHARSZ*3)),(BM +(ROW*CHARSZ*3)),(BM +(ROW*CHARSZ*3)),(BM +(ROW*CHARSZ*3)),(BM +(ROW*CHARSZ*3))
		.LOBYTES	(BM +(ROW*CHARSZ*4)),(BM +(ROW*CHARSZ*4)),(BM +(ROW*CHARSZ*4)),(BM +(ROW*CHARSZ*4)),(BM +(ROW*CHARSZ*4)),(BM +(ROW*CHARSZ*4)),(BM +(ROW*CHARSZ*4)),(BM +(ROW*CHARSZ*4))
		.LOBYTES	(BM +(ROW*CHARSZ*5)),(BM +(ROW*CHARSZ*5)),(BM +(ROW*CHARSZ*5)),(BM +(ROW*CHARSZ*5)),(BM +(ROW*CHARSZ*5)),(BM +(ROW*CHARSZ*5)),(BM +(ROW*CHARSZ*5)),(BM +(ROW*CHARSZ*5))
		.LOBYTES	(BM +(ROW*CHARSZ*6)),(BM +(ROW*CHARSZ*6)),(BM +(ROW*CHARSZ*6)),(BM +(ROW*CHARSZ*6)),(BM +(ROW*CHARSZ*6)),(BM +(ROW*CHARSZ*6)),(BM +(ROW*CHARSZ*6)),(BM +(ROW*CHARSZ*6))
		.LOBYTES	(BM +(ROW*CHARSZ*7)),(BM +(ROW*CHARSZ*7)),(BM +(ROW*CHARSZ*7)),(BM +(ROW*CHARSZ*7)),(BM +(ROW*CHARSZ*7)),(BM +(ROW*CHARSZ*7)),(BM +(ROW*CHARSZ*7)),(BM +(ROW*CHARSZ*7))
		.LOBYTES	(BM +(ROW*CHARSZ*8)),(BM +(ROW*CHARSZ*8)),(BM +(ROW*CHARSZ*8)),(BM +(ROW*CHARSZ*8)),(BM +(ROW*CHARSZ*8)),(BM +(ROW*CHARSZ*8)),(BM +(ROW*CHARSZ*8)),(BM +(ROW*CHARSZ*8))
		.LOBYTES	(BM +(ROW*CHARSZ*9)),(BM +(ROW*CHARSZ*9)),(BM +(ROW*CHARSZ*9)),(BM +(ROW*CHARSZ*9)),(BM +(ROW*CHARSZ*9)),(BM +(ROW*CHARSZ*9)),(BM +(ROW*CHARSZ*9)),(BM +(ROW*CHARSZ*9))
		.LOBYTES	(BM +(ROW*CHARSZ*10)),(BM +(ROW*CHARSZ*10)),(BM +(ROW*CHARSZ*10)),(BM +(ROW*CHARSZ*10)),(BM +(ROW*CHARSZ*10)),(BM +(ROW*CHARSZ*10)),(BM +(ROW*CHARSZ*10)),(BM +(ROW*CHARSZ*10))
		.LOBYTES	(BM +(ROW*CHARSZ*11)),(BM +(ROW*CHARSZ*11)),(BM +(ROW*CHARSZ*11)),(BM +(ROW*CHARSZ*11)),(BM +(ROW*CHARSZ*11)),(BM +(ROW*CHARSZ*11)),(BM +(ROW*CHARSZ*11)),(BM +(ROW*CHARSZ*11))
		.LOBYTES	(BM +(ROW*CHARSZ*12)),(BM +(ROW*CHARSZ*12)),(BM +(ROW*CHARSZ*12)),(BM +(ROW*CHARSZ*12)),(BM +(ROW*CHARSZ*12)),(BM +(ROW*CHARSZ*12)),(BM +(ROW*CHARSZ*12)),(BM +(ROW*CHARSZ*12))
		.LOBYTES	(BM +(ROW*CHARSZ*13)),(BM +(ROW*CHARSZ*13)),(BM +(ROW*CHARSZ*13)),(BM +(ROW*CHARSZ*13)),(BM +(ROW*CHARSZ*13)),(BM +(ROW*CHARSZ*13)),(BM +(ROW*CHARSZ*13)),(BM +(ROW*CHARSZ*13))
		.LOBYTES	(BM +(ROW*CHARSZ*14)),(BM +(ROW*CHARSZ*14)),(BM +(ROW*CHARSZ*14)),(BM +(ROW*CHARSZ*14)),(BM +(ROW*CHARSZ*14)),(BM +(ROW*CHARSZ*14)),(BM +(ROW*CHARSZ*14)),(BM +(ROW*CHARSZ*14))
		.LOBYTES	(BM +(ROW*CHARSZ*15)),(BM +(ROW*CHARSZ*15)),(BM +(ROW*CHARSZ*15)),(BM +(ROW*CHARSZ*15)),(BM +(ROW*CHARSZ*15)),(BM +(ROW*CHARSZ*15)),(BM +(ROW*CHARSZ*15)),(BM +(ROW*CHARSZ*15))
		.LOBYTES	(BM +(ROW*CHARSZ*16)),(BM +(ROW*CHARSZ*16)),(BM +(ROW*CHARSZ*16)),(BM +(ROW*CHARSZ*16)),(BM +(ROW*CHARSZ*16)),(BM +(ROW*CHARSZ*16)),(BM +(ROW*CHARSZ*16)),(BM +(ROW*CHARSZ*16))
		.LOBYTES	(BM +(ROW*CHARSZ*17)),(BM +(ROW*CHARSZ*17)),(BM +(ROW*CHARSZ*17)),(BM +(ROW*CHARSZ*17)),(BM +(ROW*CHARSZ*17)),(BM +(ROW*CHARSZ*17)),(BM +(ROW*CHARSZ*17)),(BM +(ROW*CHARSZ*17))
		.LOBYTES	(BM +(ROW*CHARSZ*18)),(BM +(ROW*CHARSZ*18)),(BM +(ROW*CHARSZ*18)),(BM +(ROW*CHARSZ*18)),(BM +(ROW*CHARSZ*18)),(BM +(ROW*CHARSZ*18)),(BM +(ROW*CHARSZ*18)),(BM +(ROW*CHARSZ*18))
		.LOBYTES	(BM +(ROW*CHARSZ*19)),(BM +(ROW*CHARSZ*19)),(BM +(ROW*CHARSZ*19)),(BM +(ROW*CHARSZ*19)),(BM +(ROW*CHARSZ*19)),(BM +(ROW*CHARSZ*19)),(BM +(ROW*CHARSZ*19)),(BM +(ROW*CHARSZ*19))

EORTAB:	.REPEAT		20
		.BYTE		%10000000,%01000000,%00100000,%00010000,%00001000,%00000100,%00000010,%00000001
		.ENDREPEAT

;CLEAR:	LDX		#<BM
;		LDY		#>BM
;		STX		SCN_LO
;		STY		SCN_HI
;
;		LDX		#15
;		LDY		#0
;		TYA		; LDA		#0
;		
;CLSLOOP:		STA		(SCN),Y
;				DEY
;				BNE		CLSLOOP
;		
;			INC		SCN_HI
;			DEX
;			BNE		CLSLOOP
;			
;		RTS

PV:		.BYTE	15,25,35,45,55,65,75,85,95,105,115,125,135,145,155
PH:		.BYTE	10,20,30,40,50,60,70,80,90,100,110,120,130,140,150
MV:		.BYTE	1,255,1,255,1,255,1,255,1,255,1,255,1,255,1
MH:		.BYTE	255,255,1,1,255,255,1,1,255,255,1,1,255,255,1