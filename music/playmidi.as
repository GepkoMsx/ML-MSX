

Music_Start equ $4000
HOOK equ $FD9F

    org $8000

    include "DKW_playerconfig.asm"

MAIN:
    DI

    ld HL, Screen5_Table
    CALL Screen              ; Change screenmode. <HL> address of table in this file.
    call waitvdp
    
    ld a, $60
    out ($99), a
    ld a, $81
    out ($99), a             ; enable screen and interrupt0

    EI

    ;Initializes the music.
    ld hl,Music_Start
    xor a                    ; Subsong 0.
    call PLY_AKG_Init

    di
    ld hl,HOOK               ; Store original VDP hook content
    ld de,OldHook
    ld bc,5
    ldir

    ld a,#C3                 ; JP instruction
    ld hl,NewHook            ; our new interrupt handler
    ld (HOOK),a
    ld (HOOK+1),hl           ; Place the jump to hook handler
    ei


    xor a                    ; reset a counter
    ld ($7fff), a
    ld ($7ffe), a


WaitVsync:
    ld a,($FC9E)             ; Laad de huidige JIFFY waarde (2 bytes)

.wait:
    halt                     ; Wacht op de volgende interrupt (bespaart CPU stroom)
    ld b,a                   ; Bewaar oude waarde
    ld a,($FC9E)             ; Laad nieuwe waarde
    cp b                     ; Is de waarde veranderd?
    jr z,.wait               ; Nee? Blijf wachten
    


    ld a, ($7fff)
    inc a
    ld ($7fff), a
    cp 50
    jp z, .sec



.sec:
    ld a, ($7ffe)
    inc a
    ld ($7ffe), a
    jp WaitVsync



ExitProg:
    di
    ld hl,OldHook
    ld de,HOOK               ; Restore original code to VDP interrupt hook
    ld bc,5
    ldir

    call PLY_AKG_Stop
    ret

; =============LIBS ========================
    include "PlayerAkg.asM"

    include "screen.asc"
    include "waitvdp.asc"

; =============== DATA ======================

NewHook:
    push af
    call Wrapper
    pop af
OldHook:
    ds 5                     ; Space to store old interrupt hook handler (this is executed after the play routine)


Wrapper:
    ld a, 15                 ; Wit (MSX kleur 15)
    out ($99), a             ; Schrijf kleur naar VDP
    ld a, 7 + 128            ; Selecteer Register 7
    out ($99), a

    call PLY_AKG_Play

    call OldHook
    
    ld a, 1                  ; Terug naar zwart (MSX kleur 1)
    out ($99), a
    ld a, 7 + 128
    out ($99), a

    ret