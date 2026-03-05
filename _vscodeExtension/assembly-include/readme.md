plugin to add includes into your main program
works on ".asc" and ".as" files

generates for .as files:

     ; comment line
     include "<relpath/FileName.ext>"

generates for .asc files:

     CALL FileName       ; comment line

generates for .inc files:

     a copy of the inc file inline. 

relpath is omitted for files and folders in "_libraries"  folder.
comment lines are copied from the file based on the LABEL. 
label matches filename (dosomething.asc -> Dosomething:)

install by copy/past this folder to %USERPROFILE%\.vscode\extensions