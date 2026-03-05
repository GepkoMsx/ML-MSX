;; BIOS Calls
CHGMOD  equ $005F            ; Zet de screen mode en wis scherm. Input: a: screen mode. Output: niets.
INITXT  equ $006C            ; Initialiseert de VDP voor de tekstmodus (40x24 karakters) en wist het scherm.

;; Memory
CALSLT  equ $001C            ; Inter-slot calls. Input: IYh: SlotId, IYl:0, IX:doeladres.
EXTBIO  equ $FFCA            ; Extended BIOS (ex: memory mapper of msx-dos2)
MAPTBL  equ $F247            ; MSX-DOS 2 memory map table.
EXPTBL  equ $FCC1            ; Expanded slots table.

;; Display
VDPD    equ $98              ; VDP Data port      (lees en schrijf data)
VDPC    equ $99              ; VDP Control Port   (instellen vram adres, schrijf registers R0-R7, lees status S0-)
VDPP    equ $9A              ; VDP Pallette poort (instellen kleuren: 2x R/B en dan G)
VDPR    equ $9B              ; VDP Registers      (schrijf resisters R8-46 via r17, en sturen pixeldata voor commandos)
SCRMOD  equ $FCAF            ; mirror for selected screen mode

;; Keyboard
CHPUT   equ $00A2            ; Print een karacter op het scherm. Input: a: karacter code. Output: niets.
CHGET   equ $009F            ; Wacht en lees een karacter van het toetsenbord. Input: niets. Output: a: karacter code.
CHSNS   equ $009C            ; Lees de status van het toetsenbord. Input: niets. Output: Zero flag: 0 = er is een toets ingedrukt, 1 = er is geen toets ingedrukt.
SNSMAT  equ $0141            ; Lees de status van de keyboard matrix. Input: a: te lezen rij. Output: a: status van rij. Zie info.txt

;; Diskdrive            ; altijd met calslt!
PHYDIO: equ $4010            ; Fysieke schijf I/O. Zie info.txt

;; Interrupts/time
JIFFY   equ $FC9E            ; address van nr of interrupts (50 or 60 per sec)
MSXID   equ $002B            ; de ID byte bit 7 heeft snelheid aan 50/60 hertz)

;; MSX-DOS 1/2
BDOS   equ $0005             ; dos calls

;; Shared Data Block
STARTDATA   equ $103
MSXDOSVER   equ STARTDATA+0  ; 1  [012] MSX-DOS version (0,1,2)                               DOSVersion.asc
MEMNRBANKS  equ STARTDATA+1  ; 1  [01-] total nr of memory-mapped segments available.	     memMapCheck.asc
MEMPAGE0    equ STARTDATA+2  ; 1  [01-] Loaded segment in page 0			                     memMapCheck.asc
MEMPAGE3    equ STARTDATA+3  ; 1  [01-] Loaded segment in page 3			                     memMapCheck.asc
MEMMAPTBL   equ STARTDATA+4  ; 2  [--2] address of MAPTBL                                     DOSVersion.asc
MEMSET      equ STARTDATA+6  ; 3  [012] jump to right set-page function   (new page)          DOSVersion.asc
MEMRESET    equ STARTDATA+9  ; 3  [012] jump to right reset-page function (old page)          DOSVersion.asc
MEMSEGMENTS equ STARTDATA+12 ; 16 [012] Array of segment requested			                 memLoadSegment.asc
