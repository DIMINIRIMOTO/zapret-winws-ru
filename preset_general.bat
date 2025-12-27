@echo off
:: 0
chcp 65001 > nul
::LOAD
cd /d "%~dp0"
:: MENU
:menu
echo ==========================================
echo 1. START ZAPRET
echo 2. INSTAL SERVICE
echo 3. EXIT
echo ==========================================
set /p choice=ENTER CHOICE (1-3):
:: SELECT
if "%choice%"=="1" goto run
if "%choice%"=="2" goto install
if "%choice%"=="3" goto exit
echo 
pause
goto menu
:: INSTALL SERVICE
:install
echo ZAPRET SERVICE CREATE
call universal.bat load_game_filter
echo:
set BIN_PATH=%~dp0bins\
set ARGS=^
--wf-tcp=80,443,2053,2083,2087,2096,8443,%GameFilter% --wf-udp=443,19294-19344,50000-50099,%GameFilter% ^
--filter-udp=443 --hostlist="%~dp0files\list-general.txt" --hostlist-exclude="%~dp0files\list-exclude.txt" --ipset-exclude="%~dp0files\ipset-exclude.txt" --dpi-desync=fake --dpi-desync-repeats=6 --dpi-desync-fake-quic="%~dp0files\quic_initial_www_google_com.bin" --new ^
--filter-udp=19294-19344,50000-50099 --filter-l7=discord,stun --dpi-desync=fake --dpi-desync-repeats=6 --new ^
--filter-tcp=2053,2083,2087,2096,8443 --hostlist-domains=discord.media --dpi-desync=fake --dpi-desync-repeats=6 --dpi-desync-fooling=ts --dpi-desync-fake-tls="%~dp0files\tls_clienthello_max_ru.bin" --new ^
--filter-tcp=443 --hostlist="%~dp0files\list-youtube.txt" --ip-id=zero --dpi-desync=fake --dpi-desync-repeats=6 --dpi-desync-fooling=ts --dpi-desync-fake-tls="%~dp0files\tls_clienthello_www_google_com.bin" --new ^
--filter-tcp=80,443 --hostlist="%~dp0files\list-general.txt" --hostlist-exclude="%~dp0files\list-exclude.txt" --ipset-exclude="%~dp0files\ipset-exclude.txt" --dpi-desync=fake --dpi-desync-repeats=6 --dpi-desync-fooling=ts --dpi-desync-fake-tls="%~dp0files\tls_clienthello_max_ru.bin" --new ^
--filter-udp=443 --ipset="%~dp0files\ipset-general.txt" --hostlist-exclude="%~dp0files\list-exclude.txt" --ipset-exclude="%~dp0files\ipset-exclude.txt" --dpi-desync=fake --dpi-desync-repeats=6 --dpi-desync-fake-quic="%~dp0files\quic_initial_www_google_com.bin" --new ^
--filter-tcp=80,443,%GameFilter% --ipset="%~dp0files\ipset-general.txt" --hostlist-exclude="%~dp0files\list-exclude.txt" --ipset-exclude="%~dp0files\ipset-exclude.txt" --dpi-desync=fake --dpi-desync-repeats=6 --dpi-desync-fooling=ts --dpi-desync-fake-tls="%~dp0files\tls_clienthello_max_ru.bin" --new ^
--filter-udp=%GameFilter% --ipset="%~dp0files\ipset-general.txt" --ipset-exclude="%~dp0files\ipset-exclude.txt" --dpi-desync=fake --dpi-desync-autottl=2 --dpi-desync-repeats=12 --dpi-desync-any-protocol=1 --dpi-desync-fake-unknown-udp="%~dp0files\quic_initial_www_google_com.bin" --dpi-desync-cutoff=n3
sc create "zapret" binPath= "\"%BIN_PATH%winws.exe\" %ARGS%" DisplayName= "zapret DPI bypass : winws1" start= auto
sc description "zapret" "zapret DPI bypass software"
sc start "zapret"
pause
exit /b
::ZAPRET START
:run
call universal.bat load_game_filter
echo:
set BIN=%~dp0bins\
start "zapret: http,https,quic" /min "%BIN%winws.exe" ^
--wf-tcp=80,443,2053,2083,2087,2096,8443,%GameFilter% --wf-udp=443,19294-19344,50000-50099,%GameFilter% ^
--filter-udp=443 --hostlist="%~dp0files\list-general.txt" --hostlist-exclude="%~dp0files\list-exclude.txt" --ipset-exclude="%~dp0files\ipset-exclude.txt" --dpi-desync=fake --dpi-desync-repeats=6 --dpi-desync-fake-quic="%~dp0files\quic_initial_www_google_com.bin" --new ^
--filter-udp=19294-19344,50000-50099 --filter-l7=discord,stun --dpi-desync=fake --dpi-desync-repeats=6 --new ^
--filter-tcp=2053,2083,2087,2096,8443 --hostlist-domains=discord.media --dpi-desync=fake --dpi-desync-repeats=6 --dpi-desync-fooling=ts --dpi-desync-fake-tls="%~dp0files\tls_clienthello_max_ru.bin" --new ^
--filter-tcp=443 --hostlist="%~dp0files\list-youtube.txt" --ip-id=zero --dpi-desync=fake --dpi-desync-repeats=6 --dpi-desync-fooling=ts --dpi-desync-fake-tls="%~dp0files\tls_clienthello_www_google_com.bin" --new ^
--filter-tcp=80,443 --hostlist="%~dp0files\list-general.txt" --hostlist-exclude="%~dp0files\list-exclude.txt" --ipset-exclude="%~dp0files\ipset-exclude.txt" --dpi-desync=fake --dpi-desync-repeats=6 --dpi-desync-fooling=ts --dpi-desync-fake-tls="%~dp0files\tls_clienthello_max_ru.bin" --new ^
--filter-udp=443 --ipset="%~dp0files\ipset-general.txt" --hostlist-exclude="%~dp0files\list-exclude.txt" --ipset-exclude="%~dp0files\ipset-exclude.txt" --dpi-desync=fake --dpi-desync-repeats=6 --dpi-desync-fake-quic="%~dp0files\quic_initial_www_google_com.bin" --new ^
--filter-tcp=80,443,%GameFilter% --ipset="%~dp0files\ipset-general.txt" --hostlist-exclude="%~dp0files\list-exclude.txt" --ipset-exclude="%~dp0files\ipset-exclude.txt" --dpi-desync=fake --dpi-desync-repeats=6 --dpi-desync-fooling=ts --dpi-desync-fake-tls="%~dp0files\tls_clienthello_max_ru.bin" --new ^
--filter-udp=%GameFilter% --ipset="%~dp0files\ipset-general.txt" --ipset-exclude="%~dp0files\ipset-exclude.txt" --dpi-desync=fake --dpi-desync-autottl=2 --dpi-desync-repeats=12 --dpi-desync-any-protocol=1 --dpi-desync-fake-unknown-udp="%~dp0files\quic_initial_www_google_com.bin" --dpi-desync-cutoff=n3
exit /b

::FINAL
:exit
echo GOOD LUCK
pause
exit
