
;; MACRO SetVDP
;; Sets a VDP register directly.  
;;  SetVDP 1, 0x28
;; 
    .macro SetVDP reg val
     ld a, \val
     out  (0x99), a
     ld a, \reg + 0x80       ; write
    .endm

;; MACRO SetScreen
;; Switch to the right screen mode with VDP
;;  SetScreen 5, off
;; - screenmode: a constant                         
;; - screenon:  "on" or "off",                      
;; - IE0 enabled: "IE0" or "ID0"  (Enable Disable)  
;; - IE1 enabled: "IE1" or "ID1"  (Enable Disable)  
;; - Sprite Size: 8 or 16                           
;; 
;;
;; default:
;; - color 0 not transparant, sprites on, color display
;; - 212 lines, not interlaced, no even/odd page, 50Hz, 
;; - Vram not properly initialized with the VDP version
;;
    .macro SetScreen nr onoff IE0 IE1 sprite
     .nolist
     .set IE1\@, 0x00
     .ifc \IE1, "IE1"
         .set IE1\@, 0x10
     .endif

     .set M12\@, 0x00
     .if \nr == 0
         .set M12\@, 0x10
     .elseif \nr == 3
         .set M12\@, 0x08
     .endif

     .set M543\@, 0x00
     .if \nr == 2
         .set M543\@, 0x02
     .elseif \nr == 4
         .set M543\@, 0x04
     .elseif \nr == 5
         .set M543\@, 0x06
     .elseif \nr == 6
         .set M543\@, 0x08
     .elseif \nr == 7
         .set M543\@, 0x0A
     .elseif \nr == 8
         .set M543\@, 0x0E
     .endif

     .set BL\@, 0x00
     .ifc \onoff, "on"
          .set BL\@, 0x40
     .endif

     .set IE0\@, 0x00
     .ifc \IE0, "IE0"
         .set IE0\@, 0x20
     .endif

      .ifB \sprite
        .set SS\@, 0x00
      .else
        .set SS\@, (\sprite / 16) * 2 ; 0x00 for 8x8 0x01 for 16x16
      .endif
      .set vdp0\@, IE1\@ + M543\@
      .set vdp1\@, BL\@ + IE0\@ + M12\@ + SS\@

      .list
      SetVDP 0, vdp0\@
      SetVDP 1, vdp1\@
      SetVDP 8, 0x28
      SetVDP 9, 0x82
    .endm

; R#0:  00 DG IE2 IE1 M5 M4 M3 000      ; DG = 0 IE2 = 0  IE1 = X  M543 = YYY
;                                       ; So: 0b000XYYY0
; R#1:  00 BL IE0 M1  M2 00 SI MAG      ; BL = disable screen = 0, enable = 1   X
                                        ; IE0 = Z (VBLANK)
                                        ; M12 = YY
                                        ; SI = sprite size 1 = 16x16, 0 = 8x8   S
                                        ; MAG = magnify sprites (always 0 for now)
                                        ; So: 0b0XZYYS0

; R#8:  MS LP TP CB VR 00 SPD BW    ; MS = 0, LP = 0, TP = 0: color 0 transparant = 0  (set to 1)
                                    ; CB = 0, VR = 1, SPD = sprite disable (always on = 0)
                                    ; BW = grayscale 1, color 0 (always color)
                                    ; So: 0b0010100 (not transparant, sprites on, color display) = 0x28

; R#9:  LN 0 S1 S2 IL EO *NT DC     ; LN = 1 (212 lines), S10 = 0, IL = interlaced = 0, EO = even/odd = 0
                                    ; NT = 1 = 50 hz, DC = 0
                                    ; So: 0x82
    