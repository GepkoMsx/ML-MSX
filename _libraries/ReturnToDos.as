; Return to dos properly
;
; Take account of not being on screen 0
    
; Exit the program and return to MSX-DOS
ReturnToDos:
    call waitvdp
    ld a, $60                ; Scherm aan ($40) + Interrupts aan ($20)
    out ($99), a
    ld a, $81                ; Schrijf naar Register #1
    out ($99), a
    
    EI
    ld a, 1                  ; 1. Forceer de BIOS om het scherm echt te wissen en te herstellen
    ld (SCRMOD), a           ; Zorg dat de BIOS niet denkt: "ik ben al in mode 0"
    
    ld iy, (EXPTBL-1)        ; 2. Schakel naar Screen 0 via de RAM-mirror, BIOS Slot ID in IYH
    ld ix, CHGMOD
    ld a, 0                  ; Mode 0
    call CALSLT
    
    ld iy, (EXPTBL-1)        ; 3. HEEL BELANGRIJK: Herinitialiseer de tekst-omgeving
    ld ix, INITXT            ; Dit kopieert de font van ROM naar VRAM (wat in Screen 8 niet kon)
    call CALSLT
    
    ld   a, $F4              ; 4. Herstel kleuren Wit op Blauw
    ld   ($F3E9), a          ; BAKCLR
    ld   iy, (EXPTBL-1)
    ld   ix, $0062           ; CHGCLR
    call CALSLT
    
    ld a, $F4                ; set Border: Kleurnummer (0-15)
    out ($99), a             ; Stuur waarde naar poort #99
    ld a, $87                ; 128 (Register schrijven) + 7 (Registernummer)
    out ($99), a
    
    LD C, $00                ; Exit do MSXDOS
    CALL BDOS
    ret