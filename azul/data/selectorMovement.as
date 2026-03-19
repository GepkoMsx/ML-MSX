SELECTORMOVEMENT:

; first the factories, same order as in factoryPositions
; every position has 4 bytes pointing left, right, up, down
; not possible movements are $FF. Layout:

;      00  01
;      02  03
;
; 04 05  14  08 09
; 06 07  15  0A 0B
;        16
; 0C 0D  17  10 11
; 0E 0F  18  12 13
;

    db $FF, $01, $FF, $02    ; $00  First Factory
    db $00, $FF, $FF, $03    ; $01
    db $FF, $03, $00, $05    ; $02
    db $02, $FF, $01, $08    ; $03
    
    db $FF, $05, $FF, $06    ; $04  Second Factory
    db $04, $14, $02, $07    ; $05
    db $FF, $07, $04, $0C    ; $06
    db $06, $15, $05, $0D    ; $07  
    
    db $14, $09, $03, $0A    ; $08  Third Factory
    db $08, $FF, $FF, $0B    ; $09
    db $15, $0B, $08, $10    ; $0A
    db $0A, $FF, $09, $11    ; $0B
    
    db $FF, $0D, $06, $0E    ; $0C  Fourth factory
    db $0C, $17, $07, $0F    ; $0D
    db $FF, $0F, $0C, $FF    ; $0E
    db $0E, $18, $0D, $FF    ; $0F
    
    db $17, $11, $0A, $12    ; $10  Fifth factory
    db $10, $FF, $0B, $13    ; $11
    db $18, $13, $10, $FF    ; $12
    db $12, $FF, $11, $FF    ; $13
    
    db $05, $08, $FF, $15    ; $14  Tiles on table
    db $07, $0A, $14, $16    ; $15
    db $FF, $FF, $15, $17    ; $16
    db $0D, $10, $16, $18    ; $17
    db $0F, $12, $17, $FF    ; $18
    