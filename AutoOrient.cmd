@ECHO OFF
SETLOCAL ENABLEDELAYEDEXPANSION&::(Don't pollute the global environment with the following)
SET $NAME=%~n0
SET $DESCRIPTION=Auto orient pictures using the EXIF orient
SET $Author=Erik Bachmann, ClicketyClick.dk (ErikBachmann@ClicketyClick.dk)
SET $Source=%~dpnx0
::----------------------------------------------------------------------
::@(#) NAME
::@(#)  %$NAME% -- %$DESCRIPTION%
::@(#) 
::@(#) SYNOPSIS
::@(#)      %$NAME%
::@(#) 
::@(#) 
::@(#) 
::@(#)ARGUMENTS
::@(#) 
::@(#) DESCRIPTION
::@(#)      
::@(#)      
::@(#)      
::@(#)      
::@(#)EXAMPLE
::@(#)      Call %$NAME% 
::@(#)      
::@(#)      
::@(#)EXIT STATUS
::@(#)  Exit status is 0 if any matches were found, otherwise 1.
::@(#) 
::@(#)REQUIRES
::@(#)  exiftool.exe    Read and write meta information in files
::@(#)                  http://www.sno.phy.queensu.ca/~phil/exiftool/
::@(#)  convert.exe     ImageMagick convert tool
::@(#)                  http://www.imagemagick.org
::@(#) 
::@(#)LIMITATIONS
::@(#) 
::@(#)SEE ALSO
::@(#)
::@(#)SOURCE
::@(#)  %$Source%
::@(#) 
::----------------------------------------------------------------------
::History
::SET $VERSION=xx.xxx&SET $REVISION=YYYY-MM-DDThh:mm:ss&SET $Comment=Init Description/Initials
::SET $VERSION=2015-08-09&SET $REVISION=11:00:00&SET $Comment=Initial/EBP
::SET $VERSION=2015-08-09&SET $REVISION=11:00:00&SET $Comment=Initial/EBP
  SET $VERSION=2015-10-11&SET $REVISION=11:00:00&SET $Comment=Initial/EBP
::**********************************************************************
::@(#)(C)%$Revision:~0,4% %$Author%
::**********************************************************************


:Init
    ECHO:%$NAME% v.%$VERSION%T%$REVISION%
    ECHO:- %$DESCRIPTION%
    ECHO:- by %$Author%
    ECHO:

    SET PATH=C:\_;%PATH%
    SET ExifTool=%~dp0\exiftool\exiftool.exe
    SET ImageMagickConvert=%~dp0\imagemagick\imgconvert.exe
    SET _LOG=%~dpn0.log.txt
    SET _count.ok=0
    SET _count.cw=0    
    SET _count.ccw=0
    SET _count.ignore=0
    SET _Count.total=0
    SET _count.processed=0
    FOR /F %%a IN ('FORFILES /M "*.jpg"') DO SET /A _Count.total+=1
    (
        ECHO:%$NAME% v.%$VERSION%T%$REVISION%
        ECHO:Start %Date% %Time%
        ECHO:
        ECHO:Total no of files: %_Count.total%
    )>%_log%
    
:Process
    :: BUG: takes _org files in too
    ::    FOR %%a IN ("*.jpg") DO CALL :GetRotation %%a
    FOR /F %%a IN ('FORFILES /M "*.jpg"') DO CALL :GetRotation %%a
:Finalize
    ECHO:
    SET _Count.
    SET _Count.>>%_log%
    ECHO:End: %Date% %Time%>>%_log%
    ECHO *** Done ***
GOTO :EOF

::----------------------------------------------------------------------

:GetRotation    :: Find all Jpg to test
    FOR /F "Delims=: tokens=2" %%b IN ('%ExifTool% -Orientation -n "%~1"') DO CALL :derotate "%~1" %%b
GOTO :EOF

::----------------------------------------------------------------------

:log    :: Write log entries
    TITLE "%~1" [%~2] - %~3
    ECHO:%~4 "%~1" [%~2] - %~3
    ECHO:%~4 "%~1" [%~2] - %~3>>%_log%
GOTO :EOF

::----------------------------------------------------------------------

:derotate filename orientation :: Auto-orient if requiered
    SET _FILE=%~1
    SET /A _count.processed+=1
    IF /I "_org"=="%_FILE:~-4%" TITLE "%~1" [%~2] - Ignore&ECHO:"%~1" [%~2] - Ignore>>%_log%&SET /A _count.ignore+=1&GOTO :EOF

    IF "1"=="%~2" ( REM Normal
        CALL :log "%~1" "%~2" "%_count.processed%/%_Count.total%: Skip" "-"
        SET /A _count.ok+=1
    ) ELSE IF "6"=="%~2" (
        CALL :log "%~1" "%~2" "%_count.processed%/%_Count.total%: Rotate 90 CW" "+"

        RENAME "%~1" "%~1_org"
        "%ImageMagickConvert%" -auto-orient "%~1_org"  "%~1"

        SET /A _count.cw+=1
    ) ELSE IF "8"=="%~2" (
        CALL :log "%~1" "%~2" "%_count.processed%/%_Count.total%: Rotate 90 CCW" "+"
        
        RENAME "%~1" "%~1_org"
        "%ImageMagickConvert%" -auto-orient "%~1_org"  "%~1"

        SET /A _count.ccw+=1
    )

::*** End of File *****************************************************