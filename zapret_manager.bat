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
setlocal EnableDelayedExpansion
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
echo 4. Hosts update (recommended)
echo 5. Restore hosts update (default windows)
echo 6. Zapret diagnostics (lite)
echo 7. Zapret service info (debug)
echo 8. Discord cache cleaner (all)
echo 9. Network Reset (default settings)
echo 10. Exit
echo ==========================================
set /p menu_choice=Enter option number (1-10): 
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
if "%menu_choice%"=="10" goto exit
::(*_*)::
goto menu

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
