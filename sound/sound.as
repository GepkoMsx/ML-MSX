;   .org 0x8200
;; first sound test

    .equ SAMPLE_DATA, 0x4000

    .section .text
    .nolist
    .include "Macros.asc"
    .list

Start_Audio:
    SetScreen 5, on                ; Change screenmode.

    call Init_PSG_For_Samples

    DI
    ; 1. Zet Line Interrupt aan in VDP Register 0
    SetVDP 0, 0b00010000           ; Bit 4 = IE1 (Line Interrupt Enable)
    SetVDP 19, 16                  ; 2              ; Elke 2 scanlijnen

    ; 3. Kaap de interrupt vector op 0x0038
    LD A, 0xC3                     ; JP instructie
    LD (0x0038), A
    LD HL, Audio_ISR               ; Adres van onze nieuwe routine
    LD (0x0039), HL
    
    ; 4. Zet pointers klaar voor de ISR
    EXX
    LD HL,SAMPLE_DATA              ; Start van je 4KB sample
    LD D, 0                        ; CURRENT LINE
    EXX
    EI

einde:
Main_Loop:
    ; 1. Wacht op de V-Sync (Bit 7 van S#0)
WaitVsync:
    IN A,(VDPC)                    ; LEES S#0 (Vlag wordt nu gereset door de VDP!)
    AND 0x80
    JR Z, WaitVsync                ; Geen V-Sync? Blijf pollen.


    ; test code
    ; ld a, (0x7FFF)
    ; inc a
    ; ld (0x7FFF), a
    ; cp 50
    ; jr nz, .cont
    ; ld a, (0x7FFE)
    ; inc a
    ; ld (0x7FFE),a
    ; xor a
; .cont
;     ld (0x7FFF), a



    ; 2. RESET DE CHASE
    ; DI
    ; EXX
    ; LD D,2           ; Reset teller
    ; LD A,D
    ; OUT (0x99),A      ; Schrijf naar R19
    ; LD A,19+128
    ; OUT (0x99),A
    ; EXX
    ; EI


Wait0:
    IN A,(0x99)
    AND 0b10000000
    JR NZ,Wait0
    

    

    ; 3. VOER GAME LOGICA UIT
    ; Omdat de vlag al 0 is, hoef je hier NIET te wachten. 
    ; Je gaat pas bij de volgende ronde van Main_Loop weer wachten.
    ; CALL Game_Logic

;     ld b, 255
; .wait
;     ld ix, 0x42
;     djnz .wait
    
    JR Main_Loop


Audio_ISR:
    DI
    EX AF,AF'                      ; 'Bewaar AF
    EXX                            ; Wissel naar schaduwregisters BC, DE, HL

 ;   ld a, 15 : out (0x99), a : ld a, 7+128 : out (0x99), a ; Wit (Start)

    ; --- VDP Interrupt Bevestigen ---
    SetVDP 15, 1                   ; Selecteer Status Register 1
    IN A,(VDPC)                    ; Lees S#1 (reset vlag)

; line chase
    LD A,D
    ADD A,3                        ; Tel 2 lijnen op voor 7812Hz 3 voor 5208Hz
    LD D,A
    OUT (0x99),A                   ; Schrijf nieuwe lijn naar VDP
    LD A,19+128                    ; Register 19
    OUT (0x99),A


    ; check of HL >=8000
    ld a, h
    ; cp 0xFF
    ; jr Z, .ready
    cp 0x80
    jr Z, .einde

    ; --- Sample naar PSG sturen ---
    LD A,(HL)                      ; Haal de huidige sample byte (0-255)
;    add a,64            ; 1 sample dus +64
    

; A bevat de gemixte sample (0-255)
    ADD A, A                       ; Index * 2
    LD C, A                        ; BC wijst nu naar de 2-byte entry
    ld A, 0                        ; A = 0 (Carry blijft behouden!)
    ADC A, 0x80                    ; A = 0 + 0x80 + Carry
    LD  B, A

    ; --- PSG Output ---
    LD  A, 8                       ; Pre-select Reg 8
    OUT (0xA0), A
    LD  A, (BC)                    ; Haal Byte 1 (Vol A + Vol B)
    
    ; Volume A (High Nibble)
    RLCA
    RLCA                           ; Verschuif 4 bits naar links
    RLCA
    RLCA                           ; (Nu staat High Nibble in Low Nibble)
    AND 0x0F                       ; Maskeer: we hebben nu Vol A
    OUT (0xA1), A                  ; Schrijf naar Reg 8 (al geselecteerd)
    
    ; Volume B (Low Nibble)
    LD A, 9
    OUT (0xA0), A                  ; Selecteer Reg 9
    LD  A, (BC)                    ; Haal Byte 1 (Vol A + Vol B)
    AND 0x0F                       ; Maskeer: we hebben nu Vol B
    OUT (0xA1), A
    
    ; Volume C (Byte 2)
    ld A, 10
    OUT (0xA0), A                  ; Selecteer Reg 10
    INC BC                         ; Volgende byte in LUT
    LD  A, (BC)                    ; Bevat alleen Vol C
    OUT (0xA1), A
    
    inc HL

.ready:
    
;     --- CRUCIAAL: ZET VDP POINTER TERUG NAAR S#0 ---
    XOR A
    OUT (0x99),A
    LD  A,15+128                   ; Selecteer Status Register 0
    OUT (0x99),A
    
    ; ld a, 0xFF
    ; ld (0x7FFC), a


   ; ld a, 0 : out (0x99), a : ld a, 7+128 : out (0x99), a  ; Zwart (Klaar)
    
    EXX                            ; Herstel registers
    EX AF,AF'                      ; '
    EI                             ; Interrupts weer aan
    RETI                           ; Terug naar hoofdprogramma

.einde:
    ld hl, 0x4000
    ; LD A, 8
    ; out (0xA0),a         ; Zet op Reg 8 
    ; xor a               ; Volume voor Reg 8 op 0
    ; OUT (0xA1),A         
    
    ; INC E               ; Volgende byte in LUT (Reg 9)
    ; LD A, 9
    ; LD (0xA0),A          ; Selecteer Reg 9
    ; xor a               ; Volume voor Reg 9 op 0
    ; OUT (0xA1),A
    ; LD H, 0xFF

  ;  ld a, 9 : out (0x99), a : ld a, 7+128 : out (0x99), a  ; rood (Klaar)
    EXX                            ; Herstel registers
    EX AF,AF'                      ; '
    EI                             ; Interrupts weer aan
    RETI                           ; Terug naar hoofdprogramma



Init_PSG_For_Samples:
    ; 1. Frequentie A en B op minimum (DC-offset)
    SetSND 0, 1
    SetSND 1, 0
    SetSND 2, 1
    SetSND 3, 0
    SetSND 4, 1
    SetSND 5, 0

    ; 2. Mixer: Toon A+B aan, rest uit
    SetSND 7, 0xB8

    ; 3. Selecteer vast Register 8 (bespaart tijd in ISR)
    LD A,8
    OUT (0xA0),A
    RET

    .section .data
    
CURRENT_LINE:
    .byte 0x00