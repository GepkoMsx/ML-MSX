

    .macro BagReset

    ld HL, TILESINBAG
    ld b, 5
.loop2\@:
    ld (HL), 20
    inc HL
    djnz .loop2\@

    .endm
