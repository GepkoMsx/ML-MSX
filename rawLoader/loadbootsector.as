; ==[ LOADBOOTSECTOR ]===============================================
;; Laadt de bootsector van drive A in RAM en controleert het media descriptor byte.
;; De media descriptor byte wordt opgeslagen op het adres MEDIADESC voor later gebruik.
;;
;; INPUT:
;; - DISKSLOT: (1)   Adres waar het slotnummer van de diskrom staat.
;;
;; OUTPUT:
;; - DISKBUF:  (512) Adres waar de bootsector wordt geladen (54k bytes).
;; - MEDIADESC:(1)   Adres waar de media descriptor byte wordt opgeslagen.
;; - A:              Media descriptor byte uit bootsector (offset $15) (alleen als laden succesvol is)
;; - Zero flag:      0 = 360Kb disk, 1 = 720Kb disk
;;
;; Gebruikt JUMP-labels:
;; - RETERR:         Adres waar naartoe gesprongen wordt bij een fout tijdens het laden van de bootsector.
;;
;; Gebruikt BIOS-routines:
;; - PHYDIO:         Fysieke schijf I/O. Zie info.txt
;; - CALSLT:         Inter-slot calls. Zie info.txt

    ld a, (DISKSLOT)     ; Haal slotnummer van diskrom
    ld iyh, a            
    ld ix, PHYDIO
    or a                ; Carry flag 0 = Lezen (1 = Schrijven) (force carry = 0)
    ld a, 0             ; Drive A: (0=A, 1=B)
    ld b, 1             ; Aantal sectoren om te lezen
    ld c, $F9           ; Media Descriptor (F8/F9)
    ld de, 0            ; Start sectornummer (0 = bootsector)
    ld hl, DISKBUF      ; Bestemmingsadres in RAM
    call CALSLT         ; Roep BIOS inter-slot call aan

    jp c, RETERR        ; Als Carry=1, dan fout.
                        ; De sector staat nu op $A000
    ld a, (DISKBUF + $15) ; Lees Media Descriptor Byte uit bootsector (offset $15)
    ld (MEDIADESC), a   ; Sla media descriptor op voor later gebruik
    cp $F8              ; Is het een 360kb disk?

; ==[ End LOADBOOTSECTOR ]===============================================