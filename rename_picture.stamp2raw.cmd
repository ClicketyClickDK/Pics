@ECHO OFF

for %%i in (*.jpg) do (
    ::2009-03-15 02:24
    call :stamping %%i %%~ti
)
for %%i in (*.dng) do (
    ::2009-03-15 02:24
    call :stamping %%i %%~ti
)

GOTO :EOF
:stamping
    SET FIle=%~1
    set stamp=%2 %3
    IF "-"=="%stamp:~2,1%" SET STAMP=%stamp:~6,4%-%stamp:~3,2%-%stamp:~0,2%T%stamp:~11,2%-%stamp:~14,2%-00
    ::echo move %file% %file:~6,4%-%file:~3,2%-%file:~0,2%%file:~10,10%
   :: echo move %file% %file:~10%
   move %file% %Stamp%_%file%
