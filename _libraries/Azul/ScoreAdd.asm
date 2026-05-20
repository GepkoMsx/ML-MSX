;; MACRO ScoreAdd
;; player 1 = 0; payer 2 = 1

    .macro ScoreAdd player amount

    ld HL, SCORE+\player
    ld a, (HL)
    add a, \amount
    ld (HL), a

    .endm