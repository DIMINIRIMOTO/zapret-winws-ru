@echo off
::LOAD
if "%~1"=="load_game_filter" (
    call :game_switch_status
	call :tcp_enable
    exit /b
)
::ADMIN
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo RUN FILE WITH ADMINISTRATOR RIGHTS.
    pause
    exit /b
)
::LOCAL BATCH
setlocal EnableDelayedExpansion
:: MENU (LITE)
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
echo 5. DISCORD VOICE FIX
echo 6. DELETE DISCORD VOICE FIX
echo 7. CLEAR DNS CACHE (NEW)
echo 8. EXIT
echo ==========================================
set /p menu_choice=ENTER CHOICE (1-8): 
::SELECT
if "%menu_choice%"=="1" goto game_switch
if "%menu_choice%"=="2" goto ipset_switch
if "%menu_choice%"=="3" goto delete_service
if "%menu_choice%"=="4" goto delete_app
if "%menu_choice%"=="5" goto discord_fix
if "%menu_choice%"=="6" goto delete_discord_fix
if "%menu_choice%"=="7" goto flush_dns
if "%menu_choice%"=="8" goto exit
goto menu

::TCP WINDOWS ENABLE (RECOMMENDED)
:tcp_enable
netsh interface tcp show global | findstr /i "timestamps" | findstr /i "enabled" > nul || netsh interface tcp set global timestamps=enabled > nul 2>&1
exit /b

::WINDOWS CACHE DNS REMOVE (LITE)
:flush_dns
cls
::CODE(NEW)
ipconfig /flushdns
::PAUSE(STOP)
pause
::HOME(EXIT)
goto menu

::STATUS (MINIMAL)
:game_switch_status
chcp 437 > nul
::LOAD
set "gameFlagFile=%~dp0bins\game_filter.status"
::DISABLE
if not exist "%gameFlagFile%" (
    set "GameFilterStatus=DISABLED"
    set "GameFilterTCP=12"
    set "GameFilterUDP=12"
    exit /b
)
::MODE
set "GameFilterMode="
for /f "usebackq delims=" %%A in ("%gameFlagFile%") do (
    if not defined GameFilterMode set "GameFilterMode=%%A"
)
::LOAD MODE
if /i "%GameFilterMode%"=="all" (
    set "GameFilterStatus=ENABLED [ALL]"
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
::END
exit /b

::GAME FILTER SWITCHER (MINIMAL)
:game_switch
chcp 437 > nul
cls
::MENU
echo ==========================================
echo GAME FILTER MODE SELECTION:
echo   0. DISABLED
echo   1. ENABLED [ALL]
echo   2. ENABLED [TCP]
echo   3. ENABLED [UDP]
echo ==========================================
::MENU END
set "GameFilterChoice=0"
set /p "GameFilterChoice=MODE SELECTION (0-3)"
if %GameFilterChoice%=="" set "GameFilterChoice=0"
::LOAD FILES
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
::PAUSE
pause
::EXIT
goto menu

::STATUS (MINIMAL)
:ipset_switch_status
chcp 437 > nul
::STATUS/IPSETS
set "listFile=%~dp0files\ipset-general.txt"
for /f %%i in ('type "%listFile%" 2^>nul ^| find /c /v ""') do set "lineCount=%%i"

if !lineCount!==0 (
    set "IPsetStatus=EMPTY"
) else (
    findstr /R "^203\.0\.113\.113/32$" "%listFile%" >nul
    if !errorlevel!==0 (
        set "IPsetStatus=DISABLE"
    ) else (
        set "IPsetStatus=ENABLE"
    )
)
exit /b

::IPSET FILTER SWITCHER (MINIMAL)
:ipset_switch
chcp 437 > nul
cls
::LOAD
set "listFile=%~dp0files\ipset-general.txt"
set "backupFile=%listFile%.old"
::SWITCHER/IPSETS
if "%IPsetStatus%"=="ENABLE" (
    echo IN THIS MODE, THE CURRENT WORKS WITH ADDRESSES FROM THE FILE.
    if not exist "%backupFile%" (
        ren "%listFile%" "ipset-general.txt.old"
    ) else (
        del /f /q "%backupFile%"
        ren "%listFile%" "ipset-general.txt.old"
    )
    >"%listFile%" (
        echo 203.0.113.113/32
    )
) else if "%IPsetStatus%"=="DISABLE" (
    echo TURNS OFF THIS MODE COMPLETELY.
    >"%listFile%" (
    rem CREATE EMPTY FILE.
    )
) else if "%IPsetStatus%"=="EMPTY" (
    echo THIS MODE SHOULD WORK WITH ALL ADDRESSES, BUT I'M NOT SURE IT ACTUALLY WORKS.
    if exist "%backupFile%" (
        del /f /q "%listFile%"
        ren "%backupFile%" "ipset-general.txt"
    ) else (
        echo I CAN'T READ THE BACKUP, PLEASE REDOWNLOAD THE APPLICATION.
        pause
        goto menu
    )
)
::PAUSE
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

::DISCORD VOICE FIX (MINIMAL)
:discord_fix
@echo off
::LOAD FILES
set "sourceFile=%~dp0bins\discord\discord_fix.voices"
set "hostFile=%SystemRoot%\System32\drivers\etc\hosts"
::ERROR LOGS
if not exist "%sourceFile%" (
    echo FILE WITH NEW LINES NOT FOUND: %sourceFile%
    goto :EOF
)
::Kostilb
echo. >> "%hostFile%"
::ADD DISCORD IP HOSTS (DIBLICATE FIX)
for /f "usebackq delims=" %%A in ("%sourceFile%") do (
    findstr /x /c:"%%A" "%hostFile%" >nul
    if errorlevel 1 (
        echo %%A>>"%hostFile%"
    )
)
::0
echo DISCORD VOICE FIX COMPLETE.
pause
::RETURN MENU
goto menu

::DELETE DISCORD FIX (REVERT)
:delete_discord_fix
@echo off
::LOCAL BATCH
setlocal
::LOAD FILES
set "hostFile=%SystemRoot%\System32\drivers\etc\hosts"
set "replacementFile=%~dp0bins\discord\discord_fix.revert"
::ERROR LOGS
if not exist "%replacementFile%" (
    echo FILE %replacementFile% NOT FOUND.
    goto :EOF
)
::REVERT HOSTS 
copy /Y "%replacementFile%" "%hostFile%" >nul
::0
echo DISCORD VOICE FIX DELETED.
pause
::RETURN MENU
goto menu

::END
:exit
echo GOOD LUCK
pause
exit
