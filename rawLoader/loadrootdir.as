; ==[ LOADROOTDIR ]===============================================
;; Laadt de root directory van drive A in RAM.
;;
;; INPUT:
;; - DISKSLOT: (1)   Adres waar het slotnummer van de diskrom staat.
;; - de:             Start sector van de rootdirectory (5 voor 360Kb, 7 voor 720Kb).
;; - c:              Media descriptor byte (F8 voor 360Kb, F9 voor 720Kb).
;;
;; OUTPUT:
;; - DISKBUF:  ($E00)Adres waar de rootdirectory wordt geladen (112*32 = 3584 bytes).
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
    ld b, 7             ; Aantal sectoren om te lezen
    ld hl, DISKBUF      ; Bestemmingsadres in RAM, Diskbuffer
    call CALSLT         ; Roep BIOS inter-slot call aan
    jp c, RETERR        ; Als Carry=1, dan fout.

; ==[ End LOADROOTDIR ]===============================================