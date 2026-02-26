; ==[ LOADFAT ]===============================================
;; Laadt de FAT1 (file allocation table) van drive A in DISKBUFFER.
;;
;; INPUT:
;; - DISKSLOT:  (1)   Adres waar het slotnummer van de diskrom staat.
;; - MEDIADESC: (1)   Media descriptor byte (F8 voor 360Kb, F9 voor 720Kb).
;;
;; OUTPUT:
;; - DISKBUF: ($600) Adres waar de FAT1 wordt geladen (512*3 = 1536 bytes).
;;
;; Gebruikt JUMP-labels:
;; - RETERR:         Adres waar naartoe gesprongen wordt bij een fout tijdens het laden van de bootsector.
;;
;; Gebruikt BIOS-routines:
;; - PHYDIO:         Fysieke schijf I/O. Zie info.txt
;; - CALSLT:         Inter-slot calls. Zie info.txt

    ld a, (DISKSLOT)    ; Haal slotnummer van diskrom
    ld iyh, a            
    ld ix, PHYDIO
    or a                ; Carry flag 0 = Lezen (1 = Schrijven) (force carry = 0)
    ld a, 0             ; Drive A: (0=A, 1=B)
    ld b, 3             ; Aantal sectoren om te lezen (We lezen 1 FAT, die is 2 of 3 sectoren)
    ld hl, MEDIADESC
    ld c, (hl)          ; Media ID (F8/F9)
    ld de, 1            ; Start op sector 1 (FAT begint na bootsector)
    ld hl, DISKBUF      ; Bestemmingsadres in RAM, Diskbuffer
    call CALSLT         ; Roep BIOS inter-slot call aan
    jp c, RETERR        ; Als Carry=1, dan fout.

; ==[ End LOADFAT ]===============================================