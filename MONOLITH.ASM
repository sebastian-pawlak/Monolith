; "Monolith", Atari XL/XE Intro 256B
; music by Richard Strauss, "Also sprach Zarathustra"
; code by tr1x / Agenda
; requirements: original Atari XL/XE 64KB PAL
; version: 1.0
; release date: 2020-12-12

value	equ $00fe
delta	equ $00c2
notes	equ $00c3

rowcrs	equ $0054
colcrs	equ $0055
oldrow	equ $005a
oldcol	equ $005b
gprior	equ $026f
pcolr0	equ $02c0
atachr	equ $02fb
hposp0	equ $d000
hposp1	equ $d001
hposp2	equ $d002
grafp0	equ $d00d
audf1	equ $d200
audc1	equ $d201
random	equ $d20a
wsync	equ $d40a
vcount	equ $d40b
osgraph	equ $ef9c
osdraw	equ $f9c2


	org $00ff-$0c

monwth1	.byte $13
monwth2	.byte $03
monrow2	.byte $36
hillwth	.byte $50
colors	.byte $2c, $36, $42, $00, $90, $52, $54
valueva	.byte $91


	org $2000

start	lda #$0f
	jsr osgraph


	; set color palette
	ldy #$06
loopa1	lda colors,y
	sta pcolr0,y
	txa
	sta grafp0,y
	dey
	bpl loopa1


	; draw hill
loopb1	ldy hillwth
	sty colcrs
	sty oldcol

	lda value+1
	adc delta
	sta value+1
	lda value+0
	adc #$00		; accumulate carry flag
	sta value+0

	sta audc1		; luckily, it works

	sta rowcrs
	pha
	jsr aux2

	lda hillwth
	eor #$7f
	adc #$20
	sta colcrs
	sta oldcol
	
	pla
	sta rowcrs
	jsr aux2

	inc delta
	inc delta

	dec hillwth
	bne loopb1


	; draw monolith
	lda #$46
	sta oldcol
	sta colcrs
	lda #$a6
	sta rowcrs

loopc1	lda #$36
	jsr aux1
	dec monwth1
	bne loopc1

	inc atachr
loopc2	dec rowcrs
	dec rowcrs
	inc monrow2
	lda monrow2
	jsr aux1
	dec monwth2
	bne loopc2


	; initialization of positions of stars
	dey		; y = 0 before "dey"
loopd1	lda random
	sta starpos,y
	dey
	bne loopd1

	; push PMG behind graphics
	ldy #$04
	sty gprior

	; starfield
loopd2	lda vcount
	;sta wsync	; not necessary
	bne loopd2
	tax		; ldx #$00
loopd3	inc starpos,x
	lda starpos,x	
	ldy #$02
	sta wsync
loopd4	sta hposp0,y
	asl
	dey
	bpl loopd4
	dex
	cpx #$37
	bne loopd3
	sty hposp0
	sty hposp1
	sty hposp2

	; play music
	lda notes
	lsr
	lsr
	lsr
	lsr
	tay
	lda music,y
	sta audf1
	inc notes

	bvc loopd2


aux1	sta oldrow
	jsr osdraw
	inc colcrs
	inc oldcol
	rts


aux2	lda #$c0
	sta oldrow
	dex
	stx atachr
	jsr osdraw

	lda random
	and #$0f
	adc rowcrs
	sta rowcrs
	inc atachr
	jsr $f1d8
	rts


	; "Also sprach Zarathustra", Richard Strauss
music	.byte 121, 121, 121, 81, 81, 81, 60, 60, 60, 0, 47, 50, 50

	; positions of stars
starpos	equ *+6


	run start