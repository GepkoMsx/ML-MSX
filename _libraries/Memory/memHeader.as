;; default header for the Memory library with MSX-DOS.
    
    jr Main                 ; jump over Shared Data Block 
                            ; SDB here.
    org STARTDATA

    db $00,$00,$00,$00                      ; Memory state bytes
    db $00,$00                              ; MAPTBL
    db $C3,$00,$00,$C3,$00,$00              ; jumps for set and reset
    db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF      ; indexlist of requested segments
    db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF

    org STARTDATA+28
    
Main: