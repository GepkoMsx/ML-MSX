;; makes color 0 a color, instead of transparent.
;; new screen macro fixes this?

    .macro Color0NotTransparent
    
    ld HL, 0xFFE7                  ; R8 mirror in memory (do we set it properly?)
    ld a, (HL)                     ; set color 0 to a color, not transparant
    or 32                          ; set TP bit
    ld (HL), a                     ; write new value back to mirror
    SetVDP 8, a 
    
    .endm