@ECHO OFF
SETLOCAL

for %%i in (*.jpg) do (
    ::2009-03-15 02:24
    call :move %%i
)

GOTO :EOF

:MOVE

SET _=%~1
SET _DIR=%_:~0,10%

ECHO "%_DIR%"
IF NOT EXIST "%_DIR%" MKDIR "%_DIR%"
MOVE "%_%" "%_DIR%"
