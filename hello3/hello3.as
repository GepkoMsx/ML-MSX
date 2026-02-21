; ==[ Constants ]===============================================
    include "Constants.as"
    
    org $8000
    include "BloadHeader.as"

; ==[ Program ]=================================================
Main:
    ; print "Hello country" on screen
    ld hl, helloCountry
    call PrintStr
    ret

PrintStr:
    ld a, (hl)
    or a
    ret z
    inc hl
    call CHPUT
    jr PrintStr
    ret

helloCountry:
    db "Hello deventer!", 13,10,0

FileEnd:
  ; ==[ ROM Padding ]=============================================
  ;  ds $4000 + RomSize - FileEnd, 255
  ds $1000, 255  ; maak het bestand groter