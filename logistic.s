; logistic.
; 128B Atari ST intro for SillyVenture 2024 WE
; allowed size is actually 160 bytes (32 bytes header + 128 bytes code, which is not quite correct, as the header is only 28 or so bytes)
    text
screenaddr equ $78000 ; this is for the 512kb version

linea_init equ $a000
linea_put_pixel equ $a001
linea_arbitrary_line equ $a003
linea_horizontal_line equ $a004
linea_hide_mouse equ $a00a

linea_param_intin equ $08
linea_param_ptsin equ $0c
linea_param_colbit0 equ $18
linea_param_colbit1 equ $1a
linea_param_colbit2 equ $1c
linea_param_colbit3 equ $1e
linea_param_lnmask equ $22
linea_param_wmode equ $24

linea_param_x1 equ $26
linea_param_y1 equ $28
linea_param_x2 equ $2a
linea_param_y2 equ $2c

main:
    ; don't know yet if we will need supervisor mode (would not be required in boot sector!)
    ;clr.l   -(sp)            ; supervisor mode on
    ;move.w  #$20,-(sp)
    ;trap    #1
    ;addq.l  #6,sp
    ; move.l  d0,sv_ssp

    ; hide cursor
    clr.l -(sp)
    move.w #$15,-(sp)
    trap #14
    addq.l #6,sp

    dc.w linea_init
    ; a0 and d0 are destroyed and contain the line-a parameter block

    dc.w linea_hide_mouse

    move.l linea_param_intin(a0),a2
    move.l linea_param_ptsin(a0),a3
    ; a1 and a2 have the addresses of the intin and ptsin arrays

reset_r:
    ; move.w #$20c0,d7 ; d7 = r = 2.0234375 (fixed point, bit-shift 12)
    ; move.w #$2700,d7 ; d7 = r = 2.35
    move.w #$2e08,d7 ; d7 = r = 2.8
    moveq #0,d5 ; current line in d5
calc_line:
    move.w #$7f03,d6 ; d6 = x = "sth. <0.5 in fixed point via bit-shift by 16"
    move.w d5,d0 ; number of points to compute = line number * 4 + 120
    lsl.w #3,d0
    move.w d0,d4 ; save line numer * 8
    add.w #120,d0
    ; move.w #1023,d0 ; compute d0 iterations before drawing
calc: ; d6 is the current x, d7 is the current r, d0 is the iteration counter, d1 is the temp var to compute the new x
    move.w d6,d1 ; d1 = x
    neg.w d1 ; d1 = 1-x (in fixed point shift by 16)
    mulu.w d6,d1 ; d1 = x*(1-x) fixed point 32 bit shift
    clr.w d1 ; clear lower word, which will end up in the high word after the following swap
    swap d1 ; fix the bit-shift to be 16 again
    ; d1.w = x*(1-x) fixed point 16 bit shift
    mulu.w d7,d1 ; d1.l = r*x*(1-x) fixed point 28 bit shift
    lsr.l #8,d1
    lsr.l #4,d1 ; d1.w = r*x*(1-x) fixed point 16 bit shift
    move.w d1,d6 ; d6 = new x
    subq #1,d0
    cmp d4,d0
    bge.s calc ; d>=0 -> continue loop

    ; now we draw the next points until d0 reaches -100
    tst d0
    ble.s next

    lsr.w #7,d1 ; d1 = 0..1 fixed point 9 bit shift (i.e. 0..511)
    add.w #60,d1 ; slightly shift to the right

    ;movem.l d0-d7/a0-a6,-(sp)
    ;clr.w linea_param_x1(a0)
    ;move.w d5,linea_param_y1(a0)
    ;move.w #639,linea_param_x2(a0)
    ;move.w d5,linea_param_y2(a0)
    ;clr.l linea_param_colbit0(a0)
    ;clr.l linea_param_colbit3(a0)
    ;move.w #$ffff,linea_param_lnmask(a0)
    ;clr.w linea_param_wmode(a0)
    ;dc.w linea_arbitrary_line
    ;movem.l (sp)+,d0-d7/a0-a6

    ;movem.l d0-d7/a0-a6,-(sp)
    ;move.w d1,linea_param_x1(a0)
    ;move.w d5,linea_param_y1(a0)
    ;move.w d1,linea_param_x2(a0)
    ;move.w #199,linea_param_y2(a0)
    ;move.l #$ffffffff,linea_param_colbit0(a0)
    ;clr.l linea_param_colbit3(a0)
    ;move.w #$ffff,linea_param_lnmask(a0)
    ;clr.w linea_param_wmode(a0)
    ;dc.w linea_arbitrary_line
    ;movem.l (sp)+,d0-d7/a0-a6

    move.w #7,0(a2) ; color in intin[0]
    move.w d1,0(a3) ; x-coordinate in ptsin[0]
    move.w d5,2(a3) ; for now: keep y = 0

    movem.l d0-d7,-(sp)
    dc.w linea_put_pixel
    movem.l (sp)+,d0-d7
    bra.s calc

next:
    addq #1,d5
    ; add.w #$28,d7 ; if start value is $20c0 -> 200 lines
    ; add.w #32,d7 ; if start value is $2700 -> 200 lines
    add.w #23,d7 ; if start value is $2e08 -> 200 lines
    cmp.w #$4000,d7
    ble.s calc_line
    bra.s reset_r
