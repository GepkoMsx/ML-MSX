(ctrl+shift +v)
# Memory pack
A set of libraries that work together to do memory management on MSX, for MSX-DOS1 and MSX-DOS2.
(The library foinds out what dos version) This pack can handle a max of 512Kb of memory mapped RAM.

## Contents
- _readme.md            
  This file with the manual.
- DOSVersion.asc    
  When msxdos2 found, call extended bios to get the memory mapper table and fills in the set and reset jumptable.
- memHeader.as    
  Headerfile that sets up the datablock needed to store variables.
- memMapCheck.asc    
  Checks the memorymapper on MSX-DOS1.
- memPack.inc    
  Include file bundle to include this pack.
- memPrepare.as    
  Prepares the variables and sets up default memory slots (like msx-dos2) and claims the 2 segments in page 1 and 2.
- memResetSeg1.asc    
  Loads a claimed segment on a page, for MSX-DOS1. B = index of segment, C = page (1 or 2)
- memResetSeg2.asc     
  Loads a claimed segment on a page, for MSX-DOS2. B = index of segment, C = page (1 or 2)
- memSetSeg1.asc    
  Loads a new segment on a page, for MSX-DOS1. B = index of segment, C = page (1 or 2)
- memSetseg2.asc    
  Loads a new segment on a page, for MSX-DOS1. B = index of segment, C = page (1 or 2)
- memSwapPage1.asc    
  Excahnges page1 from BASIC ROM to RAM.

## Program template
To use this pack, the "default" program file will look like:
```
; ==[ Constants ]===============================================

    include "Constants.as"

; ==[ Header ]==================================================
    org $0100

    include "memHeader.as"

; ==[ Program ]=================================================
    include "memPrepare.as"

... your program ...

; ==[ Libraries ]===============================================
    include "memPack.inc"

; ==[ Data ]====================================================
FileEnd:
```

## Usage
To first request a new segment, use the "MEMSET", to reload a previously requested segment use "MEMRESET"
load B with the index of the segment you want. (set a new index, reset an old index)
load C with the page where the segment needs to be loaded (only page 1 and 2 allowed)
The first 2 indexes are already claimed and loaded. 
- index 0 in page 2 
- index 1 in page 1
  
Example:
```
    ld BC, $0402              ; load a new segment in page 2, store it on index 4.
    call MEMSET     
```

```
    ld BC, $0102              ; load a claimed segment on index 1 in page 2
    call MEMRESET     
```
