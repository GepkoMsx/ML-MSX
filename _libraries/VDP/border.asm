;; CALL Border

; Set Border <A> : color (0-15)
    .macro Border
    out (0x99), a                   ; Stuur waarde naar poort #99
    ld a, 128 + 7                  ; 128 (Register schrijven) + 7 (Registernummer)
    out (0x99), a
    .endm