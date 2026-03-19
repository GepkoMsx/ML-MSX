;; first sound test

VDP_DATA:   EQU $98
VDP_REG:    EQU $99
SAMPLE_DATA: EQU $4000

    org $8200

MAIN:

Start_Audio:
    ld HL, Screen5_Table
    CALL Screen              ; Change screenmode. <HL> address of table in this file.
    call waitvdp

    call Init_PSG_For_Samples

    DI
    ; 1. Zet Line Interrupt aan in VDP Register 0
    LD A,%00010000      ; Bit 4 = IE1 (Line Interrupt Enable)
    OUT (VDP_REG),A
    LD A,$80            ; Register 0 selecteren
    OUT (VDP_REG),A

    ; 2. Stel het aantal lijnen in op 2 (VDP Register 19)
    LD A,16;2              ; Elke 2 scanlijnen
    OUT (VDP_REG),A
    LD A,$93            ; Register 19 selecteren (19 + 128)
    OUT (VDP_REG),A

    ; 3. Kaap de interrupt vector op $0038
    LD A,$C3            ; JP instructie
    LD ($0038),A
    LD HL,Audio_ISR     ; Adres van onze nieuwe routine
    LD ($0039),HL
    
    ; 4. Zet pointers klaar voor de ISR
    EXX
    LD HL,SAMPLE_DATA        ; Start van je 4KB sample
    LD D, 0                  ; CURRENT LINE
    EXX
    EI

