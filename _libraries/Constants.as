;; BIOS Calls
;; ----------

;; geheugen
CALSLT: equ $001C       ; Inter-slot calls. Input: IYh: SlotId, IYl:0, IX:doeladres.

;; scherm
CHGMOD  equ $005F       ; Zet de screen mode en wis scherm. Input: a: screen mode. Output: niets.

;; keyboard
CHPUT   equ $00A2       ; Print een karacter op het scherm. Input: a: karacter code. Output: niets.
CHGET   equ $009F       ; Wacht en lees een karacter van het toetsenbord. Input: niets. Output: a: karacter code.
CHSNS   equ $009C       ; Lees de status van het toetsenbord. Input: niets. Output: Zero flag: 0 = er is een toets ingedrukt, 1 = er is geen toets ingedrukt.
SNSMAT  equ $0141       ; Lees de status van de keyboard matrix. Input: a: te lezen rij. Output: a: status van rij. Zie info.txt

;; diskdrive             ; altijd met calslt!
PHYDIO: equ $4010       ; Fysieke schijf I/O. Zie info.txt

;; IO ports
VDPD    equ $98         ;VDP Data port      (lees en schrijf data)
VDPC    equ $99         ;VDP Control Port   (instellen vram adres, schrijf registers R0-R7, lees status S0-)
VDPP    equ $9A         ;VDP Pallette poort (instellen kleuren: 2x R/B en dan G)
VDPR    equ $9B         ;VDP Registers      (schrijf resisters R8-46 via r17, en sturen pixeldata voor commandos)

;; Interrupts/time
JIFFY   equ $FC9E       ; address van nr of itnerrupts (50 or 60 per sec) 
MSXID   equ $002B       ; de ID byte bit 7 heeft snelheid aan 950/60 hertz)