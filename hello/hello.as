; ==[ Constants ]===============================================
    include "Constants.as"
    
    org $8300
  ;  include "BloadHeader.as"

; ==[ Program ]=================================================
Main:

    ld de, helloWorld        ; Adres van de string (moet eindigen met '$')
    ld c, $09                ; Functie: Print String
    call 5
    ret



helloWorld:
    db "Hello world!", 13,10,"$"

FileEnd:
