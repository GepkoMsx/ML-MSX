;; MACRO EnableSprites16

; Enables sprites for screen5, with 16x16 size. tables on 7400/7600/7800
    .macro EnableSprites16
    ld a, 0x28                     ; #28 to R8   (sprites on)
    out (0x99), a
    ld a, 0x80+8
    out (0x99), a

    ld a, 0x62                     ; #62 to R1   (16x16 sprites)
    out (0x99), a
    ld a, 0x80+1
    out (0x99), a

    ld a, 0x0F                     ; Sprite Pattern Table 0x7800-7FFF  #0F to R6
    out (0x99), a
    ld a, 0x80+6
    out (0x99), a
    
    ld a, 0xEF                     ; Sprite Attribute Table 0x7600-767F   EF to R5, 00 to R11
    out (0x99), a                  ; Sprite Color table     0x7400-0x75FF
    ld a, 0x80+5
    out (0x99), a

    ld a, 0x00
    out (0x99), a
    ld a, 0x80+11
    out (0x99), a

    ld a, 0x01                     ; select VRAM write range 2nd 16KB (0x4000-0x7FFF)
    out (0x99), a                  ; 0x01 to R14
    ld a, 0x80+14
    out (0x99), a

    .endm