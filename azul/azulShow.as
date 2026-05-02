; .org 0x8000

;; the first screen tht shows the logo (banner2.RL8)
;; autostarted by the loader.
;;
;; load the banner on screen 8
;; its too big, so we got RLE encoded picture
    
; Loads the wait-screen

    .section .text

    .include "Macros.asc"

Main:
    DI
    ld bc, 0x0101                   ; Swap picture index 1 in memory 0x4000
    call MEMRESET
    
    SetScreen 8, off
    
    SetVDP 7, 0                     ; Border color 0
    
    ld HL, BLACKSCREEN             ; make screen black with hmmv page 0
    call HMMV
    call Waitvdp
    
    ld HL, HMMCDATA                ; prepare copy picture.
    call HMMCNoData                

    ld HL, 0x4000                  ; NOW THE RLE TRICK
    call RLESendVDP
    
    SetVDP 1, 0x40                 ; Screen on
    
    EI
    ret


    .section .data
        
BLACKSCREEN:                       ; HMMV header voor zwart scherm page0
    .word 0, 0                     ; dx,dy
    .word 256, 256                 ; mx, my
    .byte 0x00, 0x00, 0xC0         ; col, arg, HMMV

HMMCDATA:
    .word 6, 0                     ; dx,dy
    .word 244, 166                 ; mx,my
    .byte 0x00, 0x00, 0xF0         ; col, arg, HMMC
    
    