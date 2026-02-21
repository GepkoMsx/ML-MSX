; - Screen 8
; - make both pages black backgrond
; - switch to page 2 visible
; - set border black.    
    
    ld a, 8
    call CHGMOD         ; goto screen 8;
    call waitvdp

    ld HL, BLACKSCREEN+11 ; make screen black with hmmv page2
    call HMMV
    call waitvdp

    ld a, %00111111     ; Switch to VRAM page 2
    out (#99), a        ; Bit 6 bepaalt de pagina (0 voor Page 0, 1 voor Page 1)
    ld a, 128 + 2       ; Schrijf naar VDP Register 2
    out (#99), a


    ld a, 0           ; set Border: Kleurnummer (0-15)
    out (#99), a      ; Stuur waarde naar poort #99
    ld a, 128 + 7     ; 128 (Register schrijven) + 7 (Registernummer)
    out (#99), a
    call waitvdp

    ld HL, BLACKSCREEN  ; make screen black with hmmv
    call HMMV
    call waitvdp
