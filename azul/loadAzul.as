; loadazul. 
; Loads files using MSX-DOS 1.0 style FCBs or MSX_DOS 2.0 style handles.

; ==[ Constants ]===============================================
    include "Constants.as"

NROFILES: equ 5              ; Nr of files

; ==[ Header ]==================================================
    org $0100                ; MSX-DOS has no header, and starts at $0100

    include "memHeader.as"

; ==[ Program ]=================================================
    include "memPrepare.as"

    CALL DosLoader           ; Loads <NROFILES> files from <FILENAME> structure into memory. Needs Mempack.

    ; When done call the 2nd part of the program in azul1.bin
    ; its still loaded in $8000- range.
    call $8050

EXIT:
	; Exit the program and return to MSX-DOS
    include "ReturnToDos.as"

; ==[ libraries ]====================================================
    include "memPack.inc"
    include "dosloader.asc"

; ==[ Data ]====================================================

FILENAME:                    ; vergeet NROFILES niet bij te werken als je hier iets aanpast!
    db "BANNER2 RL8"         ; 0-10  filename, 11 bytes (8+3)
    dw $4000                 ; 11-12 address to load in memory (4000-C000 range!)
    db $01                   ; 13    segment index. (add $80 to add on exisiting segment, instead of a new segment)
    db $00                   ; 14    1 = run it 0 = dont run  (runners should RET, to load the next file)

    db "AZUL    BIN"         ; 0-10  filename, 11 bytes (8+3)
    dw $8000                 ; 11-12 address to load in memory (4000-C000 range!)
    db $00                   ; 13    segment index. (add $80 to add on exisiting segment, instead of a new segment)
    db $01                   ; 14    1 = run it 0 = dont run  (runners should RET, to load the next file)

    ; other data files through $4000
    db "BORD1   RL5"
    dw $4000                 ; 4000 - 5089
    db $02
    db $00

    db "TILES   RL5"
    dw $5100                 ; 5100 - 55BC
    db $82
    db $00

    db "FABRIEK RL5"
    dw $5600                 ; 5600 - 6C8A
    db $82
    db $00

FileEnd: