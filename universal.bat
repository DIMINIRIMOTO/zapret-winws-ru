@echo off
::LOAD
if "%~1"=="load_game_filter" (
    call :game_switch_status
    exit /b
)
::ADMIN
if "%1"=="admin" (
::DISABLE TEXT
    echo > nul
) else (
::DISABLE TEXT
    echo > nul 
    powershell -Command "Start-Process 'cmd.exe' -ArgumentList '/c \"\"%~f0\" admin\"' -Verb RunAs"
    exit /b
)
:: MENU
setlocal EnableDelayedExpansion
:MENU
cls
:: LOAD STATUS
call :game_switch_status
call :ipset_switch_status
:: 0
set "menu_choice=null"
echo ==========================================
echo 1. GAME FILTER (%GameFilterStatus%)
echo 2. IPSET FILTER (%IPsetStatus%)
echo 3. DELETE SERVICE
echo 4. DELETE APP
echo 5. EXIT
echo ==========================================
set /p menu_choice=ENTER CHOICE (1-5): 
::SELECT
if "%menu_choice%"=="1" goto game_switch
if "%menu_choice%"=="2" goto ipset_switch
if "%menu_choice%"=="3" goto delete_service
if "%menu_choice%"=="4" goto delete_app
if "%menu_choice%"=="5" goto exit
goto menu

::GAME FILTER SWITCHER
:game_switch_status
chcp 437 > nul

set "gameFlagFile=%~dp0bins\game_filter.status"

if exist "%gameFlagFile%" (
    set "GameFilterStatus=ON"
    set "GameFilter=1024-65535"
) else (
    set "GameFilterStatus=OFF"
    set "GameFilter=12"
)
exit /b

::STATUS
:game_switch
chcp 437 > nul
cls

if not exist "%gameFlagFile%" (
    echo GAME FILTER ENABLE
    echo ENABLED > "%gameFlagFile%"
) else (
    echo GAME FILTER DISABLE
    del /f /q "%gameFlagFile%"
)

pause
::RETURN MENU
goto menu

::STATUS
:ipset_switch_status
chcp 437 > nul

findstr /R "^203\.0\.113\.113/32$" "%~dp0files\ipset-general.txt" >nul
if !errorlevel!==0 (
    set "IPsetStatus=OFF"
) else (
    set "IPsetStatus=ON"
)
exit /b

::IPSET FILTER SWITCHER
:ipset_switch
chcp 437 > nul
cls

set "listFile=%~dp0files\ipset-general.txt"
set "backupFile=%listFile%.old"

findstr /R "^203\.0\.113\.113/32$" "%listFile%" >nul
if !errorlevel!==0 (
    echo IPSET FILTER ENABLE

    if exist "%backupFile%" (
        del /f /q "%listFile%"
        ren "%backupFile%" "ipset-general.txt"
    ) else (
        echo ERROR READING BACKUP
    )

) else (
    echo IPSET FILTER DISABLE

    if not exist "%backupFile%" (
        ren "%listFile%" "ipset-general.txt.old"
    ) else (
        del /f /q "%backupFile%"
        ren "%listFile%" "ipset-general.txt.old"
    )

    >"%listFile%" (
        echo 203.0.113.113/32
    )
)

pause
::RETURN MENU
goto menu

::DELETE SERVICE
:delete_service
@echo off
set SRVCNAME=zapret
net stop "%SRVCNAME%"
sc delete "%SRVCNAME%"
pause
::RETURN MENU
goto menu

::DELETE APP
:delete_app
@echo off
net stop "WinDivert" >nul 2>&1
sc delete "WinDivert" >nul 2>&1
net stop "WinDivert14" >nul 2>&1
sc delete "WinDivert14" >nul 2>&1
echo ZAPRET REMOVE
pause
::RETURN MENU
goto menu

::END
:exit
echo GOOD LUCK
pause
exit

