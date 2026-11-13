@echo off
::(*_*)::
if "%~1"=="zapret_game_init" (
    call :game_switch_status
    exit /b
)
::(*_*)::
if "%~1"=="zapret_set_ts" (
    call :tcp_enable
    exit /b
)
::(*_*)::
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo [Error] Please run this file as Administrator.
    pause
    exit /b
)
::(*_*)::
setlocal enabledelayedexpansion
::(*_*)::
:menu
cls
::(*_*)::
call :game_switch_status
call :ipset_switch_status
::(*_*)::
set "menu_choice=null"
echo ==========================================
echo              ZAPRET MANAGER
echo ==========================================
echo 1. Game filter (%GameFilterStatus%)
echo 2. Ipset filter (%IPsetStatus%)
echo 3. Delete App and Services
echo 4. Hosts update (Recommended)
echo 5. Restore hosts update (Default Windows)
echo 6. Timestamps diagnostics (Quick)
echo 7. Zapret service info (Debug)
echo 8. Discord cache cleaner (All)
echo 9. Network Reset (Default Settings)
echo 10. Check Bypass Status (Discord, YouTube, DNS)
echo 11. Clear DNS Cache (Windows System)
echo 12. Exit
echo ==========================================
set /p menu_choice=Enter option number (1-12): 
::(*_*)::
if "%menu_choice%"=="1" goto game_switch
if "%menu_choice%"=="2" goto ipset_switch
if "%menu_choice%"=="3" goto delete_zapret
if "%menu_choice%"=="4" goto hosts_run
if "%menu_choice%"=="5" goto hosts_undo
if "%menu_choice%"=="6" goto tcp_diagnostics
if "%menu_choice%"=="7" goto service_info
if "%menu_choice%"=="8" goto discord_cache
if "%menu_choice%"=="9" goto zapret_reset
if "%menu_choice%"=="10" goto zapret_test
if "%menu_choice%"=="11" goto flush_dns
if "%menu_choice%"=="12" goto exit
::(*_*)::
goto menu

::(*_*)::
:flush_dns
ipconfig /flushdns >nul 2>&1
echo.
echo [info] DNS cache successfully cleared.
echo.
pause
goto menu

::(*_*)::
:zapret_test
::(*_*)::
setlocal enabledelayedexpansion
::(*_*)::
set "ZAPRET_ACTIVE=0"
tasklist /fi "imagename eq winws.exe" 2>nul | find /i "winws.exe" >nul
if !errorlevel! equ 0 set "ZAPRET_ACTIVE=1"

::(*_*)::
sc query "zapret" 2>nul | find /i "RUNNING" >nul
if !errorlevel! equ 0 set "ZAPRET_ACTIVE=1"

::(*_*)::
if !ZAPRET_ACTIVE! equ 0 (
    echo.
    echo ==================================================
    echo [info] Zapret is not active!
    echo ==================================================
    echo.
    pause
    endlocal
    goto menu
)

::(*_*)::
set "FILE=%~dp0bins\zapret_targets.test"

if not exist "%FILE%" (
    echo.
    echo [info] zapret_targets.test is missing. Please redownload the application.
    echo.
    pause
    endlocal
    goto menu
)

echo.
echo ==================================================
echo         CONNECTION ^& BYPASS CHECK
echo ==================================================
echo.

set /a OK_CNT=0
set /a ERR_CNT=0
set /a ALL_CNT=0

for /f "usebackq tokens=1,* delims==" %%A in ("%FILE%") do (
    set "KEY=%%A"
    set "VAL=%%B"

    ::(*_*)::
    set "KEY=!KEY: =!"

    ::(*_*)::
    if defined KEY (
        if not "!KEY:~0,1!"=="#" (
            set /a ALL_CNT+=1
            ::(*_*)::
            set "VAL=!VAL:"=!"
            for /f "tokens=* delims= " %%X in ("!VAL!") do set "VAL=%%X"

            if "!VAL:~0,5!"=="PING:" (
                set "IP=!VAL:~5!"
                call :_zt_CheckPing "!KEY!" "!IP!"
            ) else (
                call :_zt_CheckWeb "!KEY!" "!VAL!"
            )
        )
    )
)

