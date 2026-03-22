; Configuration that can be used by the Arkos Tracker 3 players.

; It indicates what parts of code are useful to the song/sound effects, to save both memory and CPU.
; The players may or may not take advantage of these flags, it is up to them.

; You can either:
; - Ignore this file. The player will use its default build (no optimizations).
; - Include this to the source that also includes the player (BEFORE the player is included) (recommended solution).
; - Include or copy/paste this at the beginning of the player code (not recommended, the player should not be modified).

; This file was generated for a specific song. Do NOT use it for any other.
; Do NOT try to modify these flags, this can lead to a crash!

; If you use one player but several songs, don't worry, these declarations will stack up.
; Just make sure to include them, in any order, BEFORE the player.
PLY_AKG_HARDWARE_MSX equ 1
PLY_CFG_ConfigurationIsPresent equ 1

; DKW
PLY_CFG_UseEffects equ 1
PLY_CFG_UseSpeedTracks equ 1
PLY_CFG_NoSoftNoHard equ 1
PLY_CFG_NoSoftNoHard_Noise equ 1
PLY_CFG_SoftOnly equ 1
PLY_CFG_UseEffect_SetVolume equ 1

; AG
;PLY_CFG_UseEffects equ 1
;PLY_CFG_NoSoftNoHard equ 1
;PLY_CFG_SoftOnly equ 1
;PLY_CFG_UseEffect_SetVolume equ 1

; PLY_CFG_UseHardwareSounds equ 1
; PLY_CFG_SoftOnly_ForcedSoftwarePeriod equ 1
; PLY_CFG_SoftOnly_SoftwarePitch equ 1
; PLY_CFG_SoftOnly_SoftwareArpeggio equ 1
; PLY_CFG_SoftToHard equ 1
    