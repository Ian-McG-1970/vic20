; HiUxLife is a hi-resolution (160x160) version of Life for the Unexpanded VIC-20.

;HiUxLife.s
;assemble with: ./mac2c64 -r blinky.s 
;then rename to .prg.
;Memory map 2:
;$1000            $10c8       $1380        $2000
;[Basic/Video:200][MCode:696b][Chrs:200*16=3200]
;Chars start at $38, which is 896b, the max size for the image.
;Startup is now at end, is 82b long so 896+82=978b for image. 
;By 4:45 on Jan 2, starting to kinda work - scanning OK,
;some calculations appear correct, but there are mistakes.
; But #1: cmp #kRows instead of kRows-1.
; tried to use asr when adjusting neib, use lsr instead.
; Failed to duplicate start of prevRow at end.
;4.2s per generation, 855bytes.
;
; Jobs done:
; Screen setup
; Rnd routine and random initial screen.
; Main body of routine
; First pixel in row calculation.
; @TODO
; -copy current screen row to currRow
; -copy currRow to prevRow
; -last column in calculation should be first column
; -last row should be taken from topRow.
; first row 
; Bonus:
; switch to 19 rows and bottom row is gen count in decimal.
;
;   2012 SYS 4110

VIC						.equ $9000
VIC_COLUMNS 			.equ VIC+$02
VIC_ROWS 				.equ VIC+$03
VIC_SCR_CHR_MAP_ADDR	.equ VIC+$05
COLUMNS 				.equ 20
ROWS					.equ 10*10 ;(10*2)

bitmap 			.equ $1380
kCols 			.equ 20
kRows 			.equ 152
kBmH 			.equ 160
kBitmapSz 		.equ 3200
kBmNextRw 		.equ kBitmapSz-1
kBmEndCol 		.equ 3200-kBmH
kBmEndColDn 	.equ kBmEndCol+1

video			.equ $1000
colorRam 		.equ $9400
cassBuff 		.equ 828 ;to 1019 -818 = 191b. = $33c.

;At the end of the screen we need to calculate the bottom row. The row below is the top row of the screen, but that's been overwritten so we need to pre-save the topRow.

topRow 		.equ cassBuff					;$33c.
prevRow 	.equ topRow+21					;$351
currRow 	.equ prevRow+21 				;$366 63b used.
;ordering for cache block must be this.
cacheTL 	.equ currRow+21					;$37b
cacheL 		.equ currRow+22					;$37c
cacheBL 	.equ currRow+23					;$37d

cacheT 		.equ currRow+24					;$37e
cacheC 		.equ currRow+25					;$37f
cacheB 		.equ currRow+26					;$380

cacheTR 	.equ currRow+27					;$381
cacheR 		.equ currRow+28					;$382
cacheBR 	.equ currRow+29					;$383

colPos 		.equ currRow+30					;$384
newb 		.equ currRow+31

neib 		.equ currRow+32 ;number of alive cells byte.

gRow 		.equ currRow+33

        .org  $1001                          
        .byte $0C $10 $DC $07 
        .byte $9E $20 $34 $32 $39 $36 
        .byte $00 $00 $00 
		; after basic start line
        ; machine code starts at $100e = #4110
VidMore ;$100e, add 10 each time, $e*10 = 140
		;
		.ds 186 ;4097+13+186 = 4296
ptr1 .equ 251
ptr2 .equ 253

main	jsr		startup 		;setup screen and clear it.
		lda 	#192			;initial probability.
	;RND screen.

main10		jsr 	ClsNuRan
			jsr 	ResetPtr1 	;reset ptr1 to beginning of bitmap.

main12		ldy 	#0 			;row 0
main15		ldx 	#8 			;pixels per byte.
	
main20		jsr 	Rnd 		;get next rnd.
			lda 	gSeed+1
			cmp 	ch 			;x+ -192, so>=192 = cy.
			lda 	(ptr1),y
			rol
			sta 	(ptr1),y
			dex
			bne 	main20
			iny
			cpy 	#kRows
			bne 	main15 		;next byte.
			jsr 	Ptr1Col
			lda 	ptr1+1
			cmp 	#$20		;after end of RAM?
			bne 	main12 		;next row.

;In LifeCtr we maintain a running count of the number of live cells. Assume the count is currently in neib, then as we go to the next bit, then set bits on the left would decrement the count and set bits that ;become the right most bits increment the count.
;But what happens at the beginning of a row? The count needs to be set so that the next shift calculates it correctly.
;Also what do we do about the middle bit? Perhaps the easiest way is to modify the output so that if the middle bit is set, then the count should be decremented.

