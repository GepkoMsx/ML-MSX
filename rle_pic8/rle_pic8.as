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
    call MemPrepare
    ld BC, 0x0201                  ; B = segmentindex, C =  Page (Seg 2 on 4000)
    CALL MEMRESET                  ; Works cause loader still in page 0

    SetScreen 8
    call Waitvdp

    ld a, 0                        ; set Border: Kleurnummer (0-15)
    out (0x99), a                  ; Stuur waarde naar poort 0x99
    ld a, 0x87                     ; 128 (Register schrijven) + 7 (Registernummer)
    out (0x99), a
    call Waitvdp


    VdpCopy VDP_HMMV, BLACKSCREEN
    call Waitvdp

    VdpCopy VDP_HMMC, HMMCDATA
    setVDP 17, 0x80+44             ; geen increment ($80) naar register 44
    ld HL, 0x4000                  ; NOW THE RLE TRICK
    ld DE, 254*177                 ; bytes to send (1st is controlbyte)
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
    .word 0, 0, 254, 177           ; dx, dy, mx, my
    .byte 0, 0                     ; col, arg

BLACKSCREEN:
    .word 0, 0, 256, 256           ; HMMV header voor zwart scherm page0
    .byte 0, 0
