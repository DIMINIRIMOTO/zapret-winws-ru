@echo off
::TITLE
title universal.bat
::COLOR
color 0A
:menu
echo ============================
echo Select an option:
echo 1. Delete service
echo 2. Uninstalling an application
echo 3. Exit
echo ============================
set /p choice=Select:

if "%choice%"=="1" goto function1
if "%choice%"=="2" goto function2
if "%choice%"=="3" goto exit
echo Incorrect select. Try again.
pause
goto menu

:function1
@echo off
set SRVCNAME=zapret
net stop "%SRVCNAME%"
sc delete "%SRVCNAME%"
pause
exit

:function2
@echo off
net stop "WinDivert"
sc delete "WinDivert"
net stop "WinDivert14"
sc delete "WinDivert14"
pause
exit

:exit
echo Good luck!
pause
exit