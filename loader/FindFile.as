; ==[ FINDFILE ]===============================================
;; Vindt een bestand in de rootdirectory van een FAT12 diskette.
;; Bestandsnaam staat in FILENAME structuur.
;; StartCluster en FileSize worden opgeslagen in FILENAME structuur.
;;
;; INPUT:
;; - DISKBUF: ($E00) Adres waar de rootdirectory is geladen (112*32 = 3584 bytes).
;; - DE:             De Entry in de FILENAME structuur dat we zoeken.
;;
;; OUTPUT:
;; - DE+11:         Startcluster van het bestand (2 bytes).
;; - DE+13:         Filesize van het bestand (4 bytes).
;;
;; Gebruikt JUMP-labels:
;; - RETERR:         Adres waar naartoe gesprongen wordt bij een fout tijdens het laden van de bootsector.
;;
;; Gebruikt routines:
;; - CompareStrings: Vergelijkt twee strings van een opgegeven lengte.

    push bc             
    push de             
    ld HL, DISKBUF      ; Punt naar rootdirectory (Diskbuffer)
    ld B, 112           ; Max aantal bestanden in rootdirectory

FindFile_loop:
    push bc             ; Bewaar BC (aantal bestanden)
    ld b, 11            ; Aantal bytes om te vergelijken (filename is 8+3 bytes)
    call CompareStrings ; Vergelijk bestandsnaam met huidige directory entry
    pop bc              
    jr z, FindFileOK    ; Als gevonden, ga naar door
    push de
    ld de, $20
    add HL, de          ; Ga naar volgende directory entry (32 bytes per entry)
    pop de
    djnz FindFile_loop  ; Ga naar volgende directory entry als niet gevonden

FindFileNOK:
    ld a, 100           ; return integer voor "bestand niet gevonden op disk"    
    jp RETERR           ; Bestand niet gevonden, terug naar BASIC

FindFileOK:             ; Bestand gevonden.  Bewaar de info.
    ld bc, 26
    add hl, bc          ; HL wijst nu naar directory entry van het bestand

    ex de, hl          
    ld bc, 11
    add hl, bc          ; DE wijst nu naar StartCluster in FILENAME structuur
    ex de, hl           ; Herstel HL (wijst nog steeds naar directory entry)

    ld bc, 6            ; copy 6 byes van HL (directory entry) naar DE (FILENAME structuur)
    ldir                ; dit zijn de 2 bytes startcluster + 4 bytes filesize

    pop de              
    pop bc      
; ==[ End FindFile ]===============================================