echo.
echo ==================================================
echo RESULT: !OK_CNT!/!ALL_CNT! OK  ^|  !ERR_CNT! Failed
echo ==================================================
echo.
pause
endlocal
goto menu

:_zt_CheckPing
<nul set /p="Checking %~1 (%~2)... "
ping -n 1 -w 1500 %~2 >nul
if !errorlevel! equ 0 (
    set /a OK_CNT+=1
    echo [OK]
) else (
    set /a ERR_CNT+=1
    echo [FAIL]
)
exit /b

:_zt_CheckWeb
set "HOST=%~2"
set "HOST=!HOST:https://=!"
set "HOST=!HOST:http://=!"

<nul set /p="Checking %~1 (%~2)... "
curl -s -I -m 4 "%~2" >nul
if !errorlevel! equ 0 (
    set "HTTP_RES=TLS: OK"
    set /a OK_CNT+=1
) else (
    set "HTTP_RES=TLS: FAIL"
    set /a ERR_CNT+=1
)

ping -n 1 -w 1500 !HOST! >nul
if !errorlevel! equ 0 (
    set "PING_RES=Ping: OK"
) else (
    set "PING_RES=Ping: FAIL"
)

echo [!HTTP_RES! ^| !PING_RES!]
exit /b

::(*_*)::
:zapret_reset
@echo off
netsh winsock reset >nul 2>&1
netsh int ip reset all >nul 2>&1
netsh winhttp reset proxy >nul 2>&1
ipconfig /flushdns >nul 2>&1
::(*_*)::
echo [info] Network has been reset. Please restart your PC.
::(*_*)::
pause
goto menu

::(*_*)::
:discord_cache
chcp 437 > nul
cls
::(*_*)::
set /p answer=Clear Discord cache (All versions)? (YES/NO):
::(*_*)::
if /i "%answer%"=="YES" (
    echo [info] Shutting down all Discord applications...
    taskkill /IM Discord.exe /F >nul 2>&1
    taskkill /IM DiscordPTB.exe /F >nul 2>&1
    taskkill /IM DiscordCanary.exe /F >nul 2>&1
    taskkill /IM DiscordDevelopment.exe /F >nul 2>&1
	::(*_*)::
    echo [info] Waiting for applications to close...
    timeout /t 2 >nul
	::(*_*)::
    echo [info] Clearing cache for all installed Discord versions...
	::(*_*)::
    if exist "%APPDATA%\discord" rd /s /q "%APPDATA%\discord" 2>nul
	::(*_*)::
    if exist "%APPDATA%\discordptb" rd /s /q "%APPDATA%\discordptb" 2>nul
	::(*_*)::
    if exist "%APPDATA%\discordcanary" rd /s /q "%APPDATA%\discordcanary" 2>nul
	::(*_*)::
    if exist "%APPDATA%\discorddevelopment" rd /s /q "%APPDATA%\discorddevelopment" 2>nul
	::(*_*)::
    echo [info] Operation completed.
) else (
    echo [info] Operation canceled.
)
::(*_*)::
pause
goto menu

::(*_*)::
:service_info
chcp 437 > nul
cls
::(*_*)::
echo ===================================================
echo           Zapret: Service Info
echo ===================================================
echo.

reg query "HKLM\SYSTEM\CurrentControlSet\Services\zapret" /s 2>nul

if %errorlevel% neq 0 (
    echo [info] Zapret service not found in the registry.
    echo [info] It may be installed under a different name or deleted.
)

echo.
echo ===================================================
::(*_*)::
pause
goto menu

::(*_*)::
:tcp_diagnostics
chcp 437 > nul
cls
::(*_*)::
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
::(*_*)::
pause
goto menu

