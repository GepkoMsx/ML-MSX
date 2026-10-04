;; MACRO TileFirstPlayer
;; yes / no

    .macro TileFirstPlayer show

    .set show\@, 5
    .ifc \show, "no"
        .set show\@, 8
    .endif

    call Waitvdp                   ; show 1st player tile
    ld HL, TILESONTABLEPOSITIONS+10
    ld d, (HL)
    inc HL
    ld E, (HL)
    ld c, show\@
    call TileShow                  ; show tile graphic  C = type, DE = location

       .endm