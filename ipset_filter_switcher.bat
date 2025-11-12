@echo off
setlocal enabledelayedexpansion
::TITLE
title IPSET FILTER SWITCHER
::COLOR
color 0A
::LOAD DIRECTORY
cd /d "%~dp0/files"
::LOAD FILES
set "file=ipset-general.txt"
::EDIT
set "newline=203.0.113.113/32"

:menu
echo ===============================
echo SELECT:
echo 1. IPSET FILTER OFF
echo 2. IPSET FILTER ON
echo 3. EXIT
echo ===============================
set /p choice=SELECT [1, 2, 3]:

if "%choice%"=="1" goto create_new
if "%choice%"=="2" goto restore_old
if "%choice%"=="3" goto end
echo INVALID PARAMETERS.
goto menu

:create_new
    if exist "%file%" (
        ren "%file%" "%file%.old"
    )
    echo %newline% > "%file%"
    echo IPSET FILTER OFF
    goto end

:restore_old
    for /f "delims=" %%a in ('dir /b /a:-d /o:-d "%file%.old"') do (
        copy "%%a" "%file%"
        del "%%a" 
		echo IPSET FILTER ON
        goto end
    )
    echo NO FILE FOUND.
    goto end

:end
echo GOOD LUCK.
pause
exit