;; ==[ MACRO Multiply ]===============================================
;; Input:  BC = Getal 1, DE = Getal 2
;; Output: HL = Resultaat (16-bit)      HL = BC * DE
    
; <HL> = <BC> * <DE>    
    .macro Multiply
    
    ld a, 16                       ; We gaan 16 bits af (gebruik A i.p.v. B voor de teller)
    
Multiply.Loop\@:
    add hl, hl                     ; Verschuif het resultaat (HL = HL * 2)
    sla c                          ; Schuif het meest linkse bit van BC naar de Carry flag
    rl b                           ; (SLA C en RL B schuiven samen het 16-bit paar BC)
    jr nc, Multiply.NoAdd\@        ; Als het bit 0 was, hoeven we DE niet op te tellen
    add hl, de                     ; Als het bit 1 was: HL = HL + DE
    
Multiply.NoAdd\@:
    dec a
    jr nz, Multiply.Loop\@
    
    .endm