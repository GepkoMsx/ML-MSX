;; ==[ MACRO SetPalette16 ]===============================================
;; Veranderd de kleuren van het palette. (16 kleuren)
;;
;; INPUT
;; - HL : Address of colortable
    
; Change pallette colors. <HL> : address of colortable    
    .macro SetPalette16
    SetVDP 16, 0                   ; Selecteer Kleur 0 in Register 16
    ld b, 16                       ; 16 kleuren, 2 bytes per kleur
    
SetPaletteLoop\@:
    ld a, (hl)                     ; Pak Rood/Blauw byte
    out (VDPP), a
    inc hl
    ld a, (hl)                     ; Pak Groen byte
    out (VDPP), a
    inc hl
    djnz SetPaletteLoop\@
    .endm
    