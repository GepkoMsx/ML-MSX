; Azul
; the gamelogic. (hopefully it fits in 16kb lol)
    
; ==[ Header ]==================================================
    include "Constants.as"
    
    org $8000
    
; ==[ Program: AZUL2PressSpace ]================================
    
Main:                       ; TODO: Maybe choose between 1 or 2 player game?
    DI
    ;CALL Azul2PressSpace     ; shows blinking message and waits for space

    ld bc, $0201             ; Swap pictures index 2 in memory $4000
    call MEMRESET
    
    CALL Azul3Playfield      ; Draws the playfield
    CALL Azul4EnterName      ; Ask players to enter the name + enterlogic.
    CALL Azul5StartGame      ; start the game.

    ld DE, 50
    CALL Wait                ; Wait <DE> * 0.1 secs.
    
	; Exit the program and return to MSX-DOS
    include "ReturnToDos.as"
    ret

; ==[ Parts ]====================================================

    include "azul2PressSpace.asc"
    include "azul3Playfield.asc"
    include "azul4EnterName.asc"
    include "Azul5StartGame.asc"

    
; ==[ libaries ]====================================================
    include "hmmm.asc"
    include "hmmv.asc"
    include "writeLetter8.asc"
    include "writeString8.asc"
    include "multiply.asc"
    include "getactionkeys.asc"
    include "screen.asc"
    include "RLESendVDP.asc"
    include "HMMCNoData.asc"
    include "Scrollup8.asc"
    include "StopVDP.asc"
    include "waitvdp.asc"
    include "SetPalette16.asc"
    include "color0NotTransparent.asc"
    include "wait.asc"
    include "smallwait.asc"
    include "border.asc"
    include "GetFirstKey.asc"
    include "EnableSprites16.asc"
    include "SetVramWrite.asc"
    include "LastSprite16.asc"

    include "library/PrintScore.asc"
    include "library/ShowTileSPrite.asc"
    include "library/ShowSelector.asc"
    include "library/ShowTile.asc"
    include "library/TakeATile.asc"
    include "library/HMMMnumber.asc"

; ==[ Data ]====================================================
TIMER:
    db $00                   ; for use in a gameloop (to blink etc)
    
    include "data/font.as"
    include "data/colormap.as"
    include "data/SpriteData.as"
    include "data/tilePositions.as"
    include "data/selectorMovement.as"
    