::(*_*)::
:tcp_enable
chcp 437 > nul
netsh interface tcp show global | findstr /i "timestamps" | findstr /i "enabled" > nul || netsh interface tcp set global timestamps=enabled > nul 2>&1
exit /b

::(*_*)::
:game_switch_status
chcp 437 > nul
::(*_*)::
set "gameFlagFile=%~dp0bins\game_filter.status"
::(*_*)::
if not exist "%gameFlagFile%" (
    set "GameFilterStatus=disabled"
    set "GameFilterTCP=12"
    set "GameFilterUDP=12"
    exit /b
)
::(*_*)::
set "GameFilterMode="
for /f "usebackq delims=" %%A in ("%gameFlagFile%") do (
    if not defined GameFilterMode set "GameFilterMode=%%A"
)
::(*_*)::
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

::(*_*)::
:game_switch
chcp 437 > nul
cls
::(*_*)::
echo ==========================================
echo Game filter mode selection:
echo   0. disabled
echo   1. enabled [TCP/UDP]
echo   2. enabled [TCP]
echo   3. enabled [UDP]
echo ==========================================
::(*_*)::
set "GameFilterChoice=0"
set /p "GameFilterChoice=Mode selection (0-3)"
if "%GameFilterChoice%"=="" set "GameFilterChoice=0"
::(*_*)::
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
::(*_*)::	
echo [info] Changes applied. Please restart the application.
::(*_*)::
pause
goto menu

::(*_*)::
:ipset_switch_status
chcp 437 > nul
::(*_*)::
set "listFile=%~dp0files\ipset-general.txt"
for /f %%i in ('type "%listFile%" 2^>nul ^| find /c /v ""') do set "lineCount=%%i"
::(*_*)::
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

::(*_*)::
:ipset_switch
chcp 437 > nul
cls
::(*_*)::
set "listFile=%~dp0files\ipset-general.txt"
set "backupFile=%listFile%.old"
::(*_*)::
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
::(*_*)::
pause
goto menu

::(*_*)::
:delete_zapret
@echo off
set SRVCNAME=zapret
net stop "%SRVCNAME%" >nul 2>&1
sc delete "%SRVCNAME%" >nul 2>&1
net stop "WinDivert" >nul 2>&1
sc delete "WinDivert" >nul 2>&1
net stop "WinDivert14" >nul 2>&1
sc delete "WinDivert14" >nul 2>&1
net stop "Monkey" >nul 2>&1
sc delete "Monkey" >nul 2>&1
::(*_*)::
echo [info] Application has been deleted.
::(*_*)::
pause
goto menu

::(*_*)::
:hosts_run
@echo off
::(*_*)::
set "sourceFile=%~dp0bins\hosts_update.run"
set "hostFile=%SystemRoot%\System32\drivers\etc\hosts"
::(*_*)::
if not exist "%sourceFile%" (
    echo Files with new lines not found: %sourceFile%
    goto :EOF
)
::(*_*)::
echo. >> "%hostFile%"
::
for /f "usebackq delims=" %%A in ("%sourceFile%") do (
    findstr /x /c:"%%A" "%hostFile%" >nul
    if errorlevel 1 (
        echo %%A>>"%hostFile%"
    )
)
::(*_*)::
echo [info] Hosts file successfully modified.
::(*_*)::
pause
goto menu

::(*_*)::
:hosts_undo
@echo off
::(*_*)::
setlocal
::(*_*)::
set "hostFile=%SystemRoot%\System32\drivers\etc\hosts"
set "replacementFile=%~dp0bins\hosts_update.undo"
::(*_*)::
if not exist "%replacementFile%" (
    echo Files %replacementFile% not found.
    goto :EOF
)
::(*_*)::
copy /Y "%replacementFile%" "%hostFile%" >nul
::(*_*)::
echo [info] Hosts file restored to default state.
::(*_*)::
pause
goto menu

::(*_*)::
:exit
endlocal
exit /b
