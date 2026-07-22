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
    echo RUN THIS FILE AS ADMIN.
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
echo 1. GAME FILTER (%GameFilterStatus%)
echo 2. IPSET FILTER (%IPsetStatus%)
echo 3. DELETED SERVICE
echo 4. DELETED APP
echo 5. DISCORD VOICE FIX (RECOMMENDED)
echo 6. DELETE DISCORD VOICE FIX
echo 7. ZAPRET DIAGNOSTICS
echo 8. EXIT
echo ==========================================
set /p menu_choice=SELECT OPTIONS (1-8): 
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
    echo NO ERROR FOUND.
) else (
    echo ERROR WAS FOUND, FIXING...
    netsh interface tcp set global timestamps=enabled > nul 2>&1
    if !errorlevel!==0 (
        echo ERROR HAS BEEN FIXED.
    ) else (
        echo ERROR NOT FIXED, PLEASE CONTACT APP DEVELOPER.
    )
)
echo:

::CLEAR_DNS_CACHE
set /p answer=WANT TO CLEAR WINDOWS DNS CACHE? (YES/NO): 

if /i "%answer%"=="YES" (
    echo CLEARING DNS CACHE...
    call ipconfig /flushdns >nul 2>&1
    echo DNS CACHE CLEANED.
) else (
    echo OPERATION CANCELED.
)
echo:

::CLEAR_DISCORD_CACHE
set /p answer_app=WANT TO CLEAR DISCORD APPLICATION CACHE? (YES/NO):
 
if /i "%answer_app%"=="YES" (
    echo WE ARE SHUTTING DOWN DISCORD...
    taskkill /IM discord.exe /F >nul 2>&1

    echo WE ARE WAITING FOR THE CLOSING DISCORD...
    :wait_loop
    timeout /t 1 >nul
    tasklist /FI "IMAGENAME eq discord.exe" 2>NUL | find /I "discord.exe" >nul
    if errorlevel 1 (
        goto after_close
    ) else (
        goto wait_loop
    )
::OPERATION_CANSELED
:after_close
    echo CLEARING DISCORD CACHE...
    rd /s /q "%APPDATA%\discord"
    echo DISCORD CACHE CLEANED..
) else (
    echo OPERATION CANCELED.
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
    set "GameFilterStatus=DISABLED"
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
    set "GameFilterStatus=ENABLED [TCP/UDP]"
    set "GameFilterTCP=1024-65535"
    set "GameFilterUDP=1024-65535"
) else if /i "%GameFilterMode%"=="tcp" (
    set "GameFilterStatus=ENABLED [TCP]"
    set "GameFilterTCP=1024-65535"
    set "GameFilterUDP=12"
) else (
    set "GameFilterStatus=ENABLED [UDP]"
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
echo GAME FILTER MODE SELECTION:
echo   0. DISABLED
echo   1. ENABLED [TCP/UDP]
echo   2. ENABLED [TCP]
echo   3. ENABLED [UDP]
echo ==========================================
::NULL
set "GameFilterChoice=0"
set /p "GameFilterChoice=MODE SELECTION (0-3)"
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
echo THE SETTING HAVE BEEN APPLIED, PLEASE RESTART THE APPLICATION.
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
    set "IPsetStatus=EMPTY"
) else (
    findstr /C:"203.0.113.113/32" "%listFile%" >nul
    if !errorlevel!==0 (
        set "IPsetStatus=DISABLED"
    ) else (
        set "IPsetStatus=ENABLED"
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
if "%IPsetStatus%"=="ENABLED" (
    echo THE SETTING HAVE BEEN APPLIED, PLEASE RESTART THE APPLICATION.
    if not exist "%backupFile%" (
        ren "%listFile%" "ipset-general.txt.old"
    ) else (
        del /f /q "%backupFile%"
        ren "%listFile%" "ipset-general.txt.old"
    )
    >"%listFile%" (
        echo 203.0.113.113/32
    )
) else if "%IPsetStatus%"=="DISABLED" (
    echo THE SETTING HAVE BEEN APPLIED, PLEASE RESTART THE APPLICATION.
    >"%listFile%" (
    rem CREATE EMPTY FILE.
    )
) else if "%IPsetStatus%"=="EMPTY" (
    echo THE SETTING HAVE BEEN APPLIED, PLEASE RESTART THE APPLICATION.
    if exist "%backupFile%" (
        del /f /q "%listFile%"
        ren "%backupFile%" "ipset-general.txt"
    ) else (
        echo I CAN'T READ THE BACKUP, PLEASE REDOWNLOAD THE APPLICATION.
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
echo APPLICATION DELETED.
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
    echo FILE WITH NEW LINES NOT FOUND: %sourceFile%
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
echo DISCORD VOICE FIX COMPLETE.
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
    echo FILE %replacementFile% NOT FOUND.
    goto :EOF
)
::REVERT_HOSTS
copy /Y "%replacementFile%" "%hostFile%" >nul
::TEXT
echo DISCORD VOICE FIX DELETED.
::EXIT
pause
goto menu

::END
:exit
echo GOOD LUCK
pause
exit
