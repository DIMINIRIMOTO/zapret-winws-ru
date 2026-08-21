@echo off
chcp 65001 > nul
::ADMIN_USER
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo [Error] Please run this file as Administrator.
    pause
    exit /b
)
::LOAD_DIRECTORY
cd /d "%~dp0"
::START_ZAPRET
call zapret_manager.bat zapret_set_ts
call zapret_manager.bat load_game_filter
echo:
set BIN=%~dp0bins\
cd /d %BIN%
start "zapret: http,https,quic" /min "%BIN%winws.exe" ^
--wf-tcp=80,443,2053,2083,2087,2096,8443,%GameFilterTCP% --wf-udp=443,19294-19344,50000-50100,%GameFilterUDP% ^
--filter-l7=quic --hostlist="%~dp0files\list-general.txt" --hostlist-exclude="%~dp0files\list-exclude.txt" --ipset-exclude="%~dp0files\ipset-exclude.txt" --dpi-desync=fake --dpi-desync-repeats=11 --dpi-desync-fake-quic="%~dp0files\quic_initial_www_google_com.bin" --new ^
--filter-udp=19294-19344,50000-50100 --filter-l7=discord,stun,unknown --dpi-desync=fake --dpi-desync-any-protocol=1 --dpi-desync-fake-discord="%~dp0files\quic_initial_www_google_com.bin" --dpi-desync-fake-discord="%~dp0files\ACTIVE_DISCORD_UDP.bin" --dpi-desync-fake-stun="%~dp0files\ACTIVE_DISCORD_UDP.bin" --dpi-desync-fake-unknown-udp="%~dp0files\quic_initial_www_google_com.bin" --dpi-desync-fake-unknown-udp="%~dp0files\ACTIVE_DISCORD_UDP.bin" --dpi-desync-repeats=4 --new ^
--filter-tcp=2053,2083,2087,2096,8443 --hostlist-domains=discord.media --dpi-desync=fake,multisplit --dpi-desync-split-seqovl=681 --dpi-desync-split-pos=1 --dpi-desync-fooling=ts --dpi-desync-repeats=8 --dpi-desync-split-seqovl-pattern="%~dp0files\tls_clienthello_www_google_com.bin" --dpi-desync-fake-tls="%~dp0files\tls_clienthello_www_google_com.bin" --new ^
--filter-tcp=443 --hostlist="%~dp0files\list-google.txt" --ip-id=zero --dpi-desync=hostfakesplit --dpi-desync-fooling=ts --dpi-desync-hostfakesplit-mod=host=www.google.com --new ^
--filter-tcp=80,443 --hostlist="%~dp0files\list-general.txt" --hostlist-exclude="%~dp0files\list-exclude.txt" --ipset-exclude="%~dp0files\ipset-exclude.txt" --dpi-desync=fake,multisplit --dpi-desync-split-seqovl=480 --dpi-desync-split-pos=1 --dpi-desync-fooling=ts --dpi-desync-repeats=4 --dpi-desync-split-seqovl-pattern="%~dp0files\stun2.bin" --dpi-desync-fake-tls="%~dp0files\tls_clienthello_max_ru.bin" --dpi-desync-fake-http="%~dp0files\tls_clienthello_max_ru.bin" --new ^
--filter-udp=443 --ipset="%~dp0files\ipset-general.txt" --hostlist-exclude="%~dp0files\list-exclude.txt" --ipset-exclude="%~dp0files\ipset-exclude.txt" --dpi-desync=fake --dpi-desync-repeats=11 --dpi-desync-fake-quic="%~dp0files\quic_initial_www_google_com.bin" --new ^
--filter-tcp=80,443,8443 --ipset="%~dp0files\ipset-general.txt" --hostlist-exclude="%~dp0files\list-exclude.txt" --ipset-exclude="%~dp0files\ipset-exclude.txt" --hostlist-exclude-domains=fonts.googleapis.com --dpi-desync=fake,multisplit --dpi-desync-split-seqovl=480 --dpi-desync-split-pos=1 --dpi-desync-fooling=ts --dpi-desync-repeats=4 --dpi-desync-split-seqovl-pattern="%~dp0files\stun2.bin" --dpi-desync-fake-tls="%~dp0files\tls_clienthello_max_ru.bin" --dpi-desync-fake-http="%~dp0files\tls_clienthello_max_ru.bin" --new ^
--filter-tcp=%GameFilterTCP% --ipset="%~dp0files\ipset-general.txt" --ipset-exclude="%~dp0files\ipset-exclude.txt" --dpi-desync=fake,multisplit --dpi-desync-any-protocol=1 --dpi-desync-cutoff=n4 --dpi-desync-split-seqovl=664 --dpi-desync-split-pos=1 --dpi-desync-fooling=ts --dpi-desync-repeats=8 --dpi-desync-split-seqovl-pattern="%~dp0files\tls_clienthello_max_ru.bin" --dpi-desync-fake-tls="%~dp0files\stun2.bin" --dpi-desync-fake-tls="%~dp0files\tls_clienthello_max_ru.bin" --dpi-desync-fake-http="%~dp0files\tls_clienthello_max_ru.bin" --new ^
--filter-udp=%GameFilterUDP% --ipset="%~dp0files\ipset-general.txt" --ipset-exclude="%~dp0files\ipset-exclude.txt" --dpi-desync=fake --dpi-desync-repeats=5 --dpi-desync-any-protocol=1 --dpi-desync-fake-unknown-udp="%~dp0files\quic_initial_4pda_to.bin" --dpi-desync-fake-unknown-udp="%~dp0files\ACTIVE_GAME_UDP.bin" --dpi-desync-cutoff=n4
