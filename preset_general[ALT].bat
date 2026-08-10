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
call zapret_manager.bat load_game_filter
echo:
set BIN_PATH=%~dp0bins\
set ARGS=^
--wf-tcp=80,443,2053,2083,2087,2096,8443,%GameFilterTCP% --wf-udp=443,19294-19344,50000-50100,%GameFilterUDP% ^
--filter-udp=443 --hostlist="%~dp0files\list-general.txt" --hostlist-exclude="%~dp0files\list-exclude.txt" --ipset-exclude="%~dp0files\ipset-exclude.txt" --dpi-desync=fake --dpi-desync-repeats=6 --dpi-desync-fake-quic="%~dp0files\quic_initial_www_google_com.bin" --new ^
--filter-udp=19294-19344,50000-50100 --filter-l7=discord,stun --dpi-desync=fake --dpi-desync-fake-discord="%~dp0files\ACTIVE_DISCORD_UDP.bin" --dpi-desync-fake-stun="%~dp0files\ACTIVE_DISCORD_UDP.bin" --dpi-desync-repeats=6 --new ^
--filter-tcp=2053,2083,2087,2096,8443 --hostlist-domains=discord.media --dpi-desync=fake,fakedsplit --dpi-desync-repeats=6 --dpi-desync-fooling=ts --dpi-desync-fakedsplit-pattern=0x00 --dpi-desync-fake-tls="%~dp0files\tls_clienthello_www_google_com.bin" --new ^
--filter-tcp=443 --hostlist="%~dp0files\list-google.txt" --ip-id=zero --dpi-desync=fake,fakedsplit --dpi-desync-repeats=6 --dpi-desync-fooling=ts --dpi-desync-fakedsplit-pattern=0x00 --dpi-desync-fake-tls="%~dp0files\tls_clienthello_www_google_com.bin" --new ^
--filter-tcp=80,443 --hostlist="%~dp0files\list-general.txt" --hostlist-exclude="%~dp0files\list-exclude.txt" --ipset-exclude="%~dp0files\ipset-exclude.txt" --dpi-desync=fake,fakedsplit --dpi-desync-repeats=6 --dpi-desync-fooling=ts --dpi-desync-fakedsplit-pattern=0x00 --dpi-desync-fake-tls="%~dp0files\stun.bin" --dpi-desync-fake-tls="%~dp0files\tls_clienthello_www_google_com.bin" --dpi-desync-fake-http="%~dp0files\tls_clienthello_max_ru.bin" --new ^
--filter-udp=443 --ipset="%~dp0files\ipset-general.txt" --hostlist-exclude="%~dp0files\list-exclude.txt" --ipset-exclude="%~dp0files\ipset-exclude.txt" --dpi-desync=fake --dpi-desync-repeats=6 --dpi-desync-fake-quic="%~dp0files\quic_initial_www_google_com.bin" --new ^
--filter-tcp=80,443,8443 --ipset="%~dp0files\ipset-general.txt" --hostlist-exclude="%~dp0files\list-exclude.txt" --ipset-exclude="%~dp0files\ipset-exclude.txt" --dpi-desync=fake,fakedsplit --dpi-desync-repeats=6 --dpi-desync-fooling=ts --dpi-desync-fakedsplit-pattern=0x00 --dpi-desync-fake-tls="%~dp0files\stun.bin" --dpi-desync-fake-tls="%~dp0files\tls_clienthello_www_google_com.bin" --dpi-desync-fake-http="%~dp0files\tls_clienthello_max_ru.bin" --new ^
--filter-tcp=%GameFilterTCP% --ipset="%~dp0files\ipset-general.txt" --ipset-exclude="%~dp0files\ipset-exclude.txt" --dpi-desync=fake,fakedsplit --dpi-desync-repeats=6 --dpi-desync-any-protocol=1 --dpi-desync-cutoff=n4 --dpi-desync-fooling=ts --dpi-desync-fakedsplit-pattern=0x00 --dpi-desync-fake-tls="%~dp0files\stun.bin" --dpi-desync-fake-tls="%~dp0files\tls_clienthello_www_google_com.bin" --dpi-desync-fake-http="%~dp0files\tls_clienthello_max_ru.bin" --dpi-desync-fake-unknown="%~dp0files\stun.bin" --dpi-desync-fake-unknown="%~dp0files\tls_clienthello_www_google_com.bin" --new ^
--filter-udp=%GameFilterUDP% --ipset="%~dp0files\ipset-general.txt" --ipset-exclude="%~dp0files\ipset-exclude.txt" --dpi-desync=fake --dpi-desync-repeats=12 --dpi-desync-any-protocol=1 --dpi-desync-fake-unknown-udp="%~dp0files\ACTIVE_GAME_UDP.bin" --dpi-desync-cutoff=n3
sc create "zapret" binPath= "\"%BIN_PATH%winws.exe\" %ARGS%" DisplayName= "zapret DPI bypass : winws1" start= auto
sc description "zapret" "zapret DPI bypass software"
sc start "zapret"
pause
exit /b

