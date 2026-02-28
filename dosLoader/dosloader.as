; Dosloader. Loads files using MSX-DOS 1.0 style FCBs
; We want to be compatible with "vanilla MSX2"
; But also work on extentions liks harddisks, SD cards etc

; ==[ Constants ]===============================================
    include "Constants.as"

NROFILES: equ 3         ; Aantal bestanden die geladen moeten worden.

; ==[ Header ]==================================================
    org $0100           ; MSX-DOS has no header, and starts at $0100

    include "memHeader.as"

; ==[ Program ]=================================================
    include "memPrepare.as"

    call DosLoader

    ld BC, $0501            ; B = segmentindex, C =  Page (hello2 -> $4000)
    CALL MEMRESET

    ld BC, $0402            ; B = segmentindex, C =  Page (hello1 -> $8300)
    CALL MEMRESET

    call GameLoop

EXIT:
    LD C, $00           ; Exit do MSXDOS
    CALL BDOS           
    ret

; ==[ libraries ]====================================================
    include "memPack.inc"
    include "dosloader.asc"

    include "GetActionKeys.asc"
    include "gameloop.asc"
; ==[ Data ]====================================================

FILENAME:               ; vergeet NROFILES niet bij te werken als je hier iets aanpast!
;HELLO example
    db "HELLO   BIN"    ; 0-10  filename, 11 bytes (8+3)
    dw $8300            ; 11-12 address to load in memory (4000-C000 range!)
    db $04              ; 13    segment index. (add $80 to add on exisiting segment, instead of a new segment)
    db $01              ; 14    1 = run it 0 = dont run  (runners should RET, to load the next file)

    db "HELLO2  BIN", $00, $80, $05, $00    
    db "HELLO3  BIN", $00, $40, $84, $01

COUNTER:
    db $00, $00

FileEnd: