; .org 0x8000

    .section .text
    .nolist
    .include "Macros.asc"
    .list

    .global Music_Start

    .equ Music_Start, 0x4000
    .equ COUNT1, 0x7fff
    .equ COUNT2, 0x7ffe

MAIN:
    DI
    SetScreen 5, on, IE0
    EI
    
    ;Initializes the music.
    ld hl,Music_Start
    xor a                          ; Subsong 0.
    call PLY_AKG_Init

    di
    ld hl,HTIMI                    ; Store original HTIMI content
    ld de,OldHook
    ld bc,5
    ldir

    ld a, 0xC3                     ; JP instruction
    ld hl, NewHook                 ; our new interrupt handler
    ld (HTIMI),  a
    ld (HTIMI+1), hl               ; Place the jump to HTIMI handler
    ei


    xor a                          ; reset a counter
    ld (COUNT1), a
    ld (COUNT2), a


WaitVsync:
    ld a, (JIFFY)

.wait:
    halt                           ; Wacht op de volgende interrupt (bespaart CPU stroom)
    ld b, a                        ; Bewaar oude waarde
    ld a, (JIFFY)                  ; Laad nieuwe waarde
    cp b                           ; Is de waarde veranderd?
    jr z, .wait                    ; Nee? Blijf wachten
    


    ld a, (COUNT1)
    inc a
    ld (COUNT1), a
    cp 50
    jp z, .sec

.sec:
    ld a, (COUNT2)
    inc a
    ld (COUNT2), a
    jp WaitVsync

ExitProg:
    di
    ld hl, OldHook
    ld de, HTIMI                   ; Restore original code to VDP interrupt HTIMI
    ld bc, 5
    ldir

    call PLY_AKG_Stop
    ret

Wrapper:
    SetVDP 7, 15                   ; White
    call PLY_AKG_Play
    call OldHook
    SetVDP 7, 1                    ; Black
    ret


    .section .data

NewHook:
    push af
    call Wrapper
    pop af

OldHook:
    .byte 5                        ; Space to store old interrupt HTIMI handler (this is executed after the play routine)
    