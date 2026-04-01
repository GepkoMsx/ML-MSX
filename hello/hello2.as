; .org 0x4000                      ; tell the linker to use this startadres (must be comment)

    .section .text

    ld de, helloCountry            ; Adres van de string (moet eindigen met '$')
    ld c, 0x09                     ; Functie: Print String
    call 5
    ret

    .section .data

helloCountry:
    .byte "Hello country!", 13,10,"$"
