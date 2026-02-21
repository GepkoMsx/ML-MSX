; RLE_PIC8
; assumes a 'gepko's RLE' screen 8 picture is loaded at $4000
; we work with picture banner2.RL8. its 15366 bytes compressed.
; We send them to the screen while decoding. 

; ==[ Constants ]===============================================
    include "Constants.as"

MEMNRBANKS  equ $D28A   ; copied from loader.sym
MEMPAGE3    equ $D28B   ; copied from loader.sym

    org $8000
    include "BloadHeader.as"

; ==[ Program ]=================================================
Main:
    ld a, 8             ; set VDP to screen 8
    call CHGMOD
    call waitvdp

    ld a, 0             ; set Border: Kleurnummer (0-15)
    out (#99), a        ; Stuur waarde naar poort #99
    ld a, 128 + 7       ; 128 (Register schrijven) + 7 (Registernummer)
    out (#99), a
    call waitvdp

    ld HL, BLACKSCREEN  ; make screen black with hmmv
    call HMMV
    call waitvdp


    ld HL, HMMCDATA
    call HMMCNoData     ; prepare copy picture.


; NOW THE RLE TRICK
    ld HL, $4000    
    ld c, (hl)          ; RLE's controlbyte
    inc HL

    ld de, 254*177-1    ; bytes to send (1st is controlbyte)
HMMCPixelLoop:
    ld a, (HL)          ; a = de byte to send
    inc HL

; do RLE magic.
;; Bytes worden onveranderd doorgelaten (RAW), behalve de controlbyte
;; De controlbyte wordt gekozen als minst gebruitke byte in het bestand. 
;; Dit is de 1e byte in het RLE bestand.
;; - control byte gevolgd door $00 is escape ---> controlbyte
;; - anders 2e byte is aantal, 3e byte is de herhaalbyte
    cp a,c              ; is a de control?
    jr nz, HMMCWriteByte

    ; ja
    ld a, (HL)         ; 2e byte
    inc HL             ; a = 0, escape
    or a
    jr Z, RLE_Escape

    ;nee, a = herhaalbyte
    ld b, a
    ld a, (HL)
    inc HL
RLE_LOOP:
    out (VDPR), a
    dec de
    djnz RLE_LOOP    
    jr HMMCPixelLoop

RLE_Escape:
    ld a, c             ; send the control

HMMCWriteByte:
    out (VDPR), a       ; VDP zet deze pixel op de volgende positie
    dec de
    ld a, d
    or e
    jr nz, HMMCPixelLoop


theend:
    HALT
    jr theend;






; ==[ libs ]====================================================
    include "waitvdp.asc"
    include "hmmcNoData.asc"
    include "memLoadSegment.asc"
    include "multiply.asc"
    include "hmmv.asc"
; ==[ Data ]===================================================
HMMCDATA:
    dw 0, 0             ; dx,dy
    dw 254, 177         ; mx,my
    db 0, 0, $F0        ; col, arg, HMMC
BLACKSCREEN:
    dw 0, 0, 256, 212   ; HMMV header voor zwart scherm page0
    db 0, 0, $C0

FileEnd: