REM This script is a wrapper for powershell to make it easy to call PS scripts via winexe on a Linux machine (this script runs on the Windows proxy)

@echo off
set scriptname=%1

rem Throw the first parameter away so we can pass the rest to the script
shift
set params=%1
:loop
shift
if [%1]==[] goto break
set params=%params% %1
goto loop
:break

powershell.exe -NoProfile -NoLogo -NonInteractive -File %scriptname% %params%
rem This will echo PSRreturnCode:X where X is the powershell.exe return code
rem <nul (set/p junk=PSReturnCode:%ERRORLEVEL%)
exit /b %ERRORLEVEL%
