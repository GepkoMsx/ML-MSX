; ==[ CalcSectors ]===============================================
;; Berekent het aantal sectoren dat gelezen moet worden voor een bestand, 
;; op basis van de file size in de filename structuur.
;;
;; INPUT:
;; - IX:        (17) Locatie van filename structuur
;;
;; OUTPUT:
;; - BC:             Aantal sectoren om te lezen
;; 
;; Info:
;; Sectoren = (Filesize + 511) / 512.
;;
;; filename structuur:
;; 0-10: bestandsnaam (8 bytes naam + 3 bytes extensie)
;; 11-12: startcluster (2 bytes, little-endian)
;; 13-16: file size (4 bytes, little-endian)

    ld l, (IX+13)       ; Laad byte 0 (Low byte)
    ld h, (IX+14)       ; Laad byte 1 (Med byte)
    ld a, (IX+15)       ; Laad byte 2 (High byte van de relevante 24 bits)

    ld de, 511
    add hl, de          ; Tel 511 op bij de file size
    adc a, 0            ; Vergeet niet de carry van de low word optelling    

    ld c, h             ; Deel door 512 (9 keer naar rechts schuiven) (we gaan van AHL naar ABC, en dan schuiven in 1x )
    ld b, a             ; Truc: 8 keer schuiven is hetzelfde als de registers een plekje opschuiven!
    srl b               ; Verschuif nog 1x: 
    rr c                ; Verschuif H, bit 0 gaat naar Carry, Verschuif L, Carry gaat naar bit 7 van L
   
; ==[ End CalcSectors ]===============================================