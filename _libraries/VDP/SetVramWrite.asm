
;; HL = address. (make sure right 16k vram page is selected)
    .macro SetVramWrite
    push af
    ld   a, l
    out  (VDPC), a
    ld   a, h
    and  0x3F
    or   0x40                      ; Write bit
    out  (VDPC), a
    pop  af
    .endm