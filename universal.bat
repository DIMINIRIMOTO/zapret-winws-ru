@echo off
::LOAD
if "%~1"=="load_game_filter" (
    call :game_switch_status
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
:: MENU
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
echo 7. EXIT
echo ==========================================
set /p menu_choice=ENTER CHOICE (1-7): 
::SELECT
if "%menu_choice%"=="1" goto game_switch
if "%menu_choice%"=="2" goto ipset_switch
if "%menu_choice%"=="3" goto delete_service
if "%menu_choice%"=="4" goto delete_app
if "%menu_choice%"=="5" goto discord_fix
if "%menu_choice%"=="6" goto delete_discord_fix
if "%menu_choice%"=="7" goto exit
goto menu

::GAME FILTER SWITCHER
:game_switch_status
chcp 437 > nul
::LOAD
set "gameFlagFile=%~dp0bins\game_filter.status"
::STATUS
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
::FILTER SWITCHER
if not exist "%gameFlagFile%" (
    echo GAME FILTER ENABLE
    echo ENABLED > "%gameFlagFile%"
) else (
    echo GAME FILTER DISABLE
    del /f /q "%gameFlagFile%"
)
::PAUSE
pause
::RETURN MENU
goto menu

::STATUS
:ipset_switch_status
chcp 437 > nul
::STATUS/IPSETS
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
::LOAD
set "listFile=%~dp0files\ipset-general.txt"
set "backupFile=%listFile%.old"
::SWITCHER
findstr /R "^203\.0\.113\.113/32$" "%listFile%" >nul
if !errorlevel!==0 (
    echo IPSET FILTER ENABLE
::0
    if exist "%backupFile%" (
        del /f /q "%listFile%"
        ren "%backupFile%" "ipset-general.txt"
    ) else (
        echo ERROR READING BACKUP
    )

) else (
    echo IPSET FILTER DISABLE
::0
    if not exist "%backupFile%" (
        ren "%listFile%" "ipset-general.txt.old"
    ) else (
        del /f /q "%backupFile%"
        ren "%listFile%" "ipset-general.txt.old"
    )
::0
    >"%listFile%" (
        echo 203.0.113.113/32
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

::DISCORD VOICE FIX
:discord_fix
@echo off
::LOAD FILES
set "sourceFile=%~dp0bins\discord_fix.voices"
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
set "replacementFile=%~dp0bins\discord_fix_revert"
::ERROR LOGS
if not exist "%replacementFile%" (
    echo FILE %replacementFile% NOT FOUND.
    goto :eof
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
