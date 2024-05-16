;*********************************************************************
; COMMODORE VIC 20 BOOT USING BASIC 2.0
; written by Robert Hurst <robert@hurst-ri.us>
; updated version: 2-Jul-2010
;
		.fileopt author,	"Robert Hurst"
        .fileopt comment,	"Test"
        .fileopt compiler,	"VIC 20 ASSEMBLER"

.global RESTART	; useful symbol for MAP and hotkey restarting

VIC						= $9000
VIC_COLUMNS 			= VIC+$02
VIC_ROWS 				= VIC+$03
VIC_RASTER 				= VIC+$04
VIC_SCR_CHR_MAP_ADDR	= VIC+$05
COLUMNS 				= 20
ROWS					= 12+12 ;(12x2)
CHAR16 					= 1 				; 16 character charset

.global	ROWS

BITMP = $1100
VIDEO = $1000
COLOURRAM = $9400

;ptr1 = 251
;ptr2 = 253
;ch = ptr2
curr_char = 253
row_cnt = curr_char +1

;*********************************************************************
; Commodore BASIC 2.0 program
;
; LOAD "BERZERK-MMX.PRG",8
; RUN
;
		.segment "BASIC"

		.word	RUN		; load address
RUN:	.word	END		; next line link
		.word	2010	; line number
		.byte	$9E		; BASIC token: SYS
		.byte	<(MAIN / 1000 .mod 10) + $30
		.byte	<(MAIN / 100 .mod 10) + $30
		.byte	<(MAIN / 10 .mod 10) + $30
		.byte	<(MAIN / 1 .mod 10) + $30
		.byte	0		; end of line
END:	.word	0		; end of program

;*********************************************************************
; Starting entry point for this program
;
		.segment "STARTUP"

MAIN:
main:	jsr		SETVIC	 		;setup screen and clear it.	;120D
		jsr		SETSCREEN3
;		jsr		Cls

		jmp		RESTART

SETVIC:	lda 	#COLUMNS 				;bit9 of addr=0, 20 columns, colorRam at $9400. ; 1216
		sta 	VIC_COLUMNS				;A9:columns
		lda 	#128+ROWS+CHAR16 		;frame1,2*rows,double-height.
		sta 	VIC_ROWS 				;rows
		lda 	#$CC 					;chrset at block 0 [low ram]+A12=$1000.
		sta 	VIC_SCR_CHR_MAP_ADDR	;video ram and char set at $1000.
		rts
	
;SETSCREEN1:	ldy #0 			;column		; 1226
;			ldx #0			;row offset
;			lda #$0F		;first char?
;			sta ch
;
;SSLOOP:			lda 	ch			;get char		; 122D
;				sta 	VIDEO,x		;store char on screen
;
;				lda 	#0
;				sta 	COLOURRAM,x	;clear colours
;
;				inc 	ch 			;next char
;
;				txa
;				clc
;				adc 	#20			;add 20 for next row down?
;				tax 				;displacement is next row
;
;				cmp 	#240 		;acc+ -200
;				bcc 	SSLOOP		; past end of column? if less than 240 (12 increments of 20) then continue filling this column ; 1240
;
;				sbc 	#239 		;next column on the first row.
;				tax
;
;				iny
;				cpy 	#20			; last column
;				bne 	SSLOOP		; 1248
;			rts

SETSCREEN3:	ldx 	#0				; 124c
			lda 	#12
			sta 	row_cnt
			lda 	#$10
			sta 	curr_char
row_loop:		ldy 	#20		; columns
				lda 	curr_char	; get curr char
col_loop: 								; loop 10 times adding 20 to the start of the number
					sta 	VIDEO,X		; store in bitmap
					clc
					adc 	#12		; next column
					inx					; next bitmap pos
					dey
					bne 	col_loop
				inc 	curr_char
				dec 	row_cnt
				bne 	row_loop
				
			ldx		#240
			lda		#2
colourloop:		sta		COLOURRAM-1,X
				dex
				bne		colourloop
			rts

;fill_video_chars ; fill number of 8x16 programmable characters on screen
;    ; fill video characters left to right a full column at a time
;    ldy #0 ; i = 0..bitmap_chars-1(<240) by 1
;    ldx #16 ; j = 16..bitmap_chars+15(<=255) by rows, with adjustment each col
;--  tya
;    clc
;    adc #20
;    sta $fd
;-   txa
;    sta $1000,y
;    clc
;    adc rows
;    tax
;    iny
;    cpy $fd
;    bne -
;+   sec
;    sbc bitmap_chars
;    tax
;    inx
;    cpy bitmap_chars
;    bne --
;    rts
