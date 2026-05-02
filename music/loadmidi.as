
    .section .text
    .global NROFILES

    .equ NROFILES, 2


    call MemPrepare
    call DosLoader
    call ReturnToDos

    .section .data
    .global FILENAME

FILENAME:

    .byte "DKW     AKG"            ; 0-10  filename, 11 bytes (8+3)
    .word 0x4000                   ; 11-12 address to load in memory (4000-C000 range!)
    .byte 0x00                     ; 13    segment index. (add $80 to add on exisiting segment, instead of a new segment)
    .byte 0x00                     ; 14    1 = run it 0 = dont run  (runners should RET, to load the next file)
    

    .byte "PLAYMIDIBIN", 0x00, 0x80, 0x01, 0x01
