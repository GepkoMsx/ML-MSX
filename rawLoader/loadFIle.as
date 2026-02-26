; ==[ LOADFILE ]===============================================
;; Laadt een bestand van drive A in RAM
;;
;; INPUT:
;; - DISKSLOT:  (1)   Adres waar het slotnummer van de diskrom staat.
;; - MEDIADESC: (1)   Media descriptor byte (F8 voor 360Kb, F9 voor 720Kb).
;; - DISKBUF: ($600)  Adres waar de FAT1 is geladen (512*3 = 1536 bytes).
;; - IX               Bestand in FILENAME scructuur om in te lezen
;; - HL               Bestemmingsadres in RAM waar het bestand geladen moet worden.
;; - BC               Aantal sectoren om te lezen (berekend door CalcSectors)
;;
;; OUTPUT:
;; - Het bestand is geladen in RAM op het adres dat in HL staat bij aanvang van LoadFile.
;;
;; Gebruikt JUMP-labels:
;; - ERR_loadfile:   Adres waar naartoe gesprongen wordt bij een fout tijdens het laden van de bootsector.
;;
;; Gebruikt BIOS-routines:
;; - PHYDIO:         Fysieke schijf I/O. Zie info.txt
;; - CALSLT:         Inter-slot calls. Zie info.txt
;;
;; Gebruikt routines in andere bestanden:
;; - Cluster2Sector:  Converteert een cluster nummer in DE naar een sector nummer in DE, gebaseerd op de media descriptor in C.
;; - GetNextCluster:  Leest het volgende cluster nummer uit de FAT, gebaseerd op het huidige cluster nummer in DE, en plaatst het resultaat in DE.
;;
;; Opmerkingen:
;; - We lezen maximaal 255 sectoren (b), dus max 127Kb bestanden

    ld e, (ix+11)       ;
    ld d, (ix+12)       ; Start op cluster in filename structuur

    ld a, 0
    cp a, b             ; Check of BC < 256 
    jp nz, ERRBigfile   ; Zo ja, dan is het bestand te groot voor deze loader (max 127Kb)
    ld b, c

LoadFileLoop:
    push bc             ; Bewaar BC (aantal sectoren)
    push de             ; Bewaar DE (huidige cluster)
    push hl             ; Bewaar HL (bestemmingsadres)
    
    ld a, (DISKSLOT)    ; Haal slotnummer van diskrom
    ld iyh, a            
    ld ix, PHYDIO
    include "Cluster2Sector.as" ; Bereken sectornummer van huidige cluster in DE, resultaat in DE
    or a                ; Carry flag 0 = Lezen (1 = Schrijven) (force carry = 0)
    ld b, 2             ; Aantal sectoren om te lezen (cluster is altijd 2 sectoren)
    ld a, (MEDIADESC)   ; Media ID in c
    ld c, a         
    ld a, 0             ; Drive A: (0=A, 1=B)
    pop hl
    push hl

    call CALSLT         ; Roep BIOS inter-slot call aan
    jp c, POPERR        ; Als Carry=1, dan fout.
    
    pop hl              ; Herstel HL (bestemmingsadres)
    pop de              ; Herstel DE (huidige cluster)
    push hl
    call GetNextCluster ; laad volgende clusternummer uit FAT (FAT begint op $A000)    

    pop hl
    ld bc, 1024
    add hl, bc          ; Verhoog bestemmingsadres met 2 sectoren (1 cluster)
    pop bc              ; Herstel BC (aantal sectoren)

    dec b               ; Verlaag aantal sectoren met 1
    jr z, READY          
                        ; *2x omdat we 2 sectoren per cluster lezen*
    djnz LoadFileLoop   ; dec b, Als B niet nul is, ga naar LoadFileLoop
    jr READY

ERRBigfile:
    ld a, 101           ; Foutcode 101: Bestand te groot voor deze loader (max 127Kb)
    jp ERR_loadfile

POPERR:
    pop de
    pop hl
    pop bc
    jp ERR_loadfile

READY:   

; ==[ End LOADFILE ]===============================================