:run
call zapret_manager.bat zapret_set_ts
call zapret_manager.bat load_game_filter
echo:
set BIN=%~dp0bins\
cd /d %BIN%
start "zapret: http,https,quic" /min "%BIN%winws.exe" ^
--wf-tcp=80,443,2053,2083,2087,2096,8443,%GameFilterTCP% --wf-udp=443,19294-19344,50000-50100,%GameFilterUDP% ^
--filter-udp=443 --hostlist="%~dp0files\list-general.txt" --hostlist-exclude="%~dp0files\list-exclude.txt" --ipset-exclude="%~dp0files\ipset-exclude.txt" --dpi-desync=fake --dpi-desync-repeats=6 --dpi-desync-fake-quic="%~dp0files\quic_initial_www_google_com.bin" --new ^
--filter-udp=19294-19344,50000-50100 --filter-l7=discord,stun --dpi-desync=fake --dpi-desync-fake-discord="%~dp0files\ACTIVE_DISCORD_UDP.bin" --dpi-desync-fake-stun="%~dp0files\ACTIVE_DISCORD_UDP.bin" --dpi-desync-repeats=6 --new ^
--filter-tcp=2053,2083,2087,2096,8443 --hostlist-domains=discord.media --dpi-desync=fake,fakedsplit --dpi-desync-repeats=6 --dpi-desync-fooling=ts --dpi-desync-fakedsplit-pattern=0x00 --dpi-desync-fake-tls="%~dp0files\tls_clienthello_www_google_com.bin" --new ^
--filter-tcp=443 --hostlist="%~dp0files\list-google.txt" --ip-id=zero --dpi-desync=fake,fakedsplit --dpi-desync-repeats=6 --dpi-desync-fooling=ts --dpi-desync-fakedsplit-pattern=0x00 --dpi-desync-fake-tls="%~dp0files\tls_clienthello_www_google_com.bin" --new ^
--filter-tcp=80,443 --hostlist="%~dp0files\list-general.txt" --hostlist-exclude="%~dp0files\list-exclude.txt" --ipset-exclude="%~dp0files\ipset-exclude.txt" --dpi-desync=fake,fakedsplit --dpi-desync-repeats=6 --dpi-desync-fooling=ts --dpi-desync-fakedsplit-pattern=0x00 --dpi-desync-fake-tls="%~dp0files\stun.bin" --dpi-desync-fake-tls="%~dp0files\tls_clienthello_www_google_com.bin" --dpi-desync-fake-http="%~dp0files\tls_clienthello_max_ru.bin" --new ^
--filter-udp=443 --ipset="%~dp0files\ipset-general.txt" --hostlist-exclude="%~dp0files\list-exclude.txt" --ipset-exclude="%~dp0files\ipset-exclude.txt" --dpi-desync=fake --dpi-desync-repeats=6 --dpi-desync-fake-quic="%~dp0files\quic_initial_www_google_com.bin" --new ^
--filter-tcp=80,443,8443 --ipset="%~dp0files\ipset-general.txt" --hostlist-exclude="%~dp0files\list-exclude.txt" --ipset-exclude="%~dp0files\ipset-exclude.txt" --dpi-desync=fake,fakedsplit --dpi-desync-repeats=6 --dpi-desync-fooling=ts --dpi-desync-fakedsplit-pattern=0x00 --dpi-desync-fake-tls="%~dp0files\stun.bin" --dpi-desync-fake-tls="%~dp0files\tls_clienthello_www_google_com.bin" --dpi-desync-fake-http="%~dp0files\tls_clienthello_max_ru.bin" --new ^
--filter-tcp=%GameFilterTCP% --ipset="%~dp0files\ipset-general.txt" --ipset-exclude="%~dp0files\ipset-exclude.txt" --dpi-desync=fake,fakedsplit --dpi-desync-repeats=6 --dpi-desync-any-protocol=1 --dpi-desync-cutoff=n4 --dpi-desync-fooling=ts --dpi-desync-fakedsplit-pattern=0x00 --dpi-desync-fake-tls="%~dp0files\stun.bin" --dpi-desync-fake-tls="%~dp0files\tls_clienthello_www_google_com.bin" --dpi-desync-fake-http="%~dp0files\tls_clienthello_max_ru.bin" --dpi-desync-fake-unknown="%~dp0files\stun.bin" --dpi-desync-fake-unknown="%~dp0files\tls_clienthello_www_google_com.bin" --new ^
--filter-udp=%GameFilterUDP% --ipset="%~dp0files\ipset-general.txt" --ipset-exclude="%~dp0files\ipset-exclude.txt" --dpi-desync=fake --dpi-desync-repeats=12 --dpi-desync-any-protocol=1 --dpi-desync-fake-unknown-udp="%~dp0files\ACTIVE_GAME_UDP.bin" --dpi-desync-cutoff=n3
exit /b