NewGen		jsr 	$FFE4
			sta 	$1fff
			cmp 	#0
			beq 	NewGen05
;We have a keypress, regen.
			cmp 	#65			;cy set if >=65
			bcc 	NewGen01
			sbc 	#65-58 		;7
NewGen01	sec
			sbc 	#48 		;so 65-(65-58) = 58, -48 = 10.
			asl
			asl
			asl
			asl 				;*16 so digits 0 to F give a probability.
			bne 	main10
NewGen05	lda 	#0
			sta 	gRow
			jsr 	ResetPtr1
			jsr 	DoGen
			jsr 	ResetPtr1
			ldx 	#0
NewGen10	ldy #0
			lda 	(ptr1),y
			sta 	topRow,x

;lda #255
;sta (ptr1),y
;jsr pauseRed


			ldy 	#kRows-1	;so the bottom row
			lda 	(ptr1),y
			sta 	currRow,x	;gets copied to the current row.

;lda #255
;sta (ptr1),y
;jsr pauseGreen

			jsr 	Ptr1Col
			inx
			cpx 	#kCols
			bne 	NewGen10
			jsr 	ResetPtr1
			lda 	topRow
			sta 	topRow+kCols

;NewGen20
;	jmp NewGen20

LifeNuRo	ldx 	#0
			ldy 	#0
			lda 	ptr1
			pha
			lda 	ptr1+1
			pha
LifeNuRo10	lda 	currRow,x
			sta 	prevRow,x	;copy current row to the row above.
			lda 	(ptr1),y	;actual current row
			sta 	currRow,x	;is the current row.
	
;lda #255
;sta (ptr1),y
;jsr pauseBlue
	
			jsr 	Ptr1Col
			inx
			cpx 	#kCols
			bne 	LifeNuRo10
			lda 	prevRow
			sta 	prevRow+kCols ;update end of prev row.
			lda 	currRow
			sta 	currRow+kCols ;copy first col to end.
			pla
			sta 	ptr1+1
			pla
			sta 	ptr1 	;restored ptr1 to start of row.

	;now to prime cacheLefts, cache centre and cache bot for this row. But the initial *L cache bytes are in fact the bytes at the end of the top, current and screen rows and the L
	;bytes are the current ones, but we take them from the duplicate ones at the end, because then we can index both.

			ldx 	#1	;src
			ldy 	#3	;dst
LifeNuRo20	lda 	prevRow+kCols-1,x 	;load prevRow+kCols first (i.e. prevRow).
			sta 	cacheTL,y 			;cacheT first
			lda 	currRow+kCols-1,x 	;load currRow+kCols first (i.e. currRow)
			sta 	cacheL,y 			;cacheC first
			lda 	topRow+kCols-1,x
			sta 	cacheBL,y 			;in case at bottom row. 8*160 = about 1ms.
			ldy 	#0					;next loop (second loop), y=0.
			dex
			beq 	LifeNuRo20
	
			lda 	gRow
			cmp 	#kRows-1
			beq 	LifeCtr

;now to prime cacheBottoms. (ptr1) points to the new current row, so the row below is at y=1, unless you're on the bottom row, where we need the top row instead.

			iny					;so y=1 now.
			lda 	(ptr1),y 	;same as bitmap, but 1 byte shorter.
			sta 	cacheB

;lda #$ff
;sta (ptr1),y
;jsr pauseCyan	

			lda 	ptr1+1
			tax
			clc
			adc 	#>kBmEndColDn
			sta 	ptr1+1
			ldy 	#<kBmEndColDn
			lda 	(ptr1),y 		;get the last byte from the row down.
			sta 	cacheBL

;lda #255
;sta (ptr1),y
;jsr pauseYellow

			stx 	ptr1+1			;restore ptr1.

;To prime life ready for the cell calculations
;We need to count the actual number of cells for
;the previous cell, which is:
; TL.1 TL.0 T.7
;  L.1  L.0 C.7
; BL.1 BL.0 B.7
	
LifeCtr		lda 	#0
			sta 	colPos

LifeCtr01	lda 	cacheC
			sta 	newb			;the centre cache byte is basis for newb.
			ldx 	colPos
			lda 	prevRow+1,x
			sta 	cacheTR
			lda 	currRow+1,x
			sta 	cacheR			;cache next prev and curr row bytes.
		
			lda 	gRow
			cmp 	#kRows-1 		;gRow+ -(kRows-1). 
			bne 	LifeCtr02
			lda 	topRow+1,x 		;at the bottom, use topRow (has 21b).
			bcs 	LifeCtr04		;and cy is set by cmp, save 1b.

LifeCtr02	cpx 	#kCols-1
			bne 	LifeCtr03 		;end of a normal row?
;End of a normal row, need to find beginning of that row.
			lda 	ptr1+1
			pha
			ldy 	#33
			clc
			lda 	#256-12
;need to subtract kCols*kBmH
;So offset is 161-kCols*160print
;20*160 = 3200=12.5*256, so sub 13 from hi and add 128
;So 161 -3200 = 161-(12*256+128) = 161-12*256-128
;=161-128
;to y.

			adc 	ptr1+1
			sta 	ptr1+1
			lda 	(ptr1),y
			sta 	cacheBR

			pla
			sta 	ptr1+1 			;restore it (non-zero).
			jmp 	LifeCtr06
LifeCtr03	ldy 	#kBmH+1 		;normally br is next row down and next col
			lda 	(ptr1),y
LifeCtr04	sta 	cacheBR
	
;Now calculate a cell.
;This is still not correct since we actually
;calculate from bit 6.
; Before, so this represents the bits that were
; counted in the first cell and then shifted.
; So the new centre bit is at C.7 and C.6
; TL.0  T.7  T.6
;  L.0       C.6
; BL.0  B.7  B.6

LifeCtr06	ldy 	#8 				;8 cells
LifeCtr07	lda 	#0
			sta 	neib
			ldx		#2 				;3 rows
LifeCtr08	lda 	cacheTL,x		;BL, L, TL.
			ror
			bcc 	LifeCtr10		;if it had been 1 we need to dec count
			inc 	neib			;but the new bit was added 3 loops ago.
LifeCtr10	asl 	cacheTR,x		;BR, R, TR
			rol 	cacheT,x		;B , C, T
			bpl 	LifeCtr12
			inc 	neib
LifeCtr12	bcc 	LifeCtr14
			inc 	neib
LifeCtr14	rol 	cacheTL,x		;BL, L, TL
			dex
			bpl 	LifeCtr08
			
;now neib contains the sum including
;the centre which we need to discard
;e.g. if neib=1 and centre=1, then ~neib+c = -1.
; neib centre	1+ ~neib +centre
;  0     0      1+ 0xff + 0 =0.
;  0     1      1+ 0xff + 1 = 1 (impossible though).
;  1     0      1+ 0xfe + 0 = 0xff = -1
;  1     1      1+ 0xfe + 1 = 0 (correct).
;  2     0      1+ 0xfd + 0 = 0xfe = -2
;  2     1      1+ 0xfd + 1 = 0xff = -1.

			lda		cacheL 			;the centre bit, bit 0.
			lsr 					;so bit 0 in carry now.
			lda 	#1
			sbc 	neib 			;1- -(neib+1) +bit0, result is negated.
			cmp 	#256-2
			beq 	UpdCell50 		;keep current cell if 2.
			cmp 	#256-3
			bne 	UpdCell40		;die if not 2 or 3.
			sec						;born if 3.
			bcs 	UpdCell60
UpdCell40 ;die
			clc
			bcc 	UpdCell60
UpdCell50 ;skip
			lda 	newb
			rol 					;keep old bit by putting it in carry
UpdCell60	rol 	newb 			;intro new bit.
	
			dey
			bne 	LifeCtr07 		;next cell
			lda 	newb
;lda #255
			sta 	(ptr1),y 		;to screen on current line.
	
			lda 	ptr1
			clc
			adc 	#kBmH			;next column in bitmap.
			sta 	ptr1
			bcc 	UpdCell70
				inc 	ptr1+1
UpdCell70	;handle next column
			inc 	colPos
			lda 	colPos
			cmp 	#kCols
			beq 	UpdCell75	;end of row?
;sta bitmap+2
;and #7
;ora #24 ;white paper, not reversed.
;sta 36879	;set border, paper, reverse.
;jsr pause
jmp LifeCtr01	;handle next col

UpdCell75
	;so, we've added 160*kCols by now and need to sub 160*kCols, then add 1.
			inc 	gRow
			sec
			lda 	ptr1
			sbc 	#<kBmNextRw
			sta 	ptr1
			lda 	ptr1+1
			sbc 	#>kBmNextRw
			sta 	ptr1+1
;ldy #0
;lda gRow
;sta bitmap
;UpdCell80
;sta (ptr1),y
;eor #255
;jsr pause
;jmp UpdCell80

			lda 	gRow
			cmp 	#kRows
			beq 	UpdCell90
			jmp		LifeNuRo
