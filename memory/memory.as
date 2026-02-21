; doel: 
; - bepalen van de grootte van de memorymapper
; - bepalen welke mem-bank in page 3 zit bij begin.
; 
; MEMNRBANKS:   ($D0FE) Bevat het aantal memoryslots (max 32 = 512kb)
; MEMPAGE3:     ($D0FF) Bevat de memory page dat voor page 3 gerbuikt wordt. (Deze niet veranderen!)
;
; Page 1 ($4000-$7FFF) wordt van BASIC naar RAM omgezet.
; Standaard vulling voor page 3-2-1: mempage3 - mempage3+1 - mempage3+2
; Dit is meestal memorymapper segment 0-1-2 (mempage3 == 0)

; ==[ Constants ]===============================================
    include "Constants.as"

; ==[ Header ]==================================================
    org $D000
    include "BloadHeader.as"

; ==[ Program ]=================================================
Main:                   
    push iy             
    push ix             
    push af          
    
    call MemMapCheck
    call MemSwapPage1

; END FOR NOW FIX PAGE 2 LIKE THIS.
    DI
    halt

backtobasic:    
    pop af
    pop ix              
    pop iy           

    ret                 ; Return naar BASIC (na Main is klaar)

RETERR:                 ; Foutafhandeling hier...
    LD (0xf7f8), A      ; Load the result into the lower byte
    LD A, 0
    LD (0xf7f9), A      ; Clear the higher byte
    LD A, 2
    LD (0xf663), A      ; Set return value as integer (type 2)

    jp backtobasic     ; Return naar BASIC (na Main is klaar)

; ==[ Libraries ]===============================================
    include "memMapCheck.asc"
    include "memSwapPage1.asc"

; ==[ Data ]====================================================
    org $D100-2

MEMNRBANKS:
    db 0
MEMPAGE3:
    db 0
MEMBUFFER: 
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0

FileEnd:
