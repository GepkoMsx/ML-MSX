; Dosloader. Loads files using MSX-DOS 1.0 style FCBs
; We want to be compatible with "vanilla MSX2"
; But also work on extentions liks harddisks, SD cards etc

    .section .text
; ==[ Constants ]===============================================
    ;.include "Constants.as"

    .equ NROFILES, 3               ; Aantal bestanden die geladen moeten worden.


; ==[ Program ]=================================================
Main:
    .include "memPrepare.as"

    CALL DosLoader

    ld BC, 0x0501                  ; B = segmentindex, C =  Page (hello2 -> 0x4000)
    CALL MEMRESET

    ld BC, 0x0402                  ; B = segmentindex, C =  Page (hello1 -> 0x8300)
    CALL MEMRESET

    CALL GameLoop

EXIT:
    LD C, 0x00                     ; Exit do MSXDOS
    CALL BDOS
    RET

; ==[ libraries ]====================================================
    .include "memPack.as"
    .include "dosloader.asc"

    .include "GetActionKeys.asc"
    .include "gameloop.asc"

; ==[ Data ]====================================================

    .section .data
FILENAME:                          ; vergeet NROFILES niet bij te werken als je hier iets aanpast!
;HELLO example
    .byte "HELLO   BIN"            ; 0-10  filename, 11 bytes (8+3)
    .word 0x8300                   ; 11-12 address to load in memory (4000-C000 range!)
    .byte 0x04                     ; 13    segment index. (add 0x80 to add on exisiting segment, instead of a new segment)
    .byte 0x01                     ; 14    1 = run it 0 = dont run  (runners should RET, to load the next file)

    .byte "HELLO2  BIN", 0x00, 0x80, 0x05, 0x00
    .byte "HELLO3  BIN", 0x00, 0x40, 0x84, 0x01

    .section .bss
COUNTER:
    .space 2

FileEnd:
