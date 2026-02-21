; ==[ Constants ]===============================================
    include "Constants.as"

DISKSLOT: equ $FFA8     ; Slot van diskrom via H.PHYD hook.
NROFILES: equ 2         ; Aantal bestanden die geladen moeten worden.
FNSIZE:   equ 21        ; Grootte van een (1) FILENAME structuur

DISKBUF:  equ $E000     ; Adres waar bootsector wordt geladen (4k bytes) 
MEMBUFFER:equ $E000     ; tijdelijk voor memmapcheck (32 bytes)

; ==[ Header ]==================================================
    org $D000
    include "BloadHeader.as"

; ==[ Program ]=================================================
Main:                   
    push iy             ; Bewaar IY register heeft basic nodig na ret.

    call memMapCheck    ; Check the memory banks first.
    call MemSwapPage1   ; get rid of basic :)

    include "LoadBootSector.as"
    jp z, Load360kb     ; Zero? 360Kb, anders 720Kb. MEDIADESC is ingesteld.

Load720kb:
    ld de, 7            ; start op sector 7
    ld c, $F9           ; Media ID F9
    jp LoadRootDir

Load360kb:
    ld de, 5            ; start op sector 5
    ld c, $F8           ; Media ID F8

LoadRootDir:
    include "LoadRootDir.as"    ; Nu is de rootdirectory geladen in DISKBUF

FindClusters:
    ld b, NROFILES      ; Aantal bestanden om te zoeken                        
    ld DE, FILENAME     ; Punt naar filename structuur (hello.bin)
FiCl_loop:
    push bc

    include "FindFile.as"   ; Zoek het bestand in de rootdirectory en update FILNAME structuur

    ex de, hl
    ld bc, FNSIZE       ; Ga naar volgende filename structuur 
    add hl, bc          
    ex de, hl
    pop bc
    djnz FiCl_loop

    include "loadfat.as"        ; Nu is de FAT1 geladen in DISKBUF

LoadFiles:
    ld b, NROFILES      ; Aantal bestanden om te zoeken       
    ld ix, FILENAME     ; Punt naar filename structuur
        
LoadFile:       
    push bc  
    push ix               
    
    ld l, (IX+17)       ; HL: Bestemmingsadres in RAM waar we het bestand willen laden
    ld h, (IX+18)      
    PUSH HL
    call MemAddr2Page   ; HL: address ==> C: page-port
    ld b, (IX+19)       ; B: Memorymapper segment (0-MEMNRBANKS)
    call MemLoadSegment

    include "CalcSectors.as"    ; Bereken aantal sectoren om te lezen, resultaat in BC

    POP HL
    PUSH HL
    include "loadfile.as"    ; Laad het bestand in RAM, aantal sectoren in BC, ram in HL, filestructuur in IX

    POP HL              ; We gaan het nu starten. (maar niet alles is te starten!? )
    pop IX
    ld a, (IX+20)       ; a==0 = dont run
    or a                
    jr z, LoadFileRet

    ld bc, 7            ; OK we run the loaded file.
    add HL, bc          ; $XXX7 is het standaard adres om te starten.. (voor nu goed genoeg) 
    ld de, LoadFileRet  ; Boots een CALL (HL) na.
    push de
    jp (HL)             ; Spring naar het begin van het geladen bestand (Main)

LoadFileRet:
    ld bc, FNSIZE       ; Ga naar volgende filename structuur 
    add ix, bc          
    pop bc
    dec b
    jp nz, LoadFile       ; Als er nog bestanden zijn, laad ze ook

THE_END:  
RETERR:
ERR_loadfile: 
    DI                  ; we zijn klaar. Alles ingegelezen en gestart. 
    HALT                ; (of het ging fout..)


; ==[ Subroutines ]=============================================
    include "CompareStrings.asc"
    include "GetNextCluster.asc"
    include "memMapCheck.asc"
    include "memSwapPage1.asc"
    include "memAddr2Page.asc"
    include "memLoadSegment.asc"

; ==[ Data ]====================================================
MEDIADESC:
    db $F8              ; Media descriptor van huidige disk
MEMNRBANKS:             
    db 0                ; Nr of slots the memorymapper has
MEMPAGE3:
    db 0                ; What memoryslot is loaded in page3 

FILENAME:               ; vergeet NROFILES niet bij te werken als je hier iets aanpast!
; HELLO example
    ; db "HELLO   BIN"    ; bestandsnaam, 11 bytes (8 voor naam + 3 voor extensie)
    ; dw 0,0,0            ; BUFFER first cluster (2 bytes, little-endian) & file size (4 bytes, little-endian)
    ; dw $8300            ; destination to load in memory
    ; db 4                ; on memorybank segment.
    ; db 1                ; 1 = run it 0 = dont run

    ; db "HELLO2  BIN"    ; bestandsnaam, 11 bytes (8 voor naam + 3 voor extensie)
    ; dw 0,0,0            ; BUFFER first cluster (2 bytes, little-endian) & file size (4 bytes, little-endian)
    ; dw $4000            ; destination in memory
    ; db 5                ; on memorybank segment
    ; db 0                ; 1 = run it 0 = dont run

    ; db "HELLO3  BIN"    ; bestandsnaam, 11 bytes (8 voor naam + 3 voor extensie)
    ; dw 0,0,0            ; BUFFER first cluster (2 bytes, little-endian) & file size (4 bytes, little-endian)
    ; dw $8000            ; destination in memory
    ; db 6                ; on memorybank segment
    ; db 1                ; 1 = run it 0 = dont run

; AZUL
    ; db "PAGE4   SC8"
    ; dw 0,0,0
    ; dw $4000
    ; db 4
    ; db 0

    ; db "PAGE5   SC8"
    ; dw 0,0,0
    ; dw $4000
    ; db 5
    ; db 0

    ; db "AZUL    BIN"
    ; dw 0,0,0
    ; dw $8000
    ; db 3
    ; db 1

; RLE_PIC
    db "BANNER2 RL8"
    dw 0,0,0
    dw $4000
    db 4
    db 0

    db "RLE_PIC8BIN"
    dw 0,0,0
    dw $8000
    db 3
    db 1

FileEnd:
