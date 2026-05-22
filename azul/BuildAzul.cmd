@echo off
setlocal enabledelayedexpansion

:: Ga naar de juiste map
cd /d D:\MSX\code\vasm\bin

:: Standaard alles bouwen als er geen argumenten zijn meegegeven
if "%~1"=="" (
    set "RUN_LOADER=1"
    set "RUN_LIB=1"
    set "RUN_DATA=1"
    set "RUN_MAIN=1"
    goto :START_BUILD
)

:: Initialiseer variabelen op 0 (uit)
set "RUN_LOADER=0"
set "RUN_LIB=0"
set "RUN_DATA=0"
set "RUN_MAIN=0"

:: Controleer de meegegeven argumenten
:PARSE_ARGS
if "%~1"=="" goto :START_BUILD
if /i "%~1"=="/loader" set "RUN_LOADER=1"
if /i "%~1"=="/lib"    set "RUN_LIB=1"
if /i "%~1"=="/data"   set "RUN_DATA=1"
if /i "%~1"=="/main"   set "RUN_MAIN=1"
shift
goto :PARSE_ARGS

:START_BUILD

if "%RUN_LOADER%"=="0" goto :SKIP_LOADER
echo === Bouwen: LOADER ===
VasmBuilder.exe azulShow.as D:\MSX\code\azul > nul
VasmBuilder.exe loadAzul.as D:\MSX\code\azul > nul
:SKIP_LOADER

if "%RUN_LIB%"=="0" goto :SKIP_LIB
echo === Bouwen: LIBRARY ===
for %%F in (D:\MSX\code\_libraries\Azul\*.asc) do VasmBuilder.exe "%%~nxF" D:\MSX\code\_libraries\Azul > nul 
:SKIP_LIB

if "%RUN_DATA%"=="0" goto :SKIP_DATA
echo === Bouwen: DATA ===
for %%F in (D:\MSX\code\azul\data\*.asc) do VasmBuilder.exe "%%~nxF" D:\MSX\code\azul\data > nul 
:SKIP_DATA

if "%RUN_MAIN%"=="0" goto :SKIP_MAIN
echo === Bouwen: AZUL MAIN ===
for %%F in (D:\MSX\code\azul\*.asc) do VasmBuilder.exe "%%~nxF" D:\MSX\code\azul > nul 
VasmBuilder.exe azul.as D:\MSX\code\azul > nul 
:SKIP_MAIN

echo === Build voltooid ===
endlocal
