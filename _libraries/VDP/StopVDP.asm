;; CALL StopVDP
;;
    
; stops the vdp with whatever its doing.
    .macro StopVDP
    ld a, 46                       ; Load Register 46 (Command Register) via R17
    out (0x99), a
    ld a, 0x91                     ; 0x80 (write) + 0x11 (R17) = 0x91 (indirect register)
    out (0x99), a
    
    xor a                          ; A = 0 (STOP-command)
    out (0x9b), a
    
    xor a                          ; Reset Status Register to 0
    out (0x99), a
    ld a, 0x8f                     ; R15 = 0
    out (0x99), a
    .endm