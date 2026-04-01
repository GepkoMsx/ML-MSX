; GOAL: 
; - Set Memory up to use safely.
; 
; Setup: page 0 and 3 are fixed, wont be swapped out, and the 
; segments loaded there wont be mapped in page 1 or 2.
; We keep track of requested segments (max 16)
; page 1 and 2 get a "fresh requested segment"
; The includes work under MSX-DOS1 and MSX-DOS2.

    .section .text

    call MemPrepare

    ; exta tests for now
    ld BC, 0x0202                  ; index 2 in page 2
    call MEMSET
    ld BC, 0x0301                  ; index 3 in page 1
    call MEMSET                    ; 64 kb

    ld BC, 0x0402                  ; index 4 in page 2
    call MEMSET
    ld BC, 0x0501                  ; index 5 in page 1
    call MEMSET                    ; 96 kb (MAX MSX-DOS 1 without extentions)

    ld BC, 0x0001                  ; index 0 in page 1
    call MEMRESET

backtodos:
    LD C, 0x00                     ; Exit do MSX-DOS
    CALL BDOS
    ret
