; RLE_PIC8
; assumes a 'gepko's RLE' screen 8 picture is loaded at $4000
; we work with picture banner2.RL8. its 15366 bytes compressed.
; We send them to the screen while decoding. 
;
; memory management is already done by loader, we're lucky :)

; ==[ Constants ]===============================================
    include "Constants.as"

    org $8000

; ==[ Program ]=================================================
Main:
    di 

    ld BC, $0201            ; B = segmentindex, C =  Page (Seg 2 on 4000)
    CALL MEMRESET           ; Works cause loader still in page 0

    ld HL, Screen8_Table
    call screen
    call waitvdp 

    ld a, 0             ; set Border: Kleurnummer (0-15)
    out (#99), a        ; Stuur waarde naar poort #99
    ld a, $87           ; 128 (Register schrijven) + 7 (Registernummer)
    out (#99), a
    call waitvdp 

    ld HL, BLACKSCREEN  ; make screen black with hmmv
    call HMMV
    call waitvdp 

    ld HL, HMMCDATA
    call HMMCNoData     ; prepare copy picture.

    ld HL, $4000        ; NOW THE RLE TRICK
    ld de, 254*177      ; bytes to send (1st is controlbyte)
    call RLESendVDP
    
theend:
    jr theend

    ld HL, Screen0_Table
    call screen
    call waitvdp 
    ld a, $F4           ; set Border: Kleurnummer (0-15)
    out (#99), a        ; Stuur waarde naar poort #99
    ld a, $87           ; 128 (Register schrijven) + 7 (Registernummer)
    out (#99), a
    ei
    ret 

; ==[ libs ]====================================================
    include "waitvdp.asc"
    include "hmmcNoData.asc"
    include "RLESendVDP.asc"
    include "multiply.asc"
    include "hmmv.asc"
    include "hmmm.asc"
    include "screen.asc"

; ==[ Data ]===================================================
HMMCDATA:
    dw 0, 0             ; dx,dy
    dw 254, 177         ; mx,my
    db 0, 0, $F0        ; col, arg, HMMC
BLACKSCREEN:
    dw 0, 0, 256, 256   ; HMMV header voor zwart scherm page0
    db 0, 0, $C0

FileEnd: