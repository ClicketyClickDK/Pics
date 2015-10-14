@ECHO OFF
SETLOCAL ENABLEDELAYEDEXPANSION

    ::Define CR variable containing a carriage return (0x0D)
    for /f %%a in ('copy /Z "%~dpf0" nul') do set "_CR=%%a"
SET _Count=0
del *.thm.jpg
FOR %%a in (*.jpg) DO CALL SET /a _TotalCount+=1

FOR %%a in (*.jpg) DO (
    SET /a _count+=1
    TITLE %~n0 : %%a !_Count! / %_TotalCount% 
    SET /P _=%%a     !_Count! / %_TotalCount% !_CR!<nul
    CALL CreateThumb "%%a"
)
GOTO :EOF
