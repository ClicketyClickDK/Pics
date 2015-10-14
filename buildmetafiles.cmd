@ECHO OFF
    SET MetaTag=
    SETLOCAL 

    SET PATH=%PATH%;C:\_\;
    IF EXIST original CD original
    SET _AlbumIndex=album_list.xml
    SET ImageMagickConvert=%ProgramFiles%\ImageMagick-6.9.2-Q16\convert.exe
    
    (
        ECHO:^<?xml version="1.0" encoding="ISO-8859-1"?^>
        rem ECHO:^<^!-- Build by C:\pictures\Gallery\dev\\_build_album.cmd --^>
        ECHO:^<CATALOG^>
    )>%_AlbumIndex%
    SETLOCAL ENABLEDELAYEDEXPANSION
    
    FOR %%i IN (*.jpg) DO CALL :process_pic %%i
    ::FOR %%i IN (*.thm) DO CALL :process_pic %%i
    ECHO:
    ECHO Testing videos
    FOR %%i IN (*.thm) DO CALL :check_video %%i

    (
        ECHO:^</CATALOG^>
    )>>%_AlbumIndex%

    CD ..
    ECHO document.getElementById('meta_status').innerHTML="";>BuildMetaFiles.js

    ping localhost >nul
    IF ERRORLEVEL 1 pause
    ENDLOCAL
GOTO :EOF

:Check_video
    SET _thumb_file=%1
    ECHO:

    SET VideoFile=%_Picture_file:~0,-4%.avi
    
    IF NOT EXIST %VideoFile% (
        ECHO - Missing video: [%VideoFile%]
        SET ERRORLEVEL=1
    )
GOTO :EOF

:process_pic
    SET _Picture_file=%1
    SET JSGROUP=
    SET _META_OLD=
    ECHO:
    ECHO %_Picture_file%

    SET MetaTextFile=%_Picture_file:~0,-4%.txt
    SET MetaJavaFile=%_Picture_file:~0,-4%.js
    SET MetaXmlFile=%_Picture_file:~0,-4%.xml

    for %%i in ( %MetaJavaFile% %MetaTextFile%) DO IF EXIST %%i (
        ECHO Deleting %%i
        DEL %%i
    )
    >&2 ECHO - Dumping meta
    :: -L          (-latin)             Use Windows Latin1 encoding
    :: -G[NUM...]  (-groupNames)        Print group name for each tag
    :: -c FMT      (-coordFormat)       Set format for GPS coordinates
    ::    exiftool -L -all -c "%%.6f" -G %_Picture_file%  | sort> %MetaTextFile% 
    ::exiftool -all -c "%%.6f" -G %_Picture_file%  | sort> %MetaTextFile% 
    exiftool -X -c "%%.6f" %_Picture_file%  > %MetaXmlFile% 

    >&2 ECHO - Updating %_AlbumIndex%
    (
        ECHO:    ^<PICTURE^>
        ECHO:        ^<FILE^>%_Picture_file%^</FILE^>
        ECHO:        ^<FILEDATE^>%~t1^</FILEDATE^>
        ECHO:        ^<FILESIZE^>%~z1^</FILESIZE^>
        ECHO:    ^</PICTURE^>
    )>>%_AlbumIndex%

    >&2 ECHO - Extract thumb

    exiftool -b -ThumbnailImage %_Picture_file%  > %_Picture_file%.thm
     
GOTO :EOF

    >&2 ECHO - Parsing meta
    FOR /F "delims=* tokens=*" %%i IN ('TYPE %MetaTextFile%') DO (
        SET  /P _=.<nul
        SET _META=%%i
        SET _META=!_Meta:^&=+!
        SET _META=!_Meta:^'=`!
        SET _META=!_Meta:^"=`!
        CALL :Parse_meta "!_META!"
    )
    ECHO:>>%MetaJavaFile%
    ECHO };>>%MetaJavaFile%
    SET _META_OLD=
    ECHO if ( document.getElementById('meta_status') ) document.getElementById('meta_status').innerHTML="";>>%MetaJavaFile%
GOTO:EOF

::----------

:Parse_Meta
    SET MetaGroup=%_META:~0,16%
    SET MetaTag=%_META:~16,32%
    SET MetaValue=%_META:~50%

    for /l %%a in (1,1,16) do if "!MetaGroup:~-1!"==" " (
        set MetaGroup=!MetaGroup:~0,-1!
    )
    for /l %%a in (1,1,28) do if "!MetaTag:~-1!"==" " (
        set MetaTag=!MetaTag:~0,-1!
    )

    SET MetaTag=%MetaTag: =_%
    SET MetaGroup=%MetaGroup: =_%
    SET MetaGroup=%MetaGroup:[=%
    SET MetaGroup=%MetaGroup:]=%

    IF NOT "%JsGroup%" == "%MetaGroup%" (
        IF NOT "%JsGroup%!" == "!" (
            ECHO: >>%MetaJavaFile%
            ECHO };>>%MetaJavaFile%
            ECHO: >>%MetaJavaFile%
            SET _META_OLD=
        )
        ECHO var %MetaGroup% = { >>%MetaJavaFile%
        SET JsGroup=%MetaGroup%
    )

::    ECHO '%MetaTag: =_%':'%METAvalue%'>>%MetaJavaFile%
    IF DEFINED _META_OLD ECHO ,>>%MetaJavaFile%
    SET /P _=   '%MetaTag: =_%':'%METAvalue%'<nul >>%MetaJavaFile%
    SET _META_OLD=%_META%
GOTO :EOF

