(ctrl+shift +v)
# Datastructures used in AZUL

## COLORMAP 
_in azul/data/colormap.asc_  
16 bytes, 2 bytes per color in format  0xRB 0x-G  

## FontData
_in azul/data/font.asc_
Array of bytes, 12 bytes per letter/character. 

| name        | value | description           |
| ----------- | ----- | --------------------- |
| LOCHAR      | 32    | First ascii character |
| HICHAR      | 127   | Last ascii character  |
| FONT_HEIGHT | 12    | hight in pixels       |

## SELECTORMOVEMENT
_in azul/data/selectorMovement.asc_  
Shows the destination if you got in a direction form a starting selector location.
First the 5 factories, same order as in factoryPositions. Each factory has 4 tiles (rows).
Then 5 tiles-on-table, for every type 1 (numbered 14-18).
Every position has 4 bytes pointing (left, right, up, down) not possible movements are 0xFF.  

layout:  
```
      00  01  
      02  03  
  
 04 05  14  08 09  
 06 07  15  0A 0B  
        16  
 0C 0D  17  10 11  
 0E 0F  18  12 13  
```

## SpritePatterns
_in azul/data/SpriteData.asc_  
The spritepatterns, we got large sprits 16x16 (32 bytes per sprite). We use 2 sprite sper tile.
Firstlplayer tile has 3 sprites.  Selector has 1 sprite.  
Order: Blue, Yellow, Red, Black, White, 1stPlayer, Selector.

## SpriteColors
_in azul/data/SpriteData.asc_  
14 bytes of colors for the sprites. (1 byte per sprite)

## FACTORYPOSITIONS
_in azul/data/tilePostions.asc_
Screeen coordinates for the tile-locations. Factories go clockwise starting topleft.   
( 5 factories, 4 tiles per factory, so 5x4x2 = 40 bytes )

## TILESONTABLEPOSITIONS
_in azul/data/tilePostions.asc_  
Screeen coordinates for the tile-locations. (5x 2 = 10 bytes).

## TILESWALL1POSITIONS
_in azul/data/tilePostions.asc_  
Screeen coordinates for the tile-locations. (5x 2 = 10 bytes)
The wallpositions are the rigthmost tile positions per row for player 1. 
(maybe specify them all?)

## TILESWALL2POSITIONS
_in azul/data/tilePostions.asc_  
Screeen coordinates for the tile-locations. (5x 2 = 10 bytes)
The wallpositions are the rigthmost tile positions per row for player 2. 
(maybe specify them all?)

## TIMER
_in azul/azul.as_
For use in a gameloop (to blink etc)

## BELOW
_in azul/azul3Playfield.asc_
Y position (0xD5) where the tilemap starts on screen. (just below visible screen, bottom of page 0).

## TILESX, NUMBERSX
_in azul/azul5StartGame.asc_  
X positions where the tiles are in the tilemap.  (just below visible screen, bottom of page 0).  
TilesX for the tiles, NUMBERSX for the score-numbers.  

## TILESINFACTORY
_in azul/azul5StartGame.asc_  
Tiletype per factoryspot. 4 spots, 5 factories, 20 bytes.

## TILESONTABLE
_in azul/azul5StartGame.asc_  
Count of tiletypes on table (1 byte per type, 5.)

## FIRSTPLAYERONTABLE
_in azul/azul5StartGame.asc_  
is 1stplayer still on table? (1 byte)

## TILESINBAG
*in _libaraies/azul/BagTakeATile.asc*  
Game starts with 20 blue, 20 yellow, 20 red, 20 black, 20 white tiles.
(5 bytes)

## SCORE
*in _libaraies/azul/BagTakeATile.asc*
Score of player 1 and 2 (2 bytes)
