; .org 0x8000

; RLE_PIC8
; assumes a 'gepko's RLE' screen 8 picture is loaded at 0x4000
; we work with picture banner2.RL8. its 15366 bytes compressed.
; We send them to the screen while decoding. 
;
; memory management is already done by loader, we're lucky :)

    .section .text
    .nolist
    .include "Macros.asc"
    .list

    di
    ld BC, 0x0201                  ; B = segmentindex, C =  Page (Seg 2 on 4000)
    CALL MEMRESET                  ; Works cause loader still in page 0

    SetScreen 8, on
    SetVDP 2, 0x1F                 ; Set the table base registers
    SetVDP 5, 0xEF
    SetVDP 6, 0x03

    SetVDP 7, 0                    ; Set Border: color 0, register 7

    VdpCopy VDP_HMMV, BLACKSCREEN
    call Waitvdp
    

    VdpCopy VDP_HMMC, HMMCDATA
    SetVDP 17, 0x80+44             ; geen increment ($80) naar register 44
    ld HL, 0x4000                  ; NOW THE RLE TRICK
   ; ld DE, 254*177                 ; bytes to send (1st is controlbyte)
    call RLESendVDP
    
theend:
    jr theend

    SetScreen 0
    call Waitvdp
    setVDP 7, 0xF4                 ; set Border: Kleurnummer (0-15)
    ei
    ret

    .section .data

HMMCDATA:
    .word 6, 0, 244, 166           ; dx, dy, mx, my
    .byte 0, 0                     ; col, arg

BLACKSCREEN:
    .word 0, 0, 256, 256           ; HMMV header voor zwart scherm page0
    .byte 0, 0
