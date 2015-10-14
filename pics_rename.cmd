@ECHO OFF
SETLOCAL
::**********************************************************************
SET NAME=pics
SET DESCRIPTION=Copying pictures from card to PC
SET AUTHOR=Erik Bachmann [E_Bachmann@hotmail.com] www.ClicktyClick.dk
SET SOURCE=%~dpnx0
SET STUB=%~dp0
::**********************************************************************
::SET VERSION=01.000&SET REVISION=2009-07-01T10:23
::SET VERSION=01.010&SET REVISION=2009-07-04T20:56&SET COMMENT=Testing drive ready
::SET VERSION=01.020&SET REVISION=2009-07-05T16:19&SET COMMENT=Count of each file type
::SET VERSION=01.025&SET REVISION=2009-07-06T08:12&SET COMMENT=Set picture roor directory
::SET VERSION=01.030&SET REVISION=2010-06-27T19:57&SET COMMENT=SetIsoDate
::SET VERSION=01.100&SET REVISION=2010-07-06T19:52&SET COMMENT=Autoplay plus dynamic path (%1) and drive (%2)
::SET VERSION=01.200&SET REVISION=2010-07-10T17:04&SET COMMENT=Files are counted before copying
::SET VERSION=01.210&SET REVISION=2012-07-12T14:15&SET COMMENT=SetEuroDate  bugfixed
  SET VERSION=01.220&SET REVISION=2012-10-21T10:32&SET COMMENT=CD /D Root fixed
::**********************************************************************
::SEE http://windowsxp.mvps.org/addautoplay.htm
:: Use TweekUI : MyComputer/AutoPlay/Handlers
:: Installs in:
::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\AutoplayHandlers\Handlers\TweakUIAutoplay_109771953
:: Match arguments in:
:: HKEY_CLASSES_ROOT\TweakUIAutoplay\shell\TweakUIAutoplay_109771953\command

ECHO %NAME% v. %VERSION% -- %DESCRIPTION%
ECHO Rev. %Revision%
ECHO By %Author%
    ECHO:
    CALL :Init %*
::    ECHO Counting files
::    CALL :Count_files
::    CALL :Show_filecount
    CALL :main
    :: CALL :TEST
    PAUSE
GOTO :EOF
::----------------------------------------------------------------------

:init
    SET _ROOT=%STUB%
    IF NOT "!"=="!%~1" SET _ROOT=%~1
::    CD /D "%_Root%"
    SET _ERRORS=0
    SET _FILES=0
    SET _Total_FILES=0
    SET _Total_files_=0
    SET STANDARD_EXTENTIONS=jpg 
    SET RAW_EXTENTIONS=dng
    SET MOVIE_EXTENTIONS=avi mov thm
    SET _SD-DRIVE=E:

    IF NOT "!"=="%2!" SET _SD-DRIVE=%~2
    ::IF NOT EXIST %_SD-DRIVE%\. GOTO Drive-not-ready
    CALL :SET_SD

    :: Set homedir
    IF NOT "!"=="%1!" CD /D %1
    ECHO Working directory: [%CD%]
    ECHO Arguments: [%*]
GOTO :EOF   *** :init ***
::----------------------------------------------------------------------

:main
    ECHO Standards
    FOR %%j IN (%STANDARD_EXTENTIONS% %RAW_EXTENTIONS%) DO (
    DIR /B *.%%j
        FOR /F %%i IN ('DIR /B *.%%j 2^>NUL') DO (
            ECHO - %%~ni
            CALL :Copy_pic %%~nxi %%~ti %%~dpi .\ %%j
        )
    )
    ECHO:
GOTO :EOF   *** :main ****

::----------------------------------------------------------------------

:Drive-not-ready
    ECHO Sorry! [%_SD-DRIVE%] is not ready...
    PAUSE
GOTO :EOF   *** :Drive-not-ready ***

::----------------------------------------------------------------------

:SetIsoDate
    SET _dato=%_dato:_=T%-00
    SET _dato=%_dato::=-%
    SET _dato=%_dato::=-%
GOTO :EOF   *** :SetIsoDate ***

::----------------------------------------------------------------------

:SetEuroDate
    SET _dato=%_dato:~6,4%-%_dato:~3,2%-%_dato:~0,2%T%_dato:~11,2%-%_dato:~14,2%-00
GOTO :EOF   *** :SetEuroDate ***

::----------------------------------------------------------------------

:copy_pic
    SET _dato=%2_%3
    SET _FILE=%1
    SET _FILETYPE=_Files_

    IF "-"=="%_dato:~4,1%" (
        CALL :SetIsoDate
    ) ELSE IF "-20"=="%_dato:~5,3%" (
        CALL :SetEuroDate
    )
    
    IF NOT EXIST %5%_dato:~0,10%%6\nul (
        ECHO:
        ECHO - Create "%5%_dato:~0,10%%6\"
        MKDIR "%5%_dato:~0,10%%6\"
        SET /p _=+<nul
    )

    IF NOT EXIST %5%_dato:~0,10%%6\%_dato%_%1 (
        ::COPY %4%1 %5%_dato:~0,10%\%_dato%_%1 >>%_root%.error.txt 2>&1
        MOVE %4%1 %5%_dato:~0,10%%6\%_dato%_%1 >>%_root%.error.txt 2>&1
        IF ERRORLEVEL 1 ECHO FEJL & SET /A _ERRORS=%_ERRORS% + 1 & pause
        ::CALL SET /A _FILES_%_FILE:~-3%=%_FILES_%_FILE:~-3%% + 1
        CALL SET /A _FILEs=%_FILES% + 1
        CALL :add_one _FILES_%_FILE:~-3%
        SET /p _=o<nul
    ) ELSE (
        SET /p _=.<nul
    )
GOTO :EOF   *** :copy_pic ***

::----------------------------------------------------------------------

:stamping
    SET FIle=%~1
    SET stamp=%2 %3
    MOVE %file% %stamp:~6,4%-%stamp:~3,2%-%stamp:~0,2%T%stamp:~11,2%-%stamp:~14,2%-00_%file%
GOTO :EOF   *** :stamping ***

::----------------------------------------------------------------------

:init_var
    CALL SET /a %1=0
GOTO :EOF   *** :init_var ***

::----------------------------------------------------------------------

:Add_one
    CALL SET /a %1=%%%1%% + 1
    CALL SET /A _Total_files_=%_Total_files_% + 1
GOTO :EOF   *** :Add_one ***

::----------------------------------------------------------------------

:show
   SET _=%~1          !
   SET __=          %~2
   ECHO   %_:~2,10%: %__:~-10%
GOTO :EOF   *** :show ***

::----------------------------------------------------------------------

:Count_files
    FOR %%j in (%STANDARD_EXTENTIONS% %RAW_EXTENTIONS% %MOVIE_EXTENTIONS% ) DO (
        CALL :init_var $$%%j

        FOR /F %%i IN ('dir /B /S %_SD-DRIVE%\*.%%j 2^>NUL') DO (
            CALL :add_one $$%%j
        )
    )
GOTO :EOF   *** :Count_files ***

::----------------------------------------------------------------------

:Show_filecount
    FOR /F "delims== tokens=1,2*" %%j IN ('set $$') DO (
        ECHO [%%j]=[%%k]>NUL
        CALL :SHOW %%j %%k
    )
    CALL :SHOW "  Total" %_Total_files_%
GOTO :EOF   *** :Show_filecount ***

::----------------------------------------------------------------------

:set_sd
    FOR %%a IN ( E F G H ) DO (
        ECHO - Checking %%a:\DCIM
        IF EXIST %%a:\DCIM CALL SET _SD-DRIVE=%%a:
    )
    ECHO [%_SD-DRIVE%]
GOTO :EOF   *** :set_sd ***

::*** End of File ******************************************************