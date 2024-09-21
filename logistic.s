; logistic.
; 128B Atari ST intro for SillyVenture 2024 WE
; allowed size is actually 160 bytes (32 bytes header + 128 bytes code, which is not quite correct, as the header is only 28 or so bytes)
    text
screenaddr equ $78000 ; this is for the 512kb version
main:
    ; clr.l   -(sp)            ; supervisor mode on
    ; move.w  #$20,-(sp)
    ; trap    #1
    ; addq.l  #6,sp
    ; move.l  d0,sv_ssp

    move.l #screenaddr,a6 ; screen address in a6
reset_r:
    move.w #$20c0,d7 ; d7 = r = 2.0234375 (fixed point, bit-shift 12)
    ; move.w #200,d5 ; line count

calc_line:
    ; clear complete screen
    move.l a6,a5
    move.w #40*200-1,d4
clrline:
    move.l #0,(a5)+
    dbra d4,clrline

    move.w    #37,-(sp) ; waitvbi
    trap      #14
    addq.l    #2,sp


    move.w #$7f03,d6 ; d6 = x = "sth. <0.5 in fixed point via bit-shift by 16"
    moveq #100-1,d0 ; compute d0 iterations before drawing
calc:
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
    bge.s calc
    
    ; now we draw the next points until d0 reaches -100
    cmp.w #-100,d0
    ble.s next

    lsr.w #8,d1 ; d1 = 0..1 fixed point 8 bit shift (i.e. 0..255)
    ; move.w d1,d0
    ; and.w #$000f,d0 ; which pixel
    and.w #$00f0,d1 ; which 16-pixel-segment
    lsr.w #1,d1
    move.l a6,a5
    move.w #200-1,d5
fullscr:
    move.l #$ffffffff,(a5,d1.w)
    move.l #$ffffffff,4(a5,d1.w)
    adda.l #160,a5 ; next line
    dbra d5,fullscr ; 200x, fill from top to bottom
    bra.s calc
next:
    ; next line
    ; adda.l #160,a5
    ; subq.w #1,d5
    ; bge.s calc_line
    ; move.w    #37,-(sp) ; waitvbi
    ; trap      #14
    ; addq.l    #2,sp
    add.w #$28,d7
    cmp.w #$4000,d7
    ble.s calc_line
    bra.s reset_r

    ; move.l a6,a5 ; back to the first line

;; main
;    ; move.w #$4000,d2 ; d2 = "1 in fixed point via bit-shift by 14"
;    ; move.w #$ffff,d2 ; d2 ~1 in fp shift 16
;    move.w #150,d6 ; count lines
;    move.w #$2000,d7 ; d7 = r = 2 -> start there, go up to 4 (chaotic) (bit-shift 12)
;    move.l #screenaddr,a6
;    move.w #$7f03,d5 ; d5 = x = "sth. <0.5 in fixed point via bit-shift by 16"
;calc0:
;    move.w    #37,-(sp) ; waitvbi
;    trap      #14
;    addq.l    #2,sp
;calc:
;    moveq #10,d3
;    move.w #10,d4
;calc1:
;    ; move.w    #37,-(sp) ; waitvbi
;    ; trap      #14
;    ; addq.l    #2,sp
;    ; move.w d2,d1 ; d1 = one
;    ; sub.w d0,d1 ; d1 = 1-x
;    move.w d5,d1
;    neg.w d1     ; this should end up being 1-x in the 16-bit-shift (excluding 0 and 1)
;    mulu.w d5,d1 ; d1 = x*(1-x)
;    clr.w d1 ; clear lower word, which will end up in the high word after the following swap
;    swap d1 ; fix the bit-shift to be 16 again
;    ; lsr.l #8,d1
;    ; lsr.l #8,d1 ; fix the bit-shift to be 16 again
;    ; lsr.l #4,d1
;    mulu.w d7,d1 ; d1 = r*x*(1-x) 0<=d1<=1 (in fixed point, i.e. 0<=d1<=$4000=16384)
;    lsr.l #4,d1
;    lsr.l #8,d1 ; make bit-shift 16 again
;    ; divide by 16 to find the number of words
;    ; and.l #$00003FFF,d1
;    move.w d1,d5 ; d5 = x
;    dbra d4,calc1
;
;    lsr.w #8,d1
;    lsr.w #4,d1 ; shift by 12 bits, i.e. we have values 0..15 in d1 now
;    ; move.w    #37,-(sp) ; waitvbi
;    ; trap      #14
;    ; addq.l    #2,sp
;    ; move.l a6,a1
;    lsl.w #3,d1 ; *8
;    move.l #$ffffffff,0(a6,d1.w)
;    moveq #0,d4
;    dbra d3,calc1
;    ; moveq #10,d3
;; drawcls:
;    ; move.l #0,(a1)+
;    ; move.l #0,(a1)+
;    ; dbra d3,drawcls ; clear background
;    ; move.l a6,a1
;; draw:
;    ; move.l #$ffffffff,(a1)+ ; plane 0+1
;    ; move.l #$ffffffff,(a1)+ ; plane 2+3
;    ; dbra d1,draw ; mark as many as in d1
;    adda.l #160,a6 ; next line
;    add.w #$0005,d7 ; add a bit to r
;    cmp.w #$4000,d7
;    subq #1,d6
;    bne.s calc
;    ; move.w    #37,-(sp) ; waitvbi
;    ; trap      #14
;    ; addq.l    #2,sp
;    ; move.l #screenaddr,a6
;    ; move.w #150,d6
;    move.l #screenaddr,a6
;    cmp.w #$4000,d7
;    ble.s calc0
;    move.l #screenaddr,a6
;    move.l a6,a1
;    move.w #8000,d7
;clrscr:
;    clr.l (a1)+
;    dbra d7,clrscr
;    move.w #$2000,d7
;    bra.s calc0