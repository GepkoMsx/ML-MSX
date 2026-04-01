; .org 0x8300                      ; tell the linker to use this startadres (must be comment)
    
    .section .text
    
    ld de, helloWorld              ; Adres van de string (moet eindigen met '$')
    ld c, 0x09                     ; Functie: Print String
    call 5
    ret

    .section .data

helloWorld:
    .byte "Hello world!", 13,10,"$"

