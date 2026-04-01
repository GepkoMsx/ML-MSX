;; ==[ CALL GetActionKeys ]===============================================
;; Checks and reads the action keys.
;; Action keys are:
;; bit   7    6    5    4    3       2     1    0
;;       →	  ↓	   ↑    ←  return   tab   esc space
;;
;; OUTPUT
;; - A: the above bitmap
    
; Returns bitmask in A:  →,↓,↑,←,return,tab,esc,space
    .macro GetActionKeys

    ld a, 8                        ; scanline 8: has bit 7654XXX0
    out (0xAA), a                  ; Schrijf rijnummer naar PPI poort C
    in a, (0xA9)                   ; Lees de 8 toetsen van poort B
    cpl
    and 0xF1                       ; remove bit 1,2,3
    ld b, a                        ; save in B
    
    ld a, 7                        ; has return, X, X, X, tab, esc, X,X
    out (0xAA), a                  ; Schrijf rijnummer naar PPI poort C
    in a, (0xA9)                   ; Lees de 8 toetsen van poort B
    cpl
    
    ld c, a                        ; save a
    and 0x80                       ; get return
    rrca
    rrca
    rrca
    rrca
    or b                           ; add to b
    ld b, a
    
    ld a, c                        ; now do tab and esc
    rrca                           ; shift bit 2-3 to 1-2
    and 0x06
    or b                           ; combine
    
    .endm
    
; De MSX Toetsenmatrix 
; ====================
; Rij	Bit 7	Bit 6	Bit 5	Bit 4	Bit 3	Bit 2	Bit 1	Bit 0
; 0	    7	    6	    5	    4	    3	    2	    1	    0
; 1	    ;	    ]	    [	    \	    =	    -	    9	    8
; 2	    B	    A	    _	    /	    .	    ,	    `	    '
; 3	    J	    I	    H	    G	    F	    E	    D	    C
; 4	    R	    Q	    P	    O	    N	    M	    L	    K
; 5	    Z	    Y	    X	    W	    V	    U	    T	    S
; 6	    F3	    F2	    F1	    CODE	CAP	    GRAPH	CTRL	SHIFT
; 7	    RET	    SELECT	BS	    STOP	TAB	    ESC	    F5	    F4
; 8	    →	    ↓	    ↑	    ←	    DEL	    INS 	HOME	SPACE
;
; 9	    NUM 4	NUM 3	NUM 2	NUM 1	NUM 0	NUM /	NUM +	NUM *
; 10	NUM .	NUM ,	NUM -	NUM 9	NUM 8	NUM 7	NUM 6	NUM 5
    
    
    
    
