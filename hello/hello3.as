; ==[ Constants ]===============================================
    include "Constants.as"
    
    org $4000

; ==[ Program ]=================================================
Main:
    ld de, helloDeventer     ; Adres van de string (moet eindigen met '$')
    ld c, $09                ; Functie: Print String
    call 5
    ret

helloDeventer:
    db "Hello deventer!", 13,10,"$"

FileEnd:
