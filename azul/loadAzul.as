; loadazul. 
; Loads files using MSX-DOS 1.0 style FCBs or MSX_DOS 2.0 style handles.

    .section .text
    .global NROFILES

    .equ  NROFILES,  6             ; Nr of files

    CALL MemPrepare
    CALL DosLoader                 ; Loads <NROFILES> files from <FILENAME> structure into memory. Needs Mempack.

EXIT:
    CALL ReturnToDos

    .section .data
    .global FILENAME

FILENAME:                          ; vergeet NROFILES niet bij te werken als je hier iets aanpast!
    .byte "BANNER2 RL8"            ; 0-10  filename, 11 bytes (8+3)
    .word 0x4000                   ; 11-12 address to load in memory (4000-C000 range!)
    .byte 0x01                     ; 13    segment index. (add 0x80 to add on exisiting segment, instead of a new segment)
    .byte 0x00                     ; 14    1 = run it 0 = dont run  (runners should RET, to load the next file)

    .byte "AZULSHOWBIN"            ; 0-10  filename, 11 bytes (8+3)
    .word 0x8000                   ; 11-12 address to load in memory (4000-C000 range!)
    .byte 0x00                     ; 13    segment index. (add 0x80 to add on exisiting segment, instead of a new segment)
    .byte 0x01                     ; 14    1 = run it 0 = dont run  (runners should RET, to load the next file)

    ; other data files through 0x4000
    .byte "BORD1   RL5"
    .word 0x4000                   ; 4000 - 5089
    .byte 0x02
    .byte 0x00

    .byte "TILES   RL5"
    .word 0x5100                   ; 5100 - 55BC
    .byte 0x82
    .byte 0x00

    .byte "FABRIEK RL5"
    .word 0x5600                   ; 5600 - 6C8A
    .byte 0x82
    .byte 0x00

    .byte "AZUL    BIN"            ; 0-10  filename, 11 bytes (8+3)
    .word 0x8000                   ; 11-12 address to load in memory (4000-C000 range!)
    .byte 0x00                     ; 13    segment index. (add 0x80 to add on exisiting segment, instead of a new segment)
    .byte 0x01                     ; 14    1 = run it 0 = dont run  (runners should RET, to load the next file)
