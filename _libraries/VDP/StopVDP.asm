;; CALL StopVDP
;;
    
; stops the vdp with whatever its doing.
    .macro StopVDP

    SetVDP 17, 46                  ; Load Register 46 (Command Register) via R17
    xor a                          ; A = 0 (STOP-command)
    out (0x9b), a
    SetVDP 15, 0                   ; Reset Status Register to 0

    .endm