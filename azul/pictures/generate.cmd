@echo off
cd D:\MSX\code\pctools\png2msxSc5\bin\Debug\net9.0

png2msxSc5.exe D:\MSX\code\azul\pictures\tiles.png -cmap D:\MSX\code\azul\pictures\azul.color
png2msxSc5.exe D:\MSX\code\azul\pictures\board-leeg.png -cmap D:\MSX\code\azul\pictures\azul.color
png2msxSc5.exe D:\MSX\code\azul\pictures\board-leeg-grijs.png -cmap D:\MSX\code\azul\pictures\azul.color
png2msxSc5.exe D:\MSX\code\azul\pictures\fabriek.png -cmap D:\MSX\code\azul\pictures\azul.color

cd D:\MSX\code\pctools\RLEEncode\bin\Debug\net9.0

RLEEncode.exe D:\MSX\code\azul\pictures\tiles.bi5
RLEEncode.exe D:\MSX\code\azul\pictures\board-leeg.bi5
RLEEncode.exe D:\MSX\code\azul\pictures\board-leeg-grijs.bi5
RLEEncode.exe D:\MSX\code\azul\pictures\fabriek.bi5


cd D:\MSX\code\azul\pictures
del *.rl5

ren tiles.rl8 tiles.rl5
ren board-leeg.rl8 bord1.rl5
ren board-leeg-grijs.rl8 bord2.rl5
ren fabriek.rl8 fabriek.rl5

copy /Y tiles.rl5 D:\MSX\DIRASDISK
copy /Y bord1.rl5 D:\MSX\DIRASDISK
copy /Y bord2.rl5 D:\MSX\DIRASDISK
copy /Y fabriek.rl5 D:\MSX\DIRASDISK


