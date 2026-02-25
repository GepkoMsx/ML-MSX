;; ==[ MemPrepare ]===============================================
;; Sets up the memory (basic, msx-dos1, msx-dos2)
;; fresh page 1 and 2
;; msx-basic swapped out

    call DOSVersion
    cp 2
    jr z, memPrepareDone

    call MemMapCheck    ; find the mempry mapper and check it
    call MemSwapPage1   ; page 1 and 2 have fresh RAM now.
                        ; page 0 still has the bios, and page 3 is unchanged.

memPrepareDone:         ; MSX-DOS2 has above setup already for page 1 and 2.
    ld BC, $0002        ; index 0 in page 2
    call MEMSET     
    ld BC, $0101        ; index 1 in page 1
    call MEMSET
