@echo off
echo Complile %1
echo.
setlocal enabledelayedexpansion
for /F "delims=#" %%E in ('"prompt #$E# & for %%E in (1) do rem"') do set "ESC=%%E"

REM read the include folders from the file and build the INC variable
cd D:\MSX\code\vasm
set INC=
for /f "usebackq delims=" %%a in ("IncludeFolders.txt") do (
    set INC=!INC! -I"%%a"
)

echo The generated Includes:
echo %INC%
echo.

REM Generate the macro include file
del D:\MSX\code\_libraries\Macros.asc
set "TAB=	"
for /f "delims=" %%i in ('dir D:\MSX\code\_libraries\*.asm /s /b') do (
    echo %TAB%.include "%%~nxi" >> "D:\MSX\code\_libraries\Macros.asc"
)


REM RUN XREF generator
D:\MSX\code\vasm\BuildTools\XRefGenerator\bin\Release\net9.0\XRefGenerator.exe %2\%1 d:\msx\code\vasm

REM BUILD
cd d:\msx\code\vasm\bin
REM vasmz80_std.exe %2\%1.as -nocase -chklabels -Fbin -L %2\%1.sym -o %2\%1.bin %INC%
vasmz80_std.exe %2\%1 -Fvobj -nocase -chklabels -L %2\%~n1.sym -o %2\%~n1.o %INC%

if %errorlevel% neq 0 (
    echo %ESC%[31mFout vasm!%ESC%[0m
    exit /b 1
) 

REM beautify the .sym file
cd D:\MSX\code\vasm\BuildTools\SymParser\bin\Release\net9.0
SymParser.exe %2\%~n1.sym > nul
if %errorlevel% neq 0 (
    echo %ESC%[31mFout SymParser!%ESC%[0m
    exit /b 2
) 

if /I "%~x1" == ".as" (
    REM save last build to the symbols folder, to load in openMSX
    copy /Y %2\%~n1.sym D:\MSX\code\vasm\symbols.sym > nul
    if %errorlevel% neq 0 (
        echo %ESC%[31mFout copy!%ESC%[0m
        exit /b 3
    ) 

    REM LINK  (file, folder, startaddress)
    echo Running vlink.exe
    cd d:\msx\code\vasm
    call link.cmd

    REM Copy to DIRASDISK folder 
    move /Y d:\msx\code\vasm\%~n1.bin d:\msx\dirasdisk\%~n1.com
)
REM done
cd d:\msx\code\vasm
