    .section .data
    .global FACTORYPOSITIONS, TILESONTABLEPOSITIONS, TILESWALL1POSITIONS, TILESWALL2POSITIONS

FACTORYPOSITIONS:
    .byte 48,45                       ; x,y for every tile on a factory (20 places)
    .byte 48+12, 45                   ; 1 2
    .byte 48, 45+12                   ; 3 4 pattern
    .byte 48+12, 45+12

    .byte 11,85
    .byte 11+12,85
    .byte 11,85+12
    .byte 11+12,85+12

    .byte 91,85
    .byte 91+12,85
    .byte 91,85+12
    .byte 91+12,85+12

    .byte 11,128
    .byte 11+12,128
    .byte 11,128+12
    .byte 11+12,128+12
    
    .byte 91,128
    .byte 91+12,128
    .byte 91,128+12
    .byte 91+12,128+12

TILESONTABLEPOSITIONS:             ; 5 tiles in a column in the middle
    .byte 00,00                       ; TODO!
    .byte 00,00
    .byte 00,00
    .byte 00,00
    .byte 00,00

TILESWALL1POSITIONS:               ; 5 right most tiles at the wall for player 1
    .byte 00,00                       ; TODO!
    .byte 00,00
    .byte 00,00
    .byte 00,00
    .byte 00,00

TILESWALL2POSITIONS:               ; 5 right most tiles at the wall for player 2
    .byte 00,00                       ; TODO!
    .byte 00,00
    .byte 00,00
    .byte 00,00
    .byte 00,00
