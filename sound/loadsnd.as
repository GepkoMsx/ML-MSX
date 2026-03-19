; Dosloader. Loads files using MSX-DOS 1.0 style FCBs
; We want to be compatible with "vanilla MSX2"
; But also work on extentions liks harddisks, SD cards etc

; ==[ Constants ]===============================================
    include "Constants.as"

NROFILES: equ 3              ; Aantal bestanden die geladen moeten worden.

; ==[ Header ]==================================================
    org $0100                ; MSX-DOS has no header, and starts at $0100

    include "memHeader.as"

; ==[ Program ]=================================================
    include "memPrepare.as"

    call DosLoader

EXIT:
    LD C, $00                ; Exit do MSXDOS
    CALL BDOS
    ret

; ==[ libraries ]====================================================
    include "memPack.inc"
    include "dosloader.asc"

; ==[ Data ]====================================================

FILENAME:                    ; vergeet NROFILES niet bij te werken als je hier iets aanpast!
;HELLO example
    db "PSG_LUT BIN"         ; 0-10  filename, 11 bytes (8+3)
    dw $8000                 ; 11-12 address to load in memory (4000-C000 range!)
    db $00                   ; 13    segment index. (add $80 to add on exisiting segment, instead of a new segment)
    db $00                   ; 14    1 = run it 0 = dont run  (runners should RET, to load the next file)

    db "GAMEOVERBIN", $00, $40, $01, $00
    db "SOUND   BIN", $00, $82, $80, $01

FileEnd: