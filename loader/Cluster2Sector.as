; ==[ Cluster2Sector ]===============================================
;; Converteert een clusternummer naar een sectornummer
;;
;; INPUT:
;; - DE:             Clusternummer
;; - MEDIADESC: (1)  Adres waar de media descriptor byte wordt opgeslagen.
;;
;; OUTPUT:
;; - DE:             Sectornummer

    ex de, hl          ; HL = Cluster (wissel de en hl)
    dec hl             ; Cluster-nummers beginnen bij 2, dus we moeten 2 van het cluster aftrekken
    dec hl
    add hl, hl         ; Cluster-gedeelte
    ld a, (MEDIADESC)
    sub $F8 - 6        ; media offset is 12, dus nu de helft (6) minder aftrekken komen we goed uit.
    add a, a           ; anders moeten we er weer 12 bijtellen.
    ld e, a
    ld d, 0
    add hl, de         ; HL = Cluster-gedeelte + Media-offset gedeelte
    ex de, hl          ; DE = Sector
; ==[ End Cluster2Sector ]===============================================
