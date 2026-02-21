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
    org $9000
    include "BloadHeader.as"

; ==[ Program ]=================================================
Main:                   
    push iy             ; Bewaar IY register heeft basic nodig na ret.
    
    ld a, 5
    call CHGMOD         ; goto screen 5;

    call waitvdp
    call color0NotTransparent

    call waitvdp
    ld HL, PaletteData
    call SetPalette16

    ;call waitvdp
    ld HL, PixelData    ; optionally update the dx,dy on de HMMC header
    call HMMC           ; zet plaatje op scherm.

klaar:
    jp klaar


   

; ==[ libs ]====================================================
    include "waitvdp.asc"
    include "color0NotTransparent.asc"
    include "setPalette.asc"
    include "multiply.asc"
    include "HMMC.asc"
; ==[ Data ]====================================================

    include "mockup left.as5"
FileEnd: