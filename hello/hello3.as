; .org 0x4000                      ; tell the linker to use this startadres (must be comment)

    .section .text

    ld de, helloDeventer           ; Adres van de string (moet eindigen met '$')
    ld c, 0x09                     ; Functie: Print String
    call 5
    ret

    .section .data

helloDeventer:
    .byte "Hello deventer!", 13,10,"$"
