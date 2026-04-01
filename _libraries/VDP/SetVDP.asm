;; MACRO SetVDP
;; Sets a VDP register directly.  
;;  SetVDP 1, 0x28
;; 
    .macro SetVDP reg val
     ld a, \val
     out  (VDPC), a
     ld a, \reg + 0x80             ; write
     out  (VDPC), a
    .endm