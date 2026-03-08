; so we want to load a picture at $4000 with loader, not full size for screen 5
; then load this program at $8000 with loader, and get the pic on the screen.

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


; ==[ Constants ]===============================================
    include "Constants.as"

; ==[ Header ]==================================================
    org $0100
    

; ==[ Program ]=================================================
Main:
    push iy                  ; Bewaar IY register heeft basic nodig na ret.
    DI
    
    ld hl, Screen5_Table
    CALL Screen              ; Change screenmode. <HL> address of table in this file.

    call Waitvdp
    call color0NotTransparent

    call Waitvdp
    ld HL, CLEARSCREEN       ; make screen clean with hmmv page0
    call HMMV

    call Waitvdp
    ld HL, PaletteData
    call SetPalette16

    ld HL, PixelData         ; optionally update the dx,dy on de HMMC header
    call HMMC                ; zet plaatje op scherm.

    call Waitvdp
    call ClearSAT            ; Wis alle sprites (Y=208 blokkade weg)
    
    call Waitvdp
    call EnableSprites16

    call Waitvdp
    call SetSpriteData       ; Vul SPT, SCT en SAT
    
    call move
    

klaar:
    ld DE, 50
    CALL Wait                ; Wait <DE> * 0.1 secs.

	; Exit the program and return to MSX-DOS
    include "ReturnToDos.as"

move:
    ld b, 50
    ld c,0
.loop:
    ld   hl, $7600
    call SetVramWrite

    ld   a, 50
    out ($98), a             ; Y = 50
    ld   a, 50
    add a, c
    out ($98), a             ; X = 50+C
    ld a, 0
    out ($98), a             ; P = 0-3
    ld   a, $40
    out ($98), a             ; CC=1 (Gebruik SCT), Kleur=0


    ld   a, 50
    out ($98), a             ; Y = 50
    ld   a, 50
    add a, c
    out ($98), a             ; X = 50+C
    ld   a, 4
    out ($98), a             ; Pattern #4-7
    ld   a, $40
    out ($98), a             ; CC=1 (Gebruik SCT), Kleur=0


    ld   a, c                ; move5
    add a, 3
    ld c, a

    push bc
    ld DE, 1
    Call Wait
    pop bc

    djnz .loop



; ==[ libs ]====================================================
    include "waitvdp.asc"
    include "color0NotTransparent.asc"
    include "setPalette16.asc"
    include "multiply.asc"
    include "HMMC.asc"
    include "HMMV.asc"
    include "screen.asc"
    include "wait.asc"
    include "EnableSprites16.asc"
    include "SetVramWrite.asc"
; ==[ Data ]====================================================

    include "mockup left.as5"

CLEARSCREEN:
    dw 0, 0, 256, 256        ; HMMV header voor LEEG scherm page0, color 0
    db 0, 0, $C0

FileEnd:






SetSpriteData:
    ; --- 1. SPT: Vorm (7800h) ---
    ld   hl, $7800
    call SetVramWrite
    ld   hl, SpritePattern
    ld   b, 32 * 2           ; 16x16 sprite = 32 bytes
.l1:
    ld a, (hl)
    out ($98), a
    inc hl
    djnz .l1


    ; --- 2. SCT: Kleuren (7400h) ---
    ld   hl, $7400
    call SetVramWrite
    ld   hl, SpriteColors
    ld   b, 16  *2           ; 16 lijnen kleur
.l2:
    ld a, (hl)
    out ($98), a
    inc hl
    djnz .l2

    ; --- 3. SAT: Attributen (7600h) ---
    ld   hl, $7600
    call SetVramWrite
    ld   a, 50
    out ($98), a             ; Y = 50
    ld   a, 50
    out ($98), a             ; X = 50
    ld   a, 0
    out ($98), a             ; Pattern #0-3
    ld   a, $40              ; 
    out ($98), a             ; CC=1 (Gebruik SCT), Kleur=0

    ld   a, 50
    out ($98), a             ; Y = 50
    ld   a, 50
    out ($98), a             ; X = 50
    ld   a, 4
    out ($98), a             ; Pattern #4-7
    ld   a, $40
    out ($98), a             ; CC=1 (Gebruik SCT), Kleur=0

    ld   a, 216
    out ($98), a             ; Y = 216, laatste sprite
    ret

; --- Data definities ---
SpritePattern:
    ; Linkerhelft (8x16)
    db %11111111
    db %10110011
    db %11011110
    db %11101101
    db %10111111             ; Rij 1-5
    db %10111111
    db %11101101
    db %11011110
    db %10110011
    db %11111111             ; Rij 6-10
    db 0,0,0,0,0,0           ; Rij 11-16 leeg
    ; Rechterhelft (8x16)
    db %11000000
    db %01000000
    db %11000000
    db %11000000
    db %01000000             ; Rij 1-5 (2px extra = 10 breed)
    db %01000000
    db %11000000
    db %11000000
    db %01000000
    db %11000000             ; Rij 6-10
    db 0,0,0,0,0,0           ; Rij 11-16 leeg

    ; Linkerhelft (8x16)
    db %00000000
    db %01001100
    db %00100001
    db %00010010
    db %01000000             ; Rij 1-5
    db %01000000
    db %00010010
    db %00100001
    db %01001100
    db %00000000             ; Rij 6-10
    db 0,0,0,0,0,0           ; Rij 11-16 leeg
    ; Rechterhelft (8x16)
    db %00000000
    db %10000000
    db %00000000
    db %00000000
    db %10000000             ; Rij 1-5 (2px extra = 10 breed)
    db %10000000
    db %00000000
    db %00000000
    db %10000000
    db %00000000             ; Rij 6-10
    db 0,0,0,0,0,0           ; Rij 11-16 leeg


SpriteColors:
    db $29,$29,$29,$29,$29   ; Rij 1-10: color 9, ~4prio + 2noconflict + ~1noshift
    db $29,$29,$29,$29,$29
    db $20,$20,$20,$20,$20,$20 ; Rest transparant, ~4prio + 2noconfilc + ~1noshift

    db $6A,$6A,$6A,$6A,$6A   ; Rij 1-10: color A, 4noprio + 2noconflict + ~1noshift
    db $6A,$6A,$6A,$6A,$6A
    db $60,$60,$60,$60,$60,$60 ; Rest transparant, 4noprio + 2noconflict + ~1noshift



ClearSAT:
    ld   hl, $7600
    call SetVramWrite
    ld   b, 128              ; 32 sprites * 4 bytes
.cls:
    xor a
    out ($98), a
    djnz .cls
    ret
    
