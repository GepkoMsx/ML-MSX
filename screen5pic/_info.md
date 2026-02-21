(ctrl+shift+v)

### Png2msxSc5.exe works, screen5pic needs changed to match.

# Screen 5 pictures
To work with fast loading from RAM to the screen we use the VDP HMMC routine.  
Png2msxSc5.exe can generate binary files or assembly-includes in this format. 

## The format
Screen 5 data consists of 
- HMMC command header
- Pixel data, 4bits per pixel
- The colormap

These sections are combined in 1 byte-stream in order.

### HMMC header
The HMMC command consists of 11 bytes, and thus the header aswell:
- 4 bytes Begin position, usually overwritten by the program (DX, DY)
- 2 bytes Image width in pixels  (always even nr of pixels!)
- 2 bytes Image height in pixels
- 1 byte  1st 2 pixels. (Will be overwiritten by pixeldata)
- 1 byte  The ARG component, usually $00
- 1 byte  The HMMC command, always $F0

### Pixel data
The pixel data is a color index number per pixel of 4 bits (0-15). 
The image size is max 256x212 pixels. 

### Color map
The color map consists of 16 color definitions, each 2 byes:
- 1st byte: 0rrr 0bbb
- 2nd byte: 0000 0ggg

### Example
| bytes                            | Description                                            |
|----------------------------------|--------------------------------------------------------|
| 00 00 00 00 24 00 24 00 00 00 F0 | _HMMC header for a 36x36 picture_                      |
| 00 01 00 02 00 03 00 04 00 05    | _colordata 648 bytes_                                  |
| .. .. 05 07 05 08 05 09 05 10    |                                                        |
| 70 00 07 00 00 07 00 00 77 07    | _Red, blue, green, black, white_                       |
| 77 00 70 07 07 07 71 04 55 05    | _magenta, yellow, cyan, orange, gray_                  |
| 33 03 50 02 04 07 27 03 03 00    | _dark gray, brown, ligth green, light blue, dark red_  |
| 73 07                            | _pale yellow_                                          |
