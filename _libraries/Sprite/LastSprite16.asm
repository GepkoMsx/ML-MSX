;; CALL LastSprite16

; close the spritearray C = spritenr
    .macro LastSprite16
    ld   hl, 0x7600

    LD B, 0                        ; point HL to right vram address
    SLA C
    RL B
    SLA C
    RL B                           ; c = c*4 (in 16x16 mode, onesprite are actually 4)
    ADD HL, BC                     ; HL = HL + BC
    call SetVramWrite
    ld   a, 0xD8                    ; Y=0xD8 = terminator
    out (0x98), a
    
    .endm