einde:
Main_Loop:
    ; 1. Wacht op de V-Sync (Bit 7 van S#0)
WaitVsync:
    IN A,($99)               ; LEES S#0 (Vlag wordt nu gereset door de VDP!)
;    ld ($7FFD), a
    AND $80
    ; ld a, 0
    ; ld ($7FFC), a
    JR Z, WaitVsync  ; Geen V-Sync? Blijf pollen.


    ; test code
    ; ld a, ($7FFF)
    ; inc a
    ; ld ($7FFF), a
    ; cp 50
    ; jr nz, .cont
    ; ld a, ($7FFE)
    ; inc a
    ; ld ($7FFE),a
    ; xor a
; .cont
;     ld ($7FFF), a



    ; 2. RESET DE CHASE
    ; DI
    ; EXX
    ; LD D,2           ; Reset teller
    ; LD A,D
    ; OUT ($99),A      ; Schrijf naar R19
    ; LD A,19+128
    ; OUT ($99),A
    ; EXX
    ; EI


Wait0:
    IN A,($99)
    AND %10000000
    JR NZ,Wait0
    

    

    ; 3. VOER GAME LOGICA UIT
    ; Omdat de vlag al 0 is, hoef je hier NIET te wachten. 
    ; Je gaat pas bij de volgende ronde van Main_Loop weer wachten.
    ; CALL Game_Logic

;     ld b, 255
; .wait
;     ld ix, $42
;     djnz .wait
    
    JR Main_Loop


Audio_ISR:
    DI
    EX AF,AF'           ; Bewaar AF
    EXX                 ; Wissel naar schaduwregisters BC, DE, HL

 ;   ld a, 15 : out ($99), a : ld a, 7+128 : out ($99), a ; Wit (Start)

    ; --- VDP Interrupt Bevestigen ---
    LD A,1
    OUT ($99),A
    LD A,15+128      ; Selecteer Status Register 1
    OUT ($99),A
    IN A,($99)       ; Lees S#1 (reset vlag)

; line chase
    LD A,D
    ADD A,3             ; Tel 2 lijnen op voor 7812Hz 3 voor 5208Hz
    LD D,A
    OUT ($99),A         ; Schrijf nieuwe lijn naar VDP
    LD A,19+128         ; Register 19
    OUT ($99),A


    ; check of HL >=8000
    ld a, h
    ; cp $FF
    ; jr Z, .ready
    cp $80
    jr Z, .einde

    ; --- Sample naar PSG sturen ---
    LD A,(HL)           ; Haal de huidige sample byte (0-255)
;    add a,64            ; 1 sample dus +64
    

; A bevat de gemixte sample (0-255)
    ADD A, A            ; Index * 2
    LD C, A             ; BC wijst nu naar de 2-byte entry
    ld A, 0             ; A = 0 (Carry blijft behouden!)
    ADC A, $80          ; A = 0 + $80 + Carry
    LD  B, A        

    ; --- PSG Output ---
    LD  A, 8            ; Pre-select Reg 8
    OUT ($A0), A
    LD  A, (BC)         ; Haal Byte 1 (Vol A + Vol B)
    
    ; Volume A (High Nibble)
    RLCA
    RLCA                ; Verschuif 4 bits naar links
    RLCA
    RLCA                ; (Nu staat High Nibble in Low Nibble)
    AND $0F             ; Maskeer: we hebben nu Vol A
    OUT ($A1), A        ; Schrijf naar Reg 8 (al geselecteerd)
    
    ; Volume B (Low Nibble)
    LD A, 9
    OUT ($A0), A        ; Selecteer Reg 9
    LD  A, (BC)         ; Haal Byte 1 (Vol A + Vol B)
    AND $0F             ; Maskeer: we hebben nu Vol B
    OUT ($A1), A
    
    ; Volume C (Byte 2)
    ld A, 10
    OUT ($A0), A       ; Selecteer Reg 10
    INC BC               ; Volgende byte in LUT
    LD  A, (BC)              ; Bevat alleen Vol C
    OUT ($A1), A
 
    inc HL

.ready:
    
;     --- CRUCIAAL: ZET VDP POINTER TERUG NAAR S#0 ---
    XOR A
    OUT ($99),A
    LD  A,15+128      ; Selecteer Status Register 0
    OUT ($99),A   
    
    ; ld a, $FF
    ; ld ($7FFC), a


   ; ld a, 0 : out ($99), a : ld a, 7+128 : out ($99), a  ; Zwart (Klaar)
    
    EXX                 ; Herstel registers
    EX AF,AF'
    EI                  ; Interrupts weer aan
    RETI                ; Terug naar hoofdprogramma

.einde:
    ld hl, $4000
    ; LD A, 8
    ; out ($A0),a         ; Zet op Reg 8 
    ; xor a               ; Volume voor Reg 8 op 0
    ; OUT ($A1),A         
    
    ; INC E               ; Volgende byte in LUT (Reg 9)
    ; LD A, 9
    ; LD ($A0),A          ; Selecteer Reg 9
    ; xor a               ; Volume voor Reg 9 op 0
    ; OUT ($A1),A
    ; LD H, $FF

  ;  ld a, 9 : out ($99), a : ld a, 7+128 : out ($99), a  ; rood (Klaar)
    EXX                 ; Herstel registers
    EX AF,AF'
    EI                  ; Interrupts weer aan
    RETI                ; Terug naar hoofdprogramma



Init_PSG_For_Samples:
    ; 1. Frequentie A en B op minimum (DC-offset)
    LD A,0 : OUT ($A0),A : LD A,1 : OUT ($A1),A ; Reg 0 = 1
    LD A,1 : OUT ($A0),A : LD A,0 : OUT ($A1),A ; Reg 1 = 0
    LD A,2 : OUT ($A0),A : LD A,1 : OUT ($A1),A ; Reg 2 = 1
    LD A,3 : OUT ($A0),A : LD A,0 : OUT ($A1),A ; Reg 3 = 0
    LD A,4 : OUT ($A0),A : LD A,1 : OUT ($A1),A ; Reg 2 = 1
    LD A,5 : OUT ($A0),A : LD A,0 : OUT ($A1),A ; Reg 3 = 0

    ; 2. Mixer: Toon A+B aan, rest uit
    LD A,7 : OUT ($A0),A
    LD A,$B8 ; %10111000
    OUT ($A1),A

    ; 3. Selecteer vast Register 8 (bespaart tijd in ISR)
    LD A,8
    OUT ($A0),A
    RET

    include "screen.asc"
    include "waitvdp.asc"

CURRENT_LINE:
    db 0