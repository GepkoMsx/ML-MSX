;; MACRO ScoreReset

    .macro ScoreReset

    ld HL, SCORE                   ; Reset the score
    ld (HL), 0
    inc HL
    ld (HL), 0

    .endm
