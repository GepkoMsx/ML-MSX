
;; the first screen tht shows the logo (banner2.RL8)
;; autostarted by the loader.
;;
;; load the banner on screen 8
;; its too big, so we got RLE encoded picture
    
; Loads the wait-screen

; ==[ Constants ]===============================================
    include "Constants.as"

    org $8000
    
; ==[ Program ]======================================
Main:
    DI
    ld bc, $0101             ; Swap picture index 1 in memory $4000
    call MEMRESET
    
    ld HL, Screen8_Table     ; SCREEN 8
    call screen              ; starts disabled.
    
    ld a, 0
    call Border
    
    ld HL, BLACKSCREEN       ; make screen black with hmmv page 0
    call HMMV
    call Waitvdp
    
    ld HL, HMMCDATA
    call HMMCNoData          ; prepare copy picture.
    ld HL, $4000             ; NOW THE RLE TRICK
    call RLESendVDP
    
    ld a, $40                ; Screen on
    out ($99), a
    ld a, $81                ; Schrijf naar Register #1
    out ($99), a
   
    EI
    ret

; ==[ libaries ]====================================================
    include "screen.asc"
    include "RLESendVDP.asc"
    include "border.asc"
    include "hmmv.asc"
    include "waitvdp.asc"
    include "HMMCNoData.asc"

; ==[ Data ]====================================================
    
BLACKSCREEN:
    dw 0, 0, 256, 256        ; HMMV header voor zwart scherm page0
    db 0, 0, $C0
HMMCDATA:
    dw 6, 0                  ; dx,dy
    dw 244, 166              ; mx,my
    db 0, 0, $F0             ; col, arg, HMMC
    