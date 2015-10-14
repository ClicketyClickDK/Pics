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
    if "-"=="%stamp:~2,1%" (
        move %file% %stamp:~6,4%-%stamp:~3,2%-%stamp:~0,2%T%stamp:~11,2%-%stamp:~14,2%-00_%file%
    ) ELSE move %file% %stamp:~0,10%T%stamp:~11,2%-%stamp:~14,2%-00_%file%
    
    