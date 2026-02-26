; ==[ Constants ]===============================================
    include "Constants.as"
    
    org $8300
  ;  include "BloadHeader.as"

; ==[ Program ]=================================================
Main:
;     ; set VDP to screen 0
;     ld a, 0
;     call CHGMOD
;     ; print "Hello world" on screen
;     ld hl, helloWorld
;     call PrintStr
;     ret

; PrintStr:
;     ld a, (hl)
;     or a
;     ret z
;     inc hl
;     call CHPUT
;     jr PrintStr
;     ret
    ld de, helloWorld   ; Adres van de string (moet eindigen met '$')
    ld c, $09           ; Functie: Print String
    call 5
    ret



helloWorld:
    db "Hello world!", 13,10,"$"

FileEnd:
  ; ==[ ROM Padding ]=============================================
  ;  ds $4000 + RomSize - FileEnd, 255
  ;  ds $3000, 255  ; maak het bestand groter