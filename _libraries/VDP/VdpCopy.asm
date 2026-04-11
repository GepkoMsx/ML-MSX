    

; The 15-byte structure (becomming 10 or 14)
;
; SX, SY (4 bytes): Source coords       ; those not present for  HMMV, LMMV, HMMC, LMMC
; DX, DY (4 bytes): Dest coords
; NX, NY (4 bytes): Width and Height
; CLR (1 byte): Color
; ARG (1 byte): Arguments
; CMD (1 byte): The command             ; never present (macro sends it)
;
; so HMMV, LMMV, HMMC, LMMC: 10 bytes, others 14 bytes


; cmd is one of the VDP_* commands from constants.asc
; ptrData is the address of the copy-block of data.
; bytesColor is nr of bytes to send as color-data.
; ptrCOlor is the address of the color-data block.
    .macro VdpCopy cmd ptrCmdData bytesColor ptrColor ; ptrCmdData can be HL, ptrColor can be DE, or constants. Last 2 params only for HMMC/LMMC'
    .nolist
    .set nrbytes, 14
    .ifc \cmd, VDP_HMMV
        .set nrbytes, 10
    .endif
    .ifc \cmd, VDP_LMMV
        .set nrbytes, 10
    .endif
    .ifc \cmd, VDP_HMMC
        .set nrbytes, 10
    .endif
    .ifc \cmd, VDP_LMMC
        .set nrbytes, 10
    .endif

    .set startreg, 32
    .if nrbytes == 10
        .set startreg, 36
    .endif
    .list
    
    .ifnc \ptrCmdData, HL
    .ifnc \ptrCmdData, hl
        ld HL, \ptrCmdData
    .endif
    .endif

    in a, (VDPC)                   ; even status check om vdp te schonen

    setVDP 17, startreg            ; auto-increment (geen $80) vanaf register 32/36 naar R17
    
    ld b, nrbytes
    ld c, VDPR
    otir                           ; - out (c), (hl) - inc hl - dec b, and repreat until b=0
    ld A, \cmd                     ; send the command.
    out (c), a

    .ifnb \bytesColor              ; we got colordata aswell, so send it (for HMMC and LMMC)
      setVDP 17, 44                ; geen increment ($80) naar register 44
      ld HL, \ptrColor
      ld DE, \bytesColor           ; remove 1, has been sent in cmd
      dec de

.PixelLoop\@:
      ld a, (HL)
      out (c), a                   ; VDP zet deze pixel op de volgende positie
      inc HL
      dec de
      ld a, d
      or e
      jp nz, .PixelLoop\@
    .endif

    .endm