UpdCell90	jmp 	NewGen

Ptr1Col		lda 	ptr1
			clc
			adc 	#kBmH		;next column in bitmap.
			sta 	ptr1
			bcc 	Ptr1Col10
				inc 	ptr1+1
Ptr1Col10	rts	

ResetPtr1	lda 	#<bitmap
			sta 	ptr1
			lda 	#>bitmap
			sta 	ptr1+1
			rts

stop		jmp 	stop

RndLslAdd	asl
			rol 	gRndTmp1 		;*8 = 1000
			clc						; not needed?
RndAdc		clc
			adc 	gSeed
			tax
			lda 	gRndTmp1
			adc 	gSeed+1
			sta 	gRndTmp1 		; *9 = 1001
			txa
			rts

;Rnd routine:
;+1,*75, 64+11 = 01001011
Rnd			pha
			txa
			pha
			lda 	gSeed+1
			sta 	gRndTmp1
			lda 	gSeed
			asl
			rol 	gRndTmp1 		;*2 = 10
			asl
			rol 	gRndTmp1 		;*4 = 100
			jsr 	RndLslAdd
			asl
			rol 	gRndTmp1 		;*18 = 10010
			jsr 	RndLslAdd
			asl
			rol 	gRndTmp1 		; *74 = 1001010
			sec						;+1.
			adc 	gSeed
			sta 	gSeed
			lda 	gRndTmp1
			adc 	gSeed+1
			sta 	gSeed+1 		; *37 = 100101
			pla
			tax
			pla
			rts

gSeed		.word $4032
gRndTmp1	.byte 0

DoGen 		ldx 	#0				;increment genStr, and display from col 4
DoGen10		lda 	gGenStr,x
			clc
			adc 	#8
			cmp 	#80
			bcc 	DoGen12
			lda 	#0
DoGen12		sta 	gGenStr,x
			bne 	DoGen14
			inx
			cpx 	#5
			bne 	DoGen10 		;next digit
DoGen14		ldx 	#4				;First skip leading zeros
DoGen20		lda 	gGenStr,x
			bne 	DoGen22 		;found non-zero
			dex
			bne 	DoGen20 		;not reached limit yet.
DoGen22		stx ch
		
DoGen25		ldx 	ch				;Now display all digits.
			lda 	gGenStr,x
			tax
			ldy 	#kBmH-7 		;offset, same every time.
DoGen30		lda 	$8180,x 		;start of char table for digits.
			sta 	(ptr1),y
			inx 					;next source bitmap.
			iny						;next scan down.
			cpy 	#kBmH
			bne 	DoGen30
			jsr 	Ptr1Col
			dec 	ch
			bpl 		DoGen25
			rts						;end because of non-zero result.
	
ch	.byte 0

startup 				;82b long. ;Setup screen and clear it.
	lda #COLUMNS 		;bit9 of addr=0, 20 columns, colorRam at $9400.
	sta VIC_COLUMNS		;A9:columns
	lda #128+ROWS+1 	;frame1,2*rows,double-height.
	sta VIC_ROWS 		;rows

;clear screen.
	ldy #0 			;column
	ldx #0			;offset.
	lda #$38
	sta ch
	
startup10	lda 	ch
			sta 	video,x
			lda 	#0
			sta 	colorRam,x
			inc 	ch 			;next char
			txa
			clc
			adc 	#20
			tax 				;displacement is next row
			cmp 	#200 		;acc+ -200
			bcc 	startup10
			sec					;not needed? as carry is set?
			sbc 	#199 		;next column on first row.
			tax
			iny
			cpy 	#20
			bne 	startup10
;jmp stop

	lda #$cc 					;chrset at block 0 [low ram]+A12=$1000.
	sta VIC_SCR_CHR_MAP_ADDR	;video ram and char set at $1000.
	rts
	
;now fill in the bitmap area: clear screen.
ClsNuRan	sta ch
Cls			lda #0
			sta ptr1
			lda #>gGenStr 	;clear the generation string too.
			sta ptr1+1 		;aligned by page.
			ldy #<gGenStr 	;offset within page.
	
startup20	;Clear screen bitmap.
				lda #0
				sta (ptr1),y 	;store in bitmap
				iny
				bne startup30
					inc ptr1+1 		;inc page.
startup30		lda ptr1+1
				cmp #$20 		;end of char set yet?
				bne startup20 	;next page.
			rts
startupDone

gGenStr	.byte 0,0,0,0,0
