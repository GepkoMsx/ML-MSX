; loadrle. Loads files using MSX-DOS 1.0 style FCBs

    .section .text
    .global NROFILES

    .equ NROFILES, 2               ; Nr of files

    call MemPrepare
    call DosLoader
    call ReturnToDos

    .section .data
    .global FILENAME

FILENAME:                          ; vergeet NROFILES niet bij te werken als je hier iets aanpast!
    .byte "BANNER2 RL8"            ; 0-10  filename, 11 bytes (8+3)
    .word 0x4000                   ; 11-12 address to load in memory (4000-C000 range!)
    .byte 0x02                     ; 13    segment index. (add 0x80 to add on exisiting segment, instead of a new segment)
    .byte 0x00                     ; 14    1 = run it 0 = dont run  (runners should RET, to load the next file)

    .byte "RLE_PIC8BIN"            ; 0-10  filename, 11 bytes (8+3)
    .word 0x8000                   ; 11-12 address to load in memory (4000-C000 range!)
    .byte 0x01                     ; 13    segment index. (add 0x80 to add on exisiting segment, instead of a new segment)
    .byte 0x01                     ; 14    1 = run it 0 = dont run  (runners should RET, to load the next file)
    