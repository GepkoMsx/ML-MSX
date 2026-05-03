;; MACRO SetSND
;; Sets a SOUND register directly.  
;;  SetSND 1, 0x28
;; 
    .macro SetSND reg val
    LD A, \reg
    OUT (0xA0),A
    LD A,\val
    OUT (0xA1),A
    .endm