; loadrle. Loads files using MSX-DOS 1.0 style FCBs

; ==[ Constants ]===============================================
    include "Constants.as"

NROFILES: equ 2         ; Nr of files

; ==[ Header ]==================================================
    org $0100           ; MSX-DOS has no header, and starts at $0100

    include "memHeader.as"

; ==[ Program ]=================================================
    include "memPrepare.as"

    call DosLoader

EXIT:

    include "returntodos.as"

; ==[ libraries ]====================================================
    include "memPack.inc"
    include "dosloader.asc"

; ==[ Data ]====================================================

FILENAME:               ; vergeet NROFILES niet bij te werken als je hier iets aanpast!
    db "BANNER2 RL8"    ; 0-10  filename, 11 bytes (8+3)
    dw $4000            ; 11-12 address to load in memory (4000-C000 range!)
    db $02              ; 13    segment index. (add $80 to add on exisiting segment, instead of a new segment)
    db $00              ; 14    1 = run it 0 = dont run  (runners should RET, to load the next file)

    db "RLE_PIC8BIN"    ; 0-10  filename, 11 bytes (8+3)
    dw $8000            ; 11-12 address to load in memory (4000-C000 range!)
    db $01              ; 13    segment index. (add $80 to add on exisiting segment, instead of a new segment)
    db $01              ; 14    1 = run it 0 = dont run  (runners should RET, to load the next file)

FileEnd: