@echo off
setlocal enableDelayedExpansion


    ::Define CR variable containing a carriage return (0x0D)
    for /f %%a in ('copy /Z "%~dpf0" nul') do set "_CR=%%a"

echo     Delayed expansion!_CR!OK
GOTO :EOF



:: Define CR to contain a single carriage return character.
:: This also demonstrates that carriage return is stripped before
:: FOR variable expansion
for /f %%a in ('copy /Z "%~dpf0" nul') do (
  set "CR=%%a"
  echo     FOR variable%%aOK
)

:: Normal expansion seems to fail because all carriage returns
:: are stripped from the line after expansion
echo     Normal expansion%CR%FAIL

:: Delayed expansion works just fine
echo     Delayed expansion!CR!OK

:: Demonstrate that Normal expansion actually works by replacing the
:: carriage return with some other text
echo Normal expansion %CR: