@echo off
::LOAD_GAME_FILTER
if "%~1"=="load_game_filter" (
    call :game_switch_status
    exit /b
)
::LOAD_TCP
if "%~1"=="zapret_set_ts" (
    call :tcp_enable
    exit /b
)
::ADMIN_USER
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo [Error] Please run this file as Administrator.
    pause
    exit /b
)
::LOCAL_BATCH
setlocal EnableDelayedExpansion
::MENU
:menu
cls
::LOAD_STATUS
call :game_switch_status
call :ipset_switch_status
::NULL
set "menu_choice=null"
echo ==========================================
echo              ZAPRET MANAGER
echo ==========================================
echo 1. Game filter (%GameFilterStatus%)
echo 2. Ipset filter (%IPsetStatus%)
echo 3. Windows service deleted
echo 4. Application deleted
echo 5. Discord voice fix (recommended)
echo 6. Remove Discord voice fix
echo 7. Zapret diagnostics
echo 8. Exit
echo ==========================================
set /p menu_choice=Enter option number (1-8): 
::SELECT
if "%menu_choice%"=="1" goto game_switch
if "%menu_choice%"=="2" goto ipset_switch
if "%menu_choice%"=="3" goto delete_service
if "%menu_choice%"=="4" goto delete_app
if "%menu_choice%"=="5" goto discord_fix
if "%menu_choice%"=="6" goto delete_discord_fix
if "%menu_choice%"=="7" goto tcp_diagnostics
if "%menu_choice%"=="8" goto exit
::EXIT
goto menu

::ZAPRET_DIAGNOSTICS
:tcp_diagnostics
chcp 437 > nul
cls
::TCP_DIAGNOSTICS
netsh interface tcp show global | findstr /i "timestamps" | findstr /i "enabled" > nul
if !errorlevel!==0 (
    echo [info] No errors found.
) else (
    echo [info] Error detected, fixing...
    netsh interface tcp set global timestamps=enabled > nul 2>&1
    if !errorlevel!==0 (
        echo [info] Error fixed successfully.
    ) else (
        echo [info] Error not fixed, please contact support.
    )
)
::NEXT
echo:

::CLEAR_DNS_CACHE
set /p answer0=Want to clear Windows DNS cache? (YES/NO): 

if /i "%answer0%"=="YES" (
    echo [info] Clearing DNS cache...
    call ipconfig /flushdns >nul 2>&1
    echo [info] DNS cache cleared.
) else (
    echo [info] Operation canceled.
)
::NEXT
echo:

::CLEAR_DISCORD_CACHE
set /p answer_app1=Want to clear Discord application cache? (YES/NO):
 
if /i "%answer_app1%"=="YES" (
    echo [info] Shutting down Discord...
    taskkill /IM Discord.exe /F >nul 2>&1

    echo [info] Waiting for Discord to close...
    :wait_loop1
    timeout /t 1 >nul
    tasklist /FI "IMAGENAME eq Discord.exe" 2>NUL | find /I "Discord.exe" >nul
    if errorlevel 1 (
        goto after_close1
    ) else (
        goto wait_loop1
    )
::OPERATION_CANSELED
:after_close1
    echo [info] Clearing Discord cache...
    rd /s /q "%APPDATA%\discord"
    echo [info] Discord cache cleared.
) else (
    echo [info] Operation canceled.
)
::NEXT
echo:

::CLEAR_DISCORD_PTB_CACHE
set /p answer_app2=Want to clear Discord PTB application cache? (YES/NO):
 
if /i "%answer_app2%"=="YES" (
    echo [info] Waiting for Discord PTB to close...
    taskkill /IM DiscordPTB.exe /F >nul 2>&1

    echo [info] Waiting for Discord PTB to close...
    :wait_loop2
    timeout /t 1 >nul
    tasklist /FI "IMAGENAME eq DiscordPTB.exe" 2>NUL | find /I "DiscordPTB.exe" >nul
    if errorlevel 1 (
        goto after_close2
    ) else (
        goto wait_loop2
    )
::OPERATION_CANSELED
:after_close2
    echo [info] Clearing Discord PTB cache...
    rd /s /q "%APPDATA%\discordptb"
    echo [info] Discord PTB cache cleared.
) else (
    echo [info] Operation canceled.
)
::EXIT
pause
goto menu

::TCP_WINDOWS
:tcp_enable
chcp 437 > nul
netsh interface tcp show global | findstr /i "timestamps" | findstr /i "enabled" > nul || netsh interface tcp set global timestamps=enabled > nul 2>&1
exit /b

::GAME_FILTER_STATUS
:game_switch_status
chcp 437 > nul
::FILES
set "gameFlagFile=%~dp0bins\game_filter.status"
::LOAD_DISABLED_MODE
if not exist "%gameFlagFile%" (
    set "GameFilterStatus=disabled"
    set "GameFilterTCP=12"
    set "GameFilterUDP=12"
    exit /b
)
::LOAD_DEFAULT_MODE
set "GameFilterMode="
for /f "usebackq delims=" %%A in ("%gameFlagFile%") do (
    if not defined GameFilterMode set "GameFilterMode=%%A"
)
::ALL_MODS
if /i "%GameFilterMode%"=="all" (
    set "GameFilterStatus=enabled [TCP/UDP]"
    set "GameFilterTCP=1024-65535"
    set "GameFilterUDP=1024-65535"
) else if /i "%GameFilterMode%"=="tcp" (
    set "GameFilterStatus=enabled [TCP]"
    set "GameFilterTCP=1024-65535"
    set "GameFilterUDP=12"
) else (
    set "GameFilterStatus=enabled [UDP]"
    set "GameFilterTCP=12"
    set "GameFilterUDP=1024-65535"
)
exit /b

