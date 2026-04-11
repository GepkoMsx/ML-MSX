; Dosloader. Loads files using MSX-DOS 1.0 style FCBs
; We want to be compatible with "vanilla MSX2"
; But also work on extentions liks harddisks, SD cards etc

    .section .text
    .global NROFILES

    .equ NROFILES, 3               ; Aantal bestanden die geladen moeten worden.
    
    call MemPrepare
    call DosLoader
    call ReturnToDos

    .section .data
    .global FILENAME

FILENAME:                          ; vergeet NROFILES niet bij te werken als je hier iets aanpast!
    .byte "PSG_LUT BIN"            ; 0-10  filename, 11 bytes (8+3)
    .word 0x8000                   ; 11-12 address to load in memory (4000-C000 range!)
    .byte 0x00                     ; 13    segment index. (add 0x80 to add on exisiting segment, instead of a new segment)
    .byte 0x00                     ; 14    1 = run it 0 = dont run  (runners should RET, to load the next file)

    .byte "GAMEOVERSND", 0x00, 0x40, 0x01, 0x00
    .byte "SOUND   BIN", 0x00, 0x82, 0x80, 0x01

FileEnd: