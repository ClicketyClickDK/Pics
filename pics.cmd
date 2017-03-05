@ECHO OFF
SETLOCAL

::**********************************************************************
SET NAME=pics
SET DESCRIPTION=Copying pictures from card to PC
SET AUTHOR=Erik Bachmann [ErikBachmann@ClicktyClick.dk] www.ClicktyClick.dk
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
::SET VERSION=01.220&SET REVISION=2012-10-21T10:32&SET COMMENT=CD /D Root fixed
::SET VERSION=01.230&SET REVISION=2014-08-07T12:42&SET COMMENT=Eject Card after copying
::SET VERSION=01.240&SET REVISION=2014-09-14T09:55&SET COMMENT=title and msg
::SET VERSION=01.250&SET REVISION=2014-12-21T10:02&SET COMMENT=ShowTime with leading digits
::SET VERSION=01.252&SET REVISION=2014-12-21T10:03&SET COMMENT=Target dir test2 to new
::SET VERSION=01.253&SET REVISION=2016-05-07T09:03&SET COMMENT=Enhanced list of raw images + Title bar
::SET VERSION=01.254&SET REVISION=2016-07-21T21:002:00&SET COMMENT=SD-DRIVE_RANGE added + checking drive type 2
::SET VERSION=01.255&SET REVISION=2017-03-04T10:14:00&SET COMMENT=WCIM commands as string vars
  SET VERSION=01.256&SET REVISION=2017-03-05T12:50:00&SET COMMENT=CD changed to PUSHD to support UNC paths
  
::
:: TO DO
:: Use temp files for testing and finding images to copy!
::
::**********************************************************************
::SEE http://windowsxp.mvps.org/addautoplay.htm
:: Use TweekUI : MyComputer/AutoPlay/Handlers
:: Installs in:
::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\AutoplayHandlers\Handlers\TweakUIAutoplay_109771953
:: Match arguments in:
:: HKEY_CLASSES_ROOT\TweakUIAutoplay\shell\TweakUIAutoplay_109771953\command
::
:: URL: https://en.wikipedia.org/wiki/Raw_image_format
:: Raw filename extensions and respective camera manufacturers
:: 
::     .3fr (Hasselblad)
::     .ari (ARRIFLEX)
::     .arw .srf .sr2 (Sony)
::     .bay (Casio)
::     .crw .cr2 (Canon)
::     .cap .iiq .eip (Phase_One)
::     .dcs .dcr .drf .k25 .kdc (Kodak)
::     .dng (Adobe)
::     .erf (Epson)
::     .fff (Imacon/Hasselblad raw)
::     .mef (Mamiya)
::     .mdc (Minolta, Agfa)
::     .mos (Leaf)
::     .mrw (Minolta, Konica Minolta)
::     .nef .nrw (Nikon)
::     .orf (Olympus)
::     .pef .ptx (Pentax)
::     .pxn (Logitech)
::     .R3D (RED Digital Cinema)
::     .raf (Fuji)
::     .raw .rw2 (Panasonic)
::     .raw .rwl .dng (Leica)
::     .rwz (Rawzor)
::     .srw (Samsung)
::     .x3f (Sigma)
:: 
:: Windows 10: To create a link from Start menu or Task bar make a link:
:: C:\Windows\System32\cmd.exe /C "\\gryde62\fotos\pics.cmd"
:: Select an icon from: %SystemRoot%\System32\imageres.dll
:: 
::*********************************************************************
ECHO %NAME% v. %VERSION% -- %DESCRIPTION%
SET _TitleStub=%NAME% v. %VERSION% Rev. %Revision%
TITLE %_TitleStub% 
ECHO Rev. %Revision%
ECHO By %Author%
    ECHO:
    CALL :Start_Timer
    CALL :Init %*
    CALL :main
    :: CALL :TEST
    ::CALL :EjectCard
    CALL :show_Timer
    PAUSE
GOTO :EOF
::----------------------------------------------------------------------

:init
    SET _ROOT=%STUB%
    IF NOT "!"=="!%~1" SET _ROOT=%~1
    ::CD /D "%_Root%"
    PUSHD "%_Root%"
    SET _ERRORS=0
    SET _FILES=0
    ::SET _Total_FILES=0
    SET _Total_files_=0
    SET STANDARD_EXTENTIONS=jpg
    ::SET RAW_EXTENTIONS=dng pef tif 
    SET RAW_EXTENTIONS=dng pef tif crw cr2 nef nrw orf
    SET MOVIE_EXTENTIONS=avi mov thm
    ::SET _SD-DRIVE=E:
    SET _SD-DRIVE=
    ::SET _SD-DRIVE_RANGE=D E F G H I J K
    SET _SD-DRIVE_RANGE=

    
    IF NOT "!"=="%2!" SET _SD-DRIVE=%~2
    ::IF NOT EXIST %_SD-DRIVE%\. GOTO Drive-not-ready
    CALL :SET_SD

    :: Set homedir
    ::IF NOT "!"=="%1!" CD /D %1
    IF NOT "!"=="%1!" PUSHD /D %1
    ECHO Working directory: [%CD%]
    ECHO Arguments: [%*]
GOTO :EOF   *** :init ***
::----------------------------------------------------------------------

:main
    ECHO:Drive range=[%_SD-DRIVE_RANGE%]
    FOR %%a IN ( %_SD-DRIVE_RANGE% ) DO (
        ECHO:- Checking %%a\DCIM
        ::IF EXIST %%a:\DCIM CALL SET _SD-DRIVE=%%a:
        IF EXIST %%a\DCIM CALL :Process_DCIM %%a
    )
GOTO :EOF   *** :main ****

::----------------------------------------------------------------------

:Process_DCIM
    SET _SD-DRIVE=%~1
    ECHO Counting files
    CALL :Count_files
    CALL :Show_filecount

:Standards
    ECHO Standards
    FOR %%j IN (%STANDARD_EXTENTIONS%) DO (
        FOR /F %%i IN ('DIR /B /S %_SD-DRIVE%\*.%%j 2^>NUL') DO (
            CALL :Copy_pic %%~nxi %%~ti %%~dpi new\
            REM ::CALL :Copy_pic %%~nxi %%~ti %%~dpi test2\
        )
    )
    ECHO:

:Raws
    ECHO Raws
    FOR %%j in (%RAW_EXTENTIONS%) DO (
        FOR /F %%i IN ('dir /B /S %_SD-DRIVE%\*.%%j 2^>NUL') DO (
            CALL :Copy_pic %%~nxi %%~ti %%~dpi raw\
        )
    )
    ECHO:

:Movie
    ECHO Movie
    FOR %%j in (%MOVIE_EXTENTIONS%) DO (
        FOR /F %%i IN ('dir /B /S %_SD-DRIVE%\*.%%j 2^>NUL') DO (
            CALL :Copy_pic %%~nxi %%~ti %%~dpi new\
        )
    )
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
    
    IF NOT EXIST %5%_dato:~0,10%\nul (
        ECHO:
        ECHO - Create "%5%_dato:~0,10%\"
        MKDIR "%5%_dato:~0,10%\"
        SET /p _=+<nul
    )

    IF NOT EXIST %5%_dato:~0,10%\%_dato%_%1 (
        TITLE %NAME%: Copying %_dato%_%1
        COPY %4%1 %5%_dato:~0,10%\%_dato%_%1 >>%_root%.error.txt 2>&1
        IF ERRORLEVEL 1 ECHO FEJL & SET /A _ERRORS=%_ERRORS% + 1 & pause
        ::CALL SET /A _FILES_%_FILE:~-3%=%_FILES_%_FILE:~-3%% + 1
        CALL SET /A _FILEs=%_FILES% + 1
        CALL :add_one _FILES_%_FILE:~-3%
        CALL :add_one _Total_files_

        SET /p _=o<nul
    ) ELSE (
        rem TITLE %$NAME%: Skipping %_dato%_%1
        CALL SET /A _FILEs=%_FILES% + 1
        SET /p _=.<nul
    )
    TITLE %_TitleStub% - %_FILES% / %_Total_FILES_%
GOTO :EOF   *** :copy_pic ***

::----------------------------------------------------------------------

:stamping
    SET FIle=%~1
    SET stamp=%2 %3
    MOVE %file% %stamp:~6,4%-%stamp:~3,2%-%stamp:~0,2%T%stamp:~11,2%-%stamp:~14,2%-00_%file%
GOTO :EOF   *** :stamping ***

::----------------------------------------------------------------------

:: Set count to 0
:init_var
    CALL SET /a %1=0
GOTO :EOF   *** :init_var ***

::----------------------------------------------------------------------

:Add_one
    CALL SET /a %1=%%%1%% + 1
GOTO :EOF   *** :Add_one ***

::----------------------------------------------------------------------

:show
   SET _=%~1          !
   SET __=          %~2
   ECHO   %_:~2,10%: %__:~-10%
GOTO :EOF   *** :show ***

::----------------------------------------------------------------------

