; so we want to load a picture at 0x4000 with loader, not full size for screen 5
; then load this program at 0x8000 with loader, and get the pic on the screen.

; Tasks
; - update loader:
;   - load at address in data.
;   - switch to page in data, in slot 1 or 2, based on address.
;   - only start program if data tells you to.
;v - make picture suitable for screen 5
;v   - c# generator probably.
;v   - the bitmap
;v   - the color codes
; - make program to load picture
;   - change screen 5
;v   - we know dimentions, so load bitmap to vram
;v   - update the color table
;   - bonus: write on hidden vram-page and make visible when ready.
;v   - cant go back to basic, so just DI/HALT.


    .section .text
    .include "macros.asc"

Main:
    push iy                        ; Bewaar IY register heeft basic nodig na ret.
    DI
    
    SetScreen 5

    call Waitvdp
    Color0NotTransparent

    call Waitvdp
    ld HL, CLEARSCREEN             ; make screen clean with hmmv page0
    VdpCopy HMMV, HL

    call Waitvdp
    ld HL, PaletteData
    SetPalette16

    ld HL, PixelData               ; optionally update the dx,dy on de HMMC header
    VdpCopy HMMC, HL               ; zet plaatje op scherm.

    call Waitvdp
    call ClearSAT                  ; Wis alle sprites (Y=208 blokkade weg)
    
    call Waitvdp
    EnableSprites16

    call Waitvdp
    call SetSpriteData             ; Vul SPT, SCT en SAT
    
    call move
    

klaar:
    ld DE, 50
    CALL Wait                      ; Wait <DE> * 0.1 secs.

	; Exit the program and return to MSX-DOS
    CALL ReturnToDos

move:
    ld b, 50
    ld c,0
.loop:
    ld   hl, 0x7600
    SetVramWrite

    ld   a, 50
    out (0x98), a                  ; Y = 50
    ld   a, 50
    add a, c
    out (0x98), a                  ; X = 50+C
    ld a, 0
    out (0x98), a                  ; P = 0-3
    ld   a, 0x40
    out (0x98), a                  ; CC=1 (Gebruik SCT), Kleur=0


    ld   a, 50
    out (0x98), a                  ; Y = 50
    ld   a, 50
    add a, c
    out (0x98), a                  ; X = 50+C
    ld   a, 4
    out (0x98), a                  ; Pattern #4-7
    ld   a, 0x40
    out (0x98), a                  ; CC=1 (Gebruik SCT), Kleur=0


    ld   a, c                      ; move5
    add a, 3
    ld c, a

    push bc
    ld DE, 1
    Call Wait
    pop bc

    djnz .loop


    .include "mockup left.as5"

CLEARSCREEN:
    .word 0, 0, 256, 256           ; HMMV header voor LEEG scherm page0, color 0
    .byte 0, 0

SetSpriteData:
    ; --- 1. SPT: Vorm (7800h) ---
    ld   hl, 0x7800
    SetVramWrite
    ld   hl, SpritePattern
    ld   b, 32 * 2                 ; 16x16 sprite = 32 bytes
.l1:
    ld a, (hl)
    out (0x98), a
    inc hl
    djnz .l1


    ; --- 2. SCT: Kleuren (7400h) ---
    ld   hl, 0x7400
    SetVramWrite
    ld   hl, SpriteColors
    ld   b, 16  *2                 ; 16 lijnen kleur
.l2:
    ld a, (hl)
    out (0x98), a
    inc hl
    djnz .l2

    ; --- 3. SAT: Attributen (7600h) ---
    ld   hl, 0x7600
    SetVramWrite
    ld   a, 50
    out (0x98), a                  ; Y = 50
    ld   a, 50
    out (0x98), a                  ; X = 50
    ld   a, 0
    out (0x98), a                  ; Pattern #0-3
    ld   a, 0x40                   ; 
    out (0x98), a                  ; CC=1 (Gebruik SCT), Kleur=0

    ld   a, 50
    out (0x98), a                  ; Y = 50
    ld   a, 50
    out (0x98), a                  ; X = 50
    ld   a, 4
    out (0x98), a                  ; Pattern #4-7
    ld   a, 0x40
    out (0x98), a                  ; CC=1 (Gebruik SCT), Kleur=0

    ld   a, 216
    out (0x98), a                  ; Y = 216, laatste sprite
    ret

; --- Data definities ---
SpritePattern:
    ; Linkerhelft (8x16)
    .byte 0b11111111
    .byte 0b10110011
    .byte 0b11011110
    .byte 0b11101101
    .byte 0b10111111               ; Rij 1-5
    .byte 0b10111111
    .byte 0b11101101
    .byte 0b11011110
    .byte 0b10110011
    .byte 0b11111111               ; Rij 6-10
    .byte 0,0,0,0,0,0              ; Rij 11-16 leeg
    ; Rechterhelft (8x16)
    .byte 0b11000000
    .byte 0b01000000
    .byte 0b11000000
    .byte 0b11000000
    .byte 0b01000000               ; Rij 1-5 (2px extra = 10 breed)
    .byte 0b01000000
    .byte 0b11000000
    .byte 0b11000000
    .byte 0b01000000
    .byte 0b11000000               ; Rij 6-10
    .byte 0,0,0,0,0,0              ; Rij 11-16 leeg

    ; Linkerhelft (8x16)
    .byte 0b00000000
    .byte 0b01001100
    .byte 0b00100001
    .byte 0b00010010
    .byte 0b01000000               ; Rij 1-5
    .byte 0b01000000
    .byte 0b00010010
    .byte 0b00100001
    .byte 0b01001100
    .byte 0b00000000               ; Rij 6-10
    .byte 0,0,0,0,0,0              ; Rij 11-16 leeg
    ; Rechterhelft (8x16)
    .byte 0b00000000
    .byte 0b10000000
    .byte 0b00000000
    .byte 0b00000000
    .byte 0b10000000               ; Rij 1-5 (2px extra = 10 breed)
    .byte 0b10000000
    .byte 0b00000000
    .byte 0b00000000
    .byte 0b10000000
    .byte 0b00000000               ; Rij 6-10
    .byte 0,0,0,0,0,0              ; Rij 11-16 leeg


SpriteColors:
    .byte 0x29,0x29,0x29,0x29,0x29 ; Rij 1-10: color 9, ~4prio + 2noconflict + ~1noshift
    .byte 0x29,0x29,0x29,0x29,0x29
    .byte 0x20,0x20,0x20,0x20,0x20,0x20 ; Rest transparant, ~4prio + 2noconfilc + ~1noshift

    .byte 0x6A,0x6A,0x6A,0x6A,0x6A ; Rij 1-10: color A, 4noprio + 2noconflict + ~1noshift
    .byte 0x6A,0x6A,0x6A,0x6A,0x6A
    .byte 0x60,0x60,0x60,0x60,0x60,0x60 ; Rest transparant, 4noprio + 2noconflict + ~1noshift



ClearSAT:
    ld   hl, 0x7600
    SetVramWrite
    ld   b, 128                    ; 32 sprites * 4 bytes
.cls:
    xor a
    out (0x98), a
    djnz .cls
    ret
    
