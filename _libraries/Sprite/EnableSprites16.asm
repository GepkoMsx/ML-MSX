;; MACRO EnableSprites16

; Enables sprites for screen5, with 16x16 size. tables on 7400/7600/7800
    .macro EnableSprites16

    SetVDP 8, 0x28                 ; #28 to R8   (sprites on)
    SetVDP 1, 0x62                 ; #62 to R1   (16x16 sprites)
    SetVDP 6, 0x0F                 ; Sprite Pattern Table 0x7800-7FFF  #0F to R6
    SetVDP 5, 0xEF                 ; Sprite Attribute Table 0x7600-767F   EF to R5, 00 to R11
    SetVDP 11, 0x00                ; Sprite Color table     0x7400-0x75FF
    SetVDP 14, 0x01                ; select VRAM write range 2nd 16KB (0x4000-0x7FFF) 0x01 to R14

    .endm