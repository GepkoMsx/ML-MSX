; load the banner on screen 8
;; its too big, so we got 6 pictures 
;; (to save bytes in the corners and get 2 blocks of 16kb)
;;
;;                top
;; left leftcenter rigthcenter right
;;              bottom
;;
;; load sequence: L, LC, T -> segment 4
;;                B, RC, R -> segment 5
;;
;; We can optimize loading by combining the 2 sets into 1 file each
;; loader will load them
;;
;; so loader loads pics in segment 4 and 5, we are loaded afterwards in segment 3
;; The pictures dont have a HMMC header..

; ==[ Constants ]===============================================
    include "Constants.as"

MEMNRBANKS  equ $D28A   ; copied from loader.sym
MEMPAGE3    equ $D28B   ; copied from loader.sym

; ==[ Header ]==================================================
    org $8000
    include "BloadHeader.as"

; ==[ Program ]=================================================
Main:                   
   
    include "setupScreen.as"    ; - Screen 8, switch to page 2 visible
                                ; - make both pages black backgrond and border

    ld b, 4             ; Swap segment 4 in: first set of pictures for logo
    ld c, $FD
    call MemLoadSegment

    ld HL, PIXELADDRES  ; setup shadow for pixel work, and normal for HMMC work
    EXX

    ld HL, PICTURES
    ld b, 3            
    call LogoLoop    

    ld b, 5             ; Swap segment 5 in: second set of pictures for logo
    ld c, $FD
    call MemLoadSegment ; HL is safe

    ld b, 3            
    call LogoLoop

                        
    ld a, %00011111     ; Switch to VRAM page 1
    out (#99), a        ; Bit 6 bepaalt de pagina (0 voor Page 0, 1 voor Page 1)
    ld a, 128 + 2       ; Schrijf naar VDP Register 2
    out (#99), a

; tekst plaatsen.
    ld HL, LOGOTEXT     ; location to X (1),Y (1), text (bytes)
    ld b, 22            ; length of text
    ld c, $BC           ; color
    call WriteString8

; keyboard test
    ld HL, BLACKSCREEN  ; make screen black with hmmv
                        ; fill in DX, DY, NX, NY
    ld a, 256/2-4:  ld (HL),a : inc hl       
    ld a, 0:        ld (HL),a : inc hl           
    ld a, 190+13:   ld (HL),a : inc hl           
    ld a, 0:        ld (HL),a : inc hl           
    ld a, 16:        ld (HL),a : inc hl           ;; do 2 characters
    ld a, 0:        ld (HL),a : inc hl           
    ld a, 12:       ld (HL),a : inc hl           
    ld a, 0:        ld (HL),a : inc hl

WAITTEST:
    ld DE, 50       ;5 sec
    call Wait

; tekst wissen.
    ld HL, LOGOTEXT     ; location to X (1),Y (1), text (bytes)
    ld b, 22            ; length of text
    ld c, 0             ; color
    call WriteString8


KEYBOARDTEST:
    ; call GetBiosKey    ; a is first key in ascii, or 0 for no key
    call GetActionKeys
;; bit   7    6    5    4    3       2     1    0
;;       →	  ↓	   ↑    ←  return   tab   esc space

    ;;or a
    ;;jp z, KEYBOARDTEST   ; no key

    push af
    ld HL, BLACKSCREEN  ; clean prev key
    call HMMV
    call waitvdp

    pop af
    ;; add
    call ToHex          ; DE has the 2 letters.
    ld a, D
    push de
    ;; end add

    ld DE, $7CCB        ; center under press any key
    ld b, $FF           ; white
    call WriteLetter8   ; A ascii letter, B color, DE location (x,y)

    ;; add
    pop de
    ld a, E

    ld DE, $84CB        ; center under press any key
    ld b, $FF           ; white
    call WriteLetter8   ; A ascii letter, B color, DE location (x,y)
    ;; end add

    jp KEYBOARDTEST




    DI                  ; and thats it.
    HALT


; ==[ libs ]====================================================
    include "waitvdp.asc"
    include "hmmv.asc"
    include "memLoadSegment.asc"
    include "writeLetter8.asc"
    include "multiply.asc"
    include "logoloop.asc"
    include "writeString8.asc"
    include "getfirstkey.asc"
    include "getBiosKey.asc"
    include "getactionkeys.asc"
    include "tohex.asc"
    include "wait.asc"

; ==[ Data ]====================================================
LOGOTEXT:
    db 44, 190, "Press any key to start" ; X, Y, tekst 
                        ; X = (256-22*8)/2  ; 22 letters
                        ; Y = 175 + (37-FONT_HEIGHT)/2
BLACKSCREEN:
    dw 0, 0, 256, 212   ; HMMV header voor zwart scherm page0
    db 0, 0, $C0
    dw 0, 256, 256, 212 ; HMMV header voor zwart scherm page1
    db 0, 0, $C0
PIXELADDRES:
    dw 115*29,  $4000   ;  nr of bytes and address
    dw 28*82,   $4D07   
    dw 96*112,  $55FF

    dw 103*112, $4000
    dw 27*82,   $6D10
    dw 77*34,   $75B6

PICTURES:
    dw 71,0,115,29      ; top HMMC
    db 0, 0, $F0
    dw 1, 46, 28, 82    ; left HMMC
    db 0, 0, $F0
    dw 29, 29, 96, 112  ; Left center HMMC
    db 0, 0, $F0
    dw 125, 29, 103, 112 ; right center HMMC
    db 0, 0, $F0
    dw 228, 47, 27, 82  ; right HMMC
    db 0, 0, $F0
    dw 90, 141, 77, 34  ; bottom HMMC
    db 0, 0, $F0

    include "font.inc"
FileEnd: