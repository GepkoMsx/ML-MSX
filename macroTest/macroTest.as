

    .ORG 0x0100

    ; ================ [macros] ==========================
    .nolist
    .include "SetScreen.asm"
    .list

    .byte "hallo"
    .word  0x11, 0x2200,0x0033     ; ha
    .ascii "hallo"
    .string "hallo"
    
    ;SetScreen 2              ; Direct naar Screen 2
    SetScreen 5 off IE0 IE1 16     ; nr onoff IE0 IE1 sprite

    ;comm    -> comment.line
    ; .abort
    ; .include  -> support.type.asm
    ; ld C, 2      -> keyword.mnemonic.asm.z80
    ; 44       -> constant.numberi.dec
    ; 0x34     -> constant.numeric.hex
    ; 0b0111   -> constant.numeric.bin
    ; BC       -> storage.type.asm.z80
    ; jp z, label
    ; cp 0x50
    
    ; "string" -> string.quoted.double
    ; 't'      -> punctuation.character.asm.z80
    ; .org     -> punctuation.definition.directive.asm + support.type.asm
    ; CALL Z   -> keyword.control.asm + variable.parameter.control.asm
    ; .db
    ; .byte
    ; .if (\0 == "hallo")
    ; .else
    ; .endif

    ; .list

    ; CALL 0x4000
    ; ccf
    