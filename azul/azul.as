; Azul
; the gamelogic. (hopefully it fits in 16kb lol)
; its a 2 part program. 
; - call 8000 -> shows loading screen
; - call 8100 -> starts the game
    
; ==[ Header ]==================================================
    include "Constants.as"
    
    org $8000
    
; ==[ Program: AZUL1LOAD ]======================================
ain:
    DI
    ld bc, $0101             ; Swap picture index 1 in memory $4000
    call MEMRESET
    
    CALL Azul1Load           ; Loads the wait-screen
    
    EI
    ret
    
    include "azul1load.asc"
    
; ==[ Program: AZUL2PressSpace ]================================
    org $8050
    
Main2:                       ; TODO: Maybe choose between 1 or 2 player game?
    DI
    CALL Azul2PressSpace     ; shows blinking message and waits for space
    jp Main3
    
    include "azul2PressSpace.asc"
    
; ==[ Program: AZUL3PressSPace ]================================
    
Main3:
    ; show the playfield
    ld bc, $0201             ; Swap pictures index 2 in memory $4000
    call MEMRESET
    CALL Azul3Playfield      ; Draws the playfield
    CALL Azul4EnterName      ; Ask players to enter the name + enterlogic.
    jp theend
    
    include "azul3Playfield.asc"
    include "azul4EnterName.asc"
    
theend:
    ld DE, 50
    CALL Wait                ; Wait <DE> * 0.1 secs.
    
    
	; Exit the program and return to MSX-DOS
    include "ReturnToDos.as"
    
    ret
    
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
    include "border.asc"
    include "GetFirstKey.asc"
    
; ==[ Data ]====================================================
    
TIMER:
    db $00                   ; for blink-speed
    
    include "font.as"