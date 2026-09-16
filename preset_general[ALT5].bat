@echo off
chcp 65001 > nul

net session >nul 2>&1
if %errorlevel% neq 0 (
    echo [Error] Please run this file as Administrator.
    pause
    exit /b
)

cd /d "%~dp0"

:menu
cls
echo ==========================================
echo  1. Start Zapret (Manual Mode)
echo  2. Install as Windows Service
echo  3. Exit
echo ==========================================
echo.
set /p choice="Select an option (1-3): "

if "%choice%"=="1" goto run
if "%choice%"=="2" goto install
if "%choice%"=="3" goto exit

echo.
echo Invalid choice, please try again.
pause
goto menu

:install
call zapret_manager.bat zapret_set_ts
call zapret_manager.bat zapret_game_init
echo:
set "BIN=%~dp0bins\"
set "LISTS=%~dp0files\"
set ARGS=^
--wf-tcp=80,443,2053,2083,2087,2096,8443,%GameFilterTCP% --wf-udp=443,19294-19344,50000-50100,%GameFilterUDP% ^
--filter-udp=443 --hostlist="%LISTS%\list-general.txt" --hostlist-exclude="%LISTS%\list-exclude.txt" --ipset-exclude="%LISTS%\ipset-exclude.txt" --dpi-desync=fake --dpi-desync-repeats=6 --dpi-desync-fake-quic="%LISTS%\quic_initial_www_google_com.bin" --new ^
--filter-udp=19294-19344,50000-50100 --filter-l7=discord,stun --dpi-desync=fake --dpi-desync-fake-discord="%LISTS%\ACTIVE_DISCORD_UDP.bin" --dpi-desync-fake-stun="%LISTS%\ACTIVE_DISCORD_UDP.bin" --dpi-desync-repeats=6 --new ^
--filter-l3=ipv4 --filter-tcp=80,443,2053,2083,2087,2096,8443 --ipset-exclude="%LISTS%\ipset-exclude.txt" --dpi-desync=syndata,multidisorder --new ^
--filter-tcp=%GameFilterTCP% --ipset="%LISTS%\ipset-general.txt" --ipset-exclude="%LISTS%\ipset-exclude.txt" --dpi-desync=syndata,multidisorder --dpi-desync-any-protocol=1 --dpi-desync-cutoff=n4 --new ^
--filter-udp=443 --ipset="%LISTS%\ipset-general.txt" --hostlist-exclude="%LISTS%\list-exclude.txt" --ipset-exclude="%LISTS%\ipset-exclude.txt" --dpi-desync=fake --dpi-desync-repeats=6 --dpi-desync-fake-quic="%LISTS%\quic_initial_www_google_com.bin" --new ^
--filter-udp=%GameFilterUDP% --ipset="%LISTS%\ipset-general.txt" --ipset-exclude="%LISTS%\ipset-exclude.txt" --dpi-desync=fake --dpi-desync-repeats=14 --dpi-desync-any-protocol=1 --dpi-desync-fake-unknown-udp="%LISTS%\ACTIVE_GAME_UDP.bin" --dpi-desync-cutoff=n3
sc create "zapret" binPath= "\"%BIN%winws.exe\" %ARGS%" DisplayName= "zapret DPI bypass : winws1" start= auto
sc description "zapret" "zapret DPI bypass software"
sc start "zapret"
pause
exit /b

:run
call zapret_manager.bat zapret_set_ts
call zapret_manager.bat zapret_game_init
echo:
set "BIN=%~dp0bins\"
set "LISTS=%~dp0files\"
cd /d %BIN%
start "zapret: http,https,quic" /min "%BIN%winws.exe" ^
--wf-tcp=80,443,2053,2083,2087,2096,8443,%GameFilterTCP% --wf-udp=443,19294-19344,50000-50100,%GameFilterUDP% ^
--filter-udp=443 --hostlist="%LISTS%\list-general.txt" --hostlist-exclude="%LISTS%\list-exclude.txt" --ipset-exclude="%LISTS%\ipset-exclude.txt" --dpi-desync=fake --dpi-desync-repeats=6 --dpi-desync-fake-quic="%LISTS%\quic_initial_www_google_com.bin" --new ^
--filter-udp=19294-19344,50000-50100 --filter-l7=discord,stun --dpi-desync=fake --dpi-desync-fake-discord="%LISTS%\ACTIVE_DISCORD_UDP.bin" --dpi-desync-fake-stun="%LISTS%\ACTIVE_DISCORD_UDP.bin" --dpi-desync-repeats=6 --new ^
--filter-l3=ipv4 --filter-tcp=80,443,2053,2083,2087,2096,8443 --ipset-exclude="%LISTS%\ipset-exclude.txt" --dpi-desync=syndata,multidisorder --new ^
--filter-tcp=%GameFilterTCP% --ipset="%LISTS%\ipset-general.txt" --ipset-exclude="%LISTS%\ipset-exclude.txt" --dpi-desync=syndata,multidisorder --dpi-desync-any-protocol=1 --dpi-desync-cutoff=n4 --new ^
--filter-udp=443 --ipset="%LISTS%\ipset-general.txt" --hostlist-exclude="%LISTS%\list-exclude.txt" --ipset-exclude="%LISTS%\ipset-exclude.txt" --dpi-desync=fake --dpi-desync-repeats=6 --dpi-desync-fake-quic="%LISTS%\quic_initial_www_google_com.bin" --new ^
--filter-udp=%GameFilterUDP% --ipset="%LISTS%\ipset-general.txt" --ipset-exclude="%LISTS%\ipset-exclude.txt" --dpi-desync=fake --dpi-desync-repeats=14 --dpi-desync-any-protocol=1 --dpi-desync-fake-unknown-udp="%LISTS%\ACTIVE_GAME_UDP.bin" --dpi-desync-cutoff=n3
exit /b
