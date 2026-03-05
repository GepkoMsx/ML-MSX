; ==[ Constants ]===============================================
    include "Constants.as"
    
    org $4000
 ;   include "BloadHeader.as"
    
; ==[ Program ]=================================================
Main:

    ld de, helloCountry      ; Adres van de string (moet eindigen met '$')
    ld c, $09                ; Functie: Print String
    call 5
    ret
    
helloCountry:
    db "Hello country!", 13,10,"$"
    
FileEnd:
