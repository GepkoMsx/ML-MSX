FACTORYPOSITIONS:
    db 48,45                 ; x,y for every tile on a factory (20 places)
    db 48+12, 45             ; 1 2
    db 48, 45+12             ; 3 4 pattern
    db 48+12, 45+12

    db 11,85
    db 11+12,85
    db 11,85+12
    db 11+12,85+12

    db 91,85
    db 91+12,85
    db 91,85+12
    db 91+12,85+12

    db 11,128
    db 11+12,128
    db 11,128+12
    db 11+12,128+12
    
    db 91,128
    db 91+12,128
    db 91,128+12
    db 91+12,128+12

TILESONTABLEPOSITIONS:       ; 5 tiles in a column in the middle
    db 00,00                 ; TODO!
    db 00,00
    db 00,00
    db 00,00
    db 00,00

TILESWALL1POSITIONS:         ; 5 right most tiles at the wall for player 1
    db 00,00                 ; TODO!
    db 00,00
    db 00,00
    db 00,00
    db 00,00

TILESWALL2POSITIONS:         ; 5 right most tiles at the wall for player 2
    db 00,00                 ; TODO!
    db 00,00
    db 00,00
    db 00,00
    db 00,00