:EjectCard
    ECHO %0
    %SystemRoot%\System32\rundll32.exe shell32.dll,Control_RunDLL hotplug.dll
    ECHO %0 DONE
GOTO :EOF    *** :EjectCard ***

::----------------------------------------------------------------------

:Count_files
    FOR %%j in (%STANDARD_EXTENTIONS% %RAW_EXTENTIONS% %MOVIE_EXTENTIONS% ) DO (
        CALL :init_var $$%%j
::echo: dir /B /S %_SD-DRIVE%\*.%%j
        FOR /F %%i IN ('dir /B /S %_SD-DRIVE%\*.%%j 2^>NUL') DO (
            CALL :add_one $$%%j
            CALL :add_one _Total_files_
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
    :: DriveType is returned as an integer that corresponds to the type of 
:: disk drive the logical disk represents (and this matches the 
:: Description, making DriveType sort of superfluous). 
:: 0 = Unknown
:: 1 = No Root Directory
:: 2 = Removable Disk
:: 3 = Local Disk
:: 4 = Network Drive
:: 5 = Compact Disc
:: 6 = RAM Disk
:: get removable drives (Type 2)
    SET _WCIM=wmic logicaldisk get drivetype^^,caption
    FOR /F "tokens=1,2*" %%a IN ('%_WCIM% ^| Findstr "2"') DO (
        CALL :appendVar _SD-DRIVE_RANGE %%a
    )
    ::CALL SET _SD-DRIVE_RANGE=!_SD-DRIVE_RANGE! %%a
GOTO :EOF   *** :set_sd ***

::----------------------------------------------------------------------

:: Append value environment string
:appendVar Var value
    CALL SET %~1=%%%1%% %~2
GOTO :EOF
::----------------------------------------------------------------------

:: Start timer to messure duration of the processing by reading system time
:start_Timer
::    FOR /F "skip=1 tokens=1-6" %%A IN ('WMIC Path Win32_LocalTime Get Day^,Hour^,Minute^,Second /Format:table ^| findstr /r "."') DO (
    SET _WCIM=WMIC Path Win32_LocalTime Get Day^^,Hour^^,Minute^^,Second
    FOR /F "skip=1 tokens=1-6" %%A IN ('%_WCIM% /Format:table ^| findstr /r "."') DO (

        SET Milisecond=%time:~9,2% 
        SET Day=%%A
        SET Hour=%%B
        SET Minute=%%C
        SET Second=%%D
    )
    SET /a Start=%Day%*8640000+%Hour%*360000+%Minute%*6000+%Second%*100+%Milisecond%
GOTO :EOF

::----------------------------------------------------------------------

:: Calculate duration by comparing system time with stored start time
:show_timer
::    FOR /F "skip=1 tokens=1-6" %%A IN ('WMIC Path Win32_LocalTime Get Day^,Hour^,Minute^,Second /Format:table ^| findstr /r "."') DO (
    SET _WCIM=WMIC Path Win32_LocalTime Get Day^^,Hour^^,Minute^^,Second
    FOR /F "skip=1 tokens=1-6" %%A IN ('%_WCIM% /Format:table ^| findstr /r "."') DO (
        SET Day=%%A
        SET Hour=%%B
        SET Minute=%%C
        SET Second=%%D
    )
    SET Milisecond=%time:~9,2% 
    SET /a End=%Day%*8640000+%Hour%*360000+%Minute%*6000+%Second%*100+%Milisecond%
    SET /a Diff=%End%-%Start%
    SET /a DiffMS=%Diff%%%100
    SET /a Diff=(%Diff%-%DiffMS%)/100
    SET /a DiffSec=%Diff%%%60
    SET /a Diff=(%Diff%-%Diff%%%60)/60
    SET /a DiffMin=%Diff%%%60
    SET /a Diff=(%Diff%-%Diff%%%60)/60
    SET /a DiffHrs=%Diff%
     
    :: format with leading zeroes
::    if %DiffMS% LSS 10 SET DiffMS=0%DiffMS!%
::    if %DiffSec% LSS 10 SET DiffMS=0%DiffSec%
::    if %DiffMin% LSS 10 SET DiffMS=0%DiffMin%
::    if %DiffHrs% LSS 10 SET DiffMS=0%DiffHrs%
    SET DiffMS=00%DiffMS%
    SET DiffSec=00%DiffSec%
    SET DiffMin=00%DiffMin%
    SET DiffHrs=00%DiffHrs%
    ECHO: 
    ECHO Duration: %DiffHrs:~-2%:%DiffMin:~-2%:%DiffSec:~-2%.%DiffMS:~-2%
GOTO :EOF

::*** End of File ******************************************************