::GAME_FILTER_SWITCHER
:game_switch
chcp 437 > nul
cls
::MENU
echo ==========================================
echo Game filter mode selection:
echo   0. disabled
echo   1. enabled [TCP/UDP]
echo   2. enabled [TCP]
echo   3. enabled [UDP]
echo ==========================================
::NULL
set "GameFilterChoice=0"
set /p "GameFilterChoice=Mode selection (0-3)"
if "%GameFilterChoice%"=="" set "GameFilterChoice=0"
::MODE
if "%GameFilterChoice%"=="0" (
    if exist "%gameFlagFile%" (
        del /f /q "%gameFlagFile%"
    ) else (
        goto menu
    )
) else if "%GameFilterChoice%"=="1" (
    echo all>"%gameFlagFile%"
) else if "%GameFilterChoice%"=="2" (
    echo tcp>"%gameFlagFile%"
) else if "%GameFilterChoice%"=="3" (
    echo udp>"%gameFlagFile%"
) else (
    echo > nul
    pause
    goto menu
	)
::TEXT	
echo [info] Changes applied. Please restart the application.
::EXIT
pause
goto menu

::IPSET_STATUS
:ipset_switch_status
chcp 437 > nul
::FILES
set "listFile=%~dp0files\ipset-general.txt"
for /f %%i in ('type "%listFile%" 2^>nul ^| find /c /v ""') do set "lineCount=%%i"
::MODE
if !lineCount!==0 (
    set "IPsetStatus=empty"
) else (
    findstr /C:"203.0.113.113/32" "%listFile%" >nul
    if !errorlevel!==0 (
        set "IPsetStatus=disabled"
    ) else (
        set "IPsetStatus=enabled"
    )
)
exit /b

::IPSET_FILTER_SWITCHER
:ipset_switch
chcp 437 > nul
cls
::FILES
set "listFile=%~dp0files\ipset-general.txt"
set "backupFile=%listFile%.old"
::MODE
if "%IPsetStatus%"=="enabled" (
    echo [info] Changes applied. Please restart the application.
    if not exist "%backupFile%" (
        ren "%listFile%" "ipset-general.txt.old"
    ) else (
        del /f /q "%backupFile%"
        ren "%listFile%" "ipset-general.txt.old"
    )
    >"%listFile%" (
        echo 203.0.113.113/32
    )
) else if "%IPsetStatus%"=="disabled" (
    echo [info] Changes applied. Please restart the application.
    >"%listFile%" (
    rem CREATE EMPTY FILE.
    )
) else if "%IPsetStatus%"=="empty" (
    echo [info] Changes applied. Please restart the application.
    if exist "%backupFile%" (
        del /f /q "%listFile%"
        ren "%backupFile%" "ipset-general.txt"
    ) else (
        echo [info] Unable to read backup, please redownload the application.
        pause
        goto menu
    )
)
::EXIT
pause
goto menu

::DELETE_SERVICE
:delete_service
@echo off
set SRVCNAME=zapret
net stop "%SRVCNAME%"
sc delete "%SRVCNAME%"
pause
goto menu

::DELETE_APP
:delete_app
@echo off
net stop "WinDivert" >nul 2>&1
sc delete "WinDivert" >nul 2>&1
net stop "WinDivert14" >nul 2>&1
sc delete "WinDivert14" >nul 2>&1
echo [info] Application has been deleted.
pause
goto menu

::DISCORD_VOICE_FIX
:discord_fix
@echo off
::LOAD_FILES
set "sourceFile=%~dp0bins\discord\discord_fix.voices"
set "hostFile=%SystemRoot%\System32\drivers\etc\hosts"
::LOGS
if not exist "%sourceFile%" (
    echo Files with new lines not found: %sourceFile%
    goto :EOF
)
::HOST_FILES
echo. >> "%hostFile%"
::ADD_DISCORD_IP_HOSTS
for /f "usebackq delims=" %%A in ("%sourceFile%") do (
    findstr /x /c:"%%A" "%hostFile%" >nul
    if errorlevel 1 (
        echo %%A>>"%hostFile%"
    )
)
::TEXT
echo [info] Discord voice fix applied.
::EXIT
pause
goto menu

::DELETE_DISCORD_FIX
:delete_discord_fix
@echo off
::LOCAL_BATCH
setlocal
::LOAD_FILES
set "hostFile=%SystemRoot%\System32\drivers\etc\hosts"
set "replacementFile=%~dp0bins\discord\discord_fix.revert"
::LOGS
if not exist "%replacementFile%" (
    echo Files %replacementFile% not found.
    goto :EOF
)
::REVERT_HOSTS
copy /Y "%replacementFile%" "%hostFile%" >nul
::TEXT
echo [info] Discord voice fix removed.
::EXIT
pause
goto menu
