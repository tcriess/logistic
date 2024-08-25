; logistic.
; 128B Atari ST intro for SillyVenture 2024 WE
; allowed size is actually 160 bytes (32 bytes header + 128 bytes code, which is not quite correct, as the header is only 28 or so bytes)
    text
screenaddr equ $78000
main:
    ; clr.l   -(sp)            ; supervisor mode on
    ; move.w  #$20,-(sp)
    ; trap    #1
    ; addq.l  #6,sp
    ; move.l  d0,sv_ssp

    ; movea.l 4(sp),a0 ; free memory, set stack pointer
    ; lea     stack,sp
    ; move.l  #$100,d0
    ; add.l   $c(a0),d0
    ; add.l   $14(a0),d0
    ; add.l   $1c(a0),d0
    ; move.l  d0,-(sp)
    ; move.l  a0,-(sp)
    ; clr.w   -(sp)
    ; move.w  #$4a,-(sp)
    ; trap    #1
    ; lea     $c(sp),sp

;;; test code, compute the square root of 10
;    moveq #10,d0
;    bsr sqrt
;;; result should be in d1

; main
    ; move.w #$4000,d2 ; d2 = "1 in fixed point via bit-shift by 14"
    move.w #$ffff,d2 ; d2 ~1 in fp
    move.w #150,d6 ; count lines
    move.w #$200,d7 ; d7 = r = 4 -> chaotic (bit-shift 8)
    move.l #screenaddr,a0
    move.w #$0f03,d0 ; d0 = x = "sth. <0.5 in fixed point via bit-shift by 14"
calc:
    ; move.w    #37,-(sp) ; waitvbi
    ; trap      #14
    ; addq.l    #2,sp
    ; move.w d2,d1 ; d1 = one
    ; sub.w d0,d1 ; d1 = 1-x
    move.w d0,d1
    neg.w d1
    mulu.w d0,d1 ; d1 = x*(1-x)
    lsr.l #8,d1
    lsr.l #8,d1 ; fix the bit-shift to be 16 again
    lsr.l #4,d1
    mulu.w d7,d1 ; d1 = r*x*(1-x) 0<=d1<=1 (in fixed point, i.e. 0<=d1<=$4000=16384)
    lsr.w #4,d1
    ; divide by 16 to find the number of words
    ; and.l #$00003FFF,d1
    move.w d1,d0 ; d0 = x
    lsr.w #8,d1
    lsr.w #4,d1
    move.l a0,a1
    moveq #10,d3
drawcls:
    move.l #0,(a1)+
    move.l #0,(a1)+
    dbra d3,drawcls
    move.l a0,a1
draw:
    move.l #$ffffffff,(a1)+ ; plane 0+1
    move.l #$ffffffff,(a1)+ ; plane 2+3
    dbra d1,draw
    adda.l #160,a0
    subq #1,d6
    bne.s calc
    move.l #screenaddr,a0
    move.w #150,d6
    bra.s calc