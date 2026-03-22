# MSX Assembly plugin
This extension adds support for MSX Z80 Assembly to Visual Studio Code.

## Features

Symbols for BIOS entry & WORK AREA are supported.  
drag-drop files add include/call statements.   
basic formatting while you type.

## Release Notes

plugin to add includes into your main program
works on ".asc", ".asm" and ".as" files

generates for .as and .asm files:

     ; comment line
     include "<relpath/FileName.ext>"

generates for .asc files:

     CALL FileName       ; comment line

generates for .inc files:

     a copy of the inc file inline. 

relpath is omitted for files and folders in "_libraries"  folder.
comment lines are copied from the file based on the LABEL. 
label matches filename (dosomething.asc -> Dosomething:)
