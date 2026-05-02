; .org 0x8000
; Azul
; the gamelogic. (hopefully it fits in 16kb lol)

    .section .text
    
Main:                              ; TODO: Maybe choose between 1 or 2 player game?
    DI
    ;CALL Azul2PressSpace     ; shows blinking message and waits for space

    ld bc, 0x0201                  ; Swap pictures index 2 in memory 0x4000
    call MEMRESET
    
    CALL Azul3Playfield            ; Draws the playfield
    CALL Azul4EnterName            ; Ask players to enter the name + enterlogic.
    CALL Azul5StartGame            ; start the game.

    ld DE, 50
    CALL Wait                      ; Wait <DE> * 0.1 secs.

    
	; Exit the program and return to MSX-DOS
    CALL ReturnToDos
    ret

; ==[ Parts ]====================================================

    .include "azul2PressSpace.asc"
    .include "azul3Playfield.asc"
    .include "azul4EnterName.asc"
    .include "Azul5StartGame.asc"

    
; ==[ libaries ]====================================================

    .include "library/PrintScore.asc"
    .include "library/ShowTileSPrite.asc"
    .include "library/ShowSelector.asc"
    .include "library/ShowTile.asc"
    .include "library/TakeATile.asc"
    .include "library/HMMMnumber.asc"

; ==[ Data ]====================================================
    .section .text
    .global TIMER

TIMER:
    .byte 0x00                     ; for use in a gameloop (to blink etc)
    
    .include "data/font.as"
    .include "data/colormap.as"
    .include "data/SpriteData.as"
    .include "data/tilePositions.as"
    .include "data/selectorMovement.as"
    