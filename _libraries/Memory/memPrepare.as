;; ==[ MemPrepare ]===============================================
;; Sets up the memory (basic, msx-dos1, msx-dos2)
;; fresh page 1 and 2
;; msx-basic swapped out
    .pushsection .text

    call DOSVersion
    cp 2
    jr z, memPrepareDone
    
    call MemMapCheck               ; find the mempry mapper and check it
    call MemSwapPage1              ; page 1 and 2 have fresh RAM now.
                        ; page 0 still has the bios, and page 3 is unchanged.
    
memPrepareDone:                    ; MSX-DOS2 has above setup already for page 1 and 2.
    ld BC, 0x0002                  ; index 0 in page 2
    call MEMSET
    ld BC, 0x0101                  ; index 1 in page 1
    call MEMSET

;; default header for the Memory library with MSX-DOS.

    .section .data

MSXDOSVER:
    .byte 0x00                     ; 1  [012] MSX-DOS version (0,1,2)                               DOSVersion.asc
MEMNRBANKS:
    .byte 0x00                     ; 1  [01-] total nr of memory-mapped segments available.	     memMapCheck.asc
MEMPAGE0:
    .byte 0x00                     ; 1  [01-] Loaded segment in page 0			                     memMapCheck.asc
MEMPAGE3:
    .byte 0x00                     ; 1  [01-] Loaded segment in page 3			                     memMapCheck.asc
MEMMAPTBL:
    .byte 0x00, 0x00               ; 2  [--2] address of MAPTBL                                     DOSVersion.asc
MEMSET:
    .byte 0xC3, 0x00, 0x00         ; 3  [012] jump to right set-page function   (new page)             DOSVersion.asc
MEMRESET:
    .byte 0xC3, 0x00, 0x00         ; 3  [012] jump to right reset-page function (old page)           DOSVersion.asc
MEMSEGMENTS:
    .byte 0xFF, 0xFF, 0xFF, 0xFF   ; 16 [012] Array of segment requested			             memLoadSegment.asc
    .byte 0xFF, 0xFF, 0xFF, 0xFF
    .byte 0xFF, 0xFF, 0xFF, 0xFF
    .byte 0xFF, 0xFF, 0xFF, 0xFF

    .popsection
