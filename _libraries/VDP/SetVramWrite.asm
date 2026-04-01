;; CALL SetVramWrite


;; HL = address. (make sure right 16k vram page is selected)
    .macro SetVramWrite
    push af
    ld   a, l
    out  (0x99), a
    ld   a, h
    and  0x3F
    or   0x40                      ; Write bit
    out  (0x99), a
    pop  af
    .endm