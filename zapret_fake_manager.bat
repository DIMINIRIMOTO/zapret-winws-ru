@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

:: Check for Administrator privileges
net session >nul 2>&1
if %errorlevel% neq 0 (
    cls
    echo [ERROR] Administrator privileges are required.
    echo Please right-click this file and select "Run as administrator".
    echo.
    pause
    exit /b
)

:: Change directory to where the batch file is located
cd /d "%~dp0"

:: Set path to the log file inside your bins folder
set "LOG_FILE=%~dp0bins\zapret_fake.status"
set "DISCORD_TARGET=ACTIVE_DISCORD_UDP.bin"
set "GAME_TARGET=ACTIVE_GAME_UDP.bin"

:: Initialize default status variables
set "STATUS_DISCORD=Discord UDP (Voice): [Not selected]"
set "STATUS_GAME=GameFilter UDP: [Not selected]"

echo Searching for "files" folder...
set "SOURCE_DIR="

:: Fast search for a folder ending with \files
for /f "delims=" %%D in ('dir /b /s /ad 2^>nul ^| findstr /i "\\files$"') do (
    set "SOURCE_DIR=%%D"
    goto :FOUND_DIR
)

:FOUND_DIR
if not defined SOURCE_DIR (
    cls
    echo [ERROR] Could not find "files" folder near this batch script.
    echo Make sure the folder named "files" exists here or in subfolders.
    echo.
    pause
    exit
)

:: CHECK FOR ACTIVE FAKES AND CLEAN LOG
if not exist "%SOURCE_DIR%\%DISCORD_TARGET%" if not exist "%SOURCE_DIR%\%GAME_TARGET%" (
    if exist "%LOG_FILE%" del /f /q "%LOG_FILE%" >nul
)

:: Load statuses from log at startup (if log survived the check)
if exist "%LOG_FILE%" (
    for /f "usebackq delims=" %%A in ("%LOG_FILE%") do (
        set "line=%%A"
        if "!line:~0,19!"=="Discord UDP (Voice)" set "STATUS_DISCORD=!line!"
        if "!line:~0,14!"=="GameFilter UDP" set "STATUS_GAME=!line!"
    )
)

:: Reset status in interface if one of the target files was manually deleted
if not exist "%SOURCE_DIR%\%DISCORD_TARGET%" set "STATUS_DISCORD=Discord UDP (Voice): [Not selected]"
if not exist "%SOURCE_DIR%\%GAME_TARGET%" set "STATUS_GAME=GameFilter UDP: [Not selected]"

:MAIN_MENU
cls
echo ===================================================
echo               ZAPRET FAKE MANAGER
echo ===================================================
echo.
echo STATUS:
echo %STATUS_DISCORD%
echo %STATUS_GAME%
echo.
echo ---------------------------------------------------
echo Select a service to replace fake:
echo 1. Discord UDP (Voice) (%DISCORD_TARGET%)
echo 2. GameFilter UDP (%GAME_TARGET%)
echo 3. Exit
echo ---------------------------------------------------
set /p "service_choice=Enter option number (1-3): "

if "%service_choice%"=="1" set "TARGET_NAME=%DISCORD_TARGET%" & set "SERVICE_LABEL=Discord UDP (Voice)" & goto :SELECT_FAKE
if "%service_choice%"=="2" set "TARGET_NAME=%GAME_TARGET%" & set "SERVICE_LABEL=GameFilter UDP" & goto :SELECT_FAKE
if "%service_choice%"=="3" exit
goto :MAIN_MENU

:SELECT_FAKE
cls
echo ===================================================
echo Select fake file for: %SERVICE_LABEL%
echo ===================================================
echo.
echo Available files:
echo.

set "count=0"
for %%F in ("%SOURCE_DIR%\*.bin") do (
    if /i "%%~nxF" NEQ "%DISCORD_TARGET%" (
        if /i "%%~nxF" NEQ "%GAME_TARGET%" (
            set /a count+=1
            set "fake[!count!]=%%~nxF"
            echo !count!. %%~nxF
        )
    )
)

if %count%==0 (
    echo No available .bin files found in "%SOURCE_DIR%" folder!
    pause
    goto :MAIN_MENU
)

echo.
echo 0. Go back
echo ---------------------------------------------------
set /p "fake_choice=Select file number (0-%count%): "

if "%fake_choice%"=="0" goto :MAIN_MENU

if not defined fake[%fake_choice%] (
    echo Invalid choice, please try again.
    pause
    goto :SELECT_FAKE
)

set "SELECTED_FAKE=!fake[%fake_choice%]!"

:: Copy file inside %SOURCE_DIR% folder
copy /y "%SOURCE_DIR%\%SELECTED_FAKE%" "%SOURCE_DIR%\%TARGET_NAME%" >nul

if %errorlevel%==0 (
    echo.
    echo [SUCCESS] File %SELECTED_FAKE% copied as %TARGET_NAME%
    
    :: Form the status string
    if "%SERVICE_LABEL%"=="Discord UDP (Voice)" (
        set "STATUS_DISCORD=Discord UDP (Voice): %SELECTED_FAKE%"
    ) else (
        set "STATUS_GAME=GameFilter UDP: %SELECTED_FAKE%"
    )
    
    :: Write to log inside the existing bins folder
    echo !STATUS_DISCORD!> "%LOG_FILE%"
    echo !STATUS_GAME!>> "%LOG_FILE%"
    
    ping -n 2 127.0.0.1 >nul
) else (
    echo [ERROR] Failed to copy the file.
)

pause
goto :MAIN_MENU
