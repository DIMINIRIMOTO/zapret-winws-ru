@echo off
setlocal enabledelayedexpansion

::LOAD DIRECTORY
cd /d "%~dp0"
::TITLE
title GAME FILTER SWITCHER
::COLOR
color 0A
::LOAD FILES
set "file1=preset_general[ALT].bat"
set "file2=service_create[ALT].bat"

:MENU
echo ===========================
echo SELECT:
echo 1. GAME FILTER OFF
echo 2. GAME FILTER ON
echo 3. EXIT
echo ===========================
set /p choice=CHOOSE [1, 2, 3]:

if "%choice%"=="1" goto DISABLE
if "%choice%"=="2" goto ENABLE
if "%choice%"=="3" goto END
echo INVALID PARAMETERS.
pause
goto MENU

:DISABLE
set "searchText=444-65535"
set "replaceText=12"
call :ReplaceInFile "%file1%" "%searchText%" "%replaceText%"
call :ReplaceInFile "%file2%" "%searchText%" "%replaceText%"
echo GAME FILTER DISABLE.
pause
exit

:ENABLE
set "searchText=12"
set "replaceText=444-65535"
call :ReplaceInFile "%file1%" "%searchText%" "%replaceText%"
call :ReplaceInFile "%file2%" "%searchText%" "%replaceText%"
echo GAME FILTER ENABLE.
pause
exit

:END
echo GOOD LUCK.
pause
exit

::XYITA
:ReplaceInFile
set "targetFile=%~1"
set "searchText=%~2"
set "replaceText=%~3"
set "tempFile=%temp%\temp_%RANDOM%.txt"

> "%tempFile%" (
    for /f "usebackq delims=" %%A in ("%targetFile%") do (
        set "line=%%A"
        echo !line! | findstr /c:"%searchText%" >nul
        if errorlevel 1 (
            echo !line!
        ) else (
            set "newline=!line:%searchText%=%replaceText%!"
            echo !newline!
        )
    )
)
move /Y "%tempFile%" "%targetFile%"
exit /b