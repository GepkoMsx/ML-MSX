

    .macro SetLastSprite16 nr
    ld   hl, 0x7600
    ld C, \nr
    LD B, 0                        ; point HL to right vram address
    SLA C
    RL B
    SLA C
    RL B                           ; c = c*4 (in 16x16 mode, onesprite are actually 4)
    ADD HL, BC                     ; HL = HL + BC
    SetVramWrite
    ld   a, 0xD8                   ; Y=0xD8 = terminator
    out (0x98), a
    
    .endm