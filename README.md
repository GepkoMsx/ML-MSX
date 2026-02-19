# ML-MSX
Assembly programming for the MSX2

## Goal
Make software for the MSX2 that works on any MSX2 with a diskdrive (MSX-DOS1), but also on MSX2 with expansions like SD cards, Harddrives etc. (MSX-DOS2). 
The final product(s) will be a DSK file with the program, game, etc. Setting up a library of common functions of code snippets, so software can be built faster. 

The product should be fully functional on standard hardware, meaning:
- It all fits on one 360kb floppy disk.
- Works on real hardware without midifcations
- Works with expansions, especially storage solutions (sd card, msx-dos2, nextor drives)

## Setup
To build software we need tools. All the work is done on a modern windows 11 PC.  
Software tools used:
- [openMSX v21](https://github.com/openMSX/openMSX): MSX Emulator for the pc.
- [vscode](https://code.visualstudio.com/download): Visual studio code editor/IDE
- [Vasm 1.9a](http://sun.hasenbraten.de/vasm/): A Z80 assembler to assemble to the code.
- [Disk-Manager 0.17](https://www.lexlechz.at/en/software/DiskMgr.html): A tool to write DKS files to floppy disks.
- [Corel PaintSHop Pro](https://www.paintshoppro.com/en/products/paintshop-pro/standard/): Editing pictuers.
- Home-made tools in [visualstudio](https://visualstudio.microsoft.com/), in c#.
  - Symbol file reducer: removes extra comments etc from the symbol file, to make it more compact.
  - Png2sc8: Converts a png image to a screen8-bytestream.
  - Png2sc5: Converts a png image to a screen5-bytestream.
  - RLE encode: Encodes a binary file with a form of RLE comression. 
  
Information used:
