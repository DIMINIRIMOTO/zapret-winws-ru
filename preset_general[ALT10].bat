@echo off
:: 0
chcp 65001 > nul
::ADMIN(NEW)
net session >nul 2>&1
if %errorlevel% neq 0 (
echo RUN THIS FILE AS ADMIN.
pause
exit /b
)
::LOAD
cd /d "%~dp0"
:: MENU
:menu
echo ==========================================
echo 1. START ZAPRET
echo 2. INSTALL SERVICE
echo 3. EXIT
echo ==========================================
set /p choice=SELECT OPTIONS (1-3):
:: SELECT
if "%choice%"=="1" goto run
if "%choice%"=="2" goto install
if "%choice%"=="3" goto exit
echo:
pause
goto menu
:: INSTALL SERVICE
:install
echo ZAPRET SERVICE CREATE
call universal.bat zapret_set_ts
call universal.bat load_game_filter
echo:
set BIN_PATH=%~dp0bins\
set ARGS=^
--wf-tcp=80,443,2053,2083,2087,2096,8443,%GameFilterTCP% --wf-udp=443,19294-19344,50000-50032,%GameFilterUDP% ^
--filter-udp=443 --hostlist="%~dp0files\list-general.txt" --hostlist-exclude="%~dp0files\list-exclude.txt" --ipset-exclude="%~dp0files\ipset-exclude.txt" --dpi-desync=fake --dpi-desync-repeats=6 --dpi-desync-fake-quic="%~dp0files\quic_initial_www_google_com.bin" --new ^
--filter-udp=19294-19344,50000-50032 --filter-l7=discord,stun --dpi-desync=fake --dpi-desync-fake-discord="%~dp0files\quic_initial_dbankcloud_ru.bin" --dpi-desync-fake-stun="%~dp0files\quic_initial_dbankcloud_ru.bin" --dpi-desync-repeats=6 --new ^
--filter-tcp=2053,2083,2087,2096,8443 --hostlist-domains=discord.media --dpi-desync=fake --dpi-desync-repeats=6 --dpi-desync-fooling=ts --dpi-desync-fake-tls="%~dp0files\tls_clienthello_www_google_com.bin" --dpi-desync-fake-tls-mod=none --new ^
--filter-tcp=443 --hostlist="%~dp0files\list-google.txt" --ip-id=zero --dpi-desync=fake --dpi-desync-repeats=6 --dpi-desync-fooling=ts --dpi-desync-fake-tls="%~dp0files\tls_clienthello_www_google_com.bin" --new ^
--filter-tcp=80,443 --hostlist="%~dp0files\list-general.txt" --hostlist-exclude="%~dp0files\list-exclude.txt" --ipset-exclude="%~dp0files\ipset-exclude.txt" --dpi-desync=fake --dpi-desync-repeats=6 --dpi-desync-fooling=ts --dpi-desync-fake-tls="%~dp0files\stun.bin" --dpi-desync-fake-tls="%~dp0files\tls_clienthello_4pda_to.bin" --dpi-desync-fake-http="%~dp0files\tls_clienthello_max_ru.bin" --new ^
--filter-udp=443 --ipset="%~dp0files\ipset-general.txt" --hostlist-exclude="%~dp0files\list-exclude.txt" --ipset-exclude="%~dp0files\ipset-exclude.txt" --dpi-desync=fake --dpi-desync-repeats=6 --dpi-desync-fake-quic="%~dp0files\quic_initial_www_google_com.bin" --new ^
--filter-tcp=80,443,8443 --ipset="%~dp0files\ipset-general.txt" --hostlist-exclude="%~dp0files\list-exclude.txt" --ipset-exclude="%~dp0files\ipset-exclude.txt" --dpi-desync=fake --dpi-desync-repeats=6 --dpi-desync-fooling=ts --dpi-desync-fake-tls="%~dp0files\stun.bin" --dpi-desync-fake-tls="%~dp0files\tls_clienthello_4pda_to.bin" --dpi-desync-fake-http="%~dp0files\tls_clienthello_max_ru.bin" --new ^
--filter-tcp=%GameFilterTCP% --ipset="%~dp0files\ipset-general.txt" --ipset-exclude="%~dp0files\ipset-exclude.txt" --dpi-desync=fake --dpi-desync-repeats=6 --dpi-desync-any-protocol=1 --dpi-desync-cutoff=n3 --dpi-desync-fooling=ts --dpi-desync-fake-tls="%~dp0files\stun.bin" --dpi-desync-fake-tls="%~dp0files\tls_clienthello_4pda_to.bin" --dpi-desync-fake-http="%~dp0files\tls_clienthello_max_ru.bin" --new ^
--filter-udp=%GameFilterUDP% --ipset="%~dp0files\ipset-general.txt" --ipset-exclude="%~dp0files\ipset-exclude.txt" --dpi-desync=fake --dpi-desync-repeats=12 --dpi-desync-any-protocol=1 --dpi-desync-fake-unknown-udp="%~dp0files\quic_initial_dbankcloud_ru.bin" --dpi-desync-cutoff=n2
sc create "zapret" binPath= "\"%BIN_PATH%winws.exe\" %ARGS%" DisplayName= "zapret DPI bypass : winws1" start= auto
sc description "zapret" "zapret DPI bypass software"
sc start "zapret"
pause
exit /b
::ZAPRET START
:run
call universal.bat zapret_set_ts
call universal.bat load_game_filter
echo:
set BIN=%~dp0bins\
start "zapret: http,https,quic" /min "%BIN%winws.exe" ^
--wf-tcp=80,443,2053,2083,2087,2096,8443,%GameFilterTCP% --wf-udp=443,19294-19344,50000-50032,%GameFilterUDP% ^
--filter-udp=443 --hostlist="%~dp0files\list-general.txt" --hostlist-exclude="%~dp0files\list-exclude.txt" --ipset-exclude="%~dp0files\ipset-exclude.txt" --dpi-desync=fake --dpi-desync-repeats=6 --dpi-desync-fake-quic="%~dp0files\quic_initial_www_google_com.bin" --new ^
--filter-udp=19294-19344,50000-50032 --filter-l7=discord,stun --dpi-desync=fake --dpi-desync-fake-discord="%~dp0files\quic_initial_dbankcloud_ru.bin" --dpi-desync-fake-stun="%~dp0files\quic_initial_dbankcloud_ru.bin" --dpi-desync-repeats=6 --new ^
--filter-tcp=2053,2083,2087,2096,8443 --hostlist-domains=discord.media --dpi-desync=fake --dpi-desync-repeats=6 --dpi-desync-fooling=ts --dpi-desync-fake-tls="%~dp0files\tls_clienthello_www_google_com.bin" --dpi-desync-fake-tls-mod=none --new ^
--filter-tcp=443 --hostlist="%~dp0files\list-google.txt" --ip-id=zero --dpi-desync=fake --dpi-desync-repeats=6 --dpi-desync-fooling=ts --dpi-desync-fake-tls="%~dp0files\tls_clienthello_www_google_com.bin" --new ^
--filter-tcp=80,443 --hostlist="%~dp0files\list-general.txt" --hostlist-exclude="%~dp0files\list-exclude.txt" --ipset-exclude="%~dp0files\ipset-exclude.txt" --dpi-desync=fake --dpi-desync-repeats=6 --dpi-desync-fooling=ts --dpi-desync-fake-tls="%~dp0files\stun.bin" --dpi-desync-fake-tls="%~dp0files\tls_clienthello_4pda_to.bin" --dpi-desync-fake-http="%~dp0files\tls_clienthello_max_ru.bin" --new ^
--filter-udp=443 --ipset="%~dp0files\ipset-general.txt" --hostlist-exclude="%~dp0files\list-exclude.txt" --ipset-exclude="%~dp0files\ipset-exclude.txt" --dpi-desync=fake --dpi-desync-repeats=6 --dpi-desync-fake-quic="%~dp0files\quic_initial_www_google_com.bin" --new ^
--filter-tcp=80,443,8443 --ipset="%~dp0files\ipset-general.txt" --hostlist-exclude="%~dp0files\list-exclude.txt" --ipset-exclude="%~dp0files\ipset-exclude.txt" --dpi-desync=fake --dpi-desync-repeats=6 --dpi-desync-fooling=ts --dpi-desync-fake-tls="%~dp0files\stun.bin" --dpi-desync-fake-tls="%~dp0files\tls_clienthello_4pda_to.bin" --dpi-desync-fake-http="%~dp0files\tls_clienthello_max_ru.bin" --new ^
--filter-tcp=%GameFilterTCP% --ipset="%~dp0files\ipset-general.txt" --ipset-exclude="%~dp0files\ipset-exclude.txt" --dpi-desync=fake --dpi-desync-repeats=6 --dpi-desync-any-protocol=1 --dpi-desync-cutoff=n3 --dpi-desync-fooling=ts --dpi-desync-fake-tls="%~dp0files\stun.bin" --dpi-desync-fake-tls="%~dp0files\tls_clienthello_4pda_to.bin" --dpi-desync-fake-http="%~dp0files\tls_clienthello_max_ru.bin" --new ^
--filter-udp=%GameFilterUDP% --ipset="%~dp0files\ipset-general.txt" --ipset-exclude="%~dp0files\ipset-exclude.txt" --dpi-desync=fake --dpi-desync-repeats=12 --dpi-desync-any-protocol=1 --dpi-desync-fake-unknown-udp="%~dp0files\quic_initial_dbankcloud_ru.bin" --dpi-desync-cutoff=n2
exit /b

::FINAL
:exit
echo GOOD LUCK
pause
exit
