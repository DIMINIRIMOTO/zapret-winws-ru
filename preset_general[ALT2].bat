@echo off
::UTF-8
chcp 65001 > nul
::LOAD DIRECTORY
cd /d "%~dp0"
::LOAD FILTER
call universal.bat load_game_filter
::CLEAR CMD
echo:
::STARTUP
set BIN=%~dp0bins\
start "zapret: http,https,quic" /min "%BIN%winws.exe" ^
::PARAMETRS
--wf-tcp=80,443,%GameFilter% --wf-udp=443,50000-50099,%GameFilter% ^
--filter-udp=443 --hostlist="%~dp0files\list-general.txt" --dpi-desync=fake --dpi-desync-repeats=6 --dpi-desync-fake-quic="%~dp0files\quic_initial_www_google_com.bin" --new ^
--filter-udp=50000-50099 --filter-l7=discord,stun --dpi-desync=fake --dpi-desync-repeats=6 --new ^
--filter-tcp=80 --hostlist="%~dp0files\list-general.txt" --dpi-desync=fake,split2 --dpi-desync-autottl=2 --dpi-desync-fooling=badseq --dpi-desync-badseq-increment=2 --new ^
--filter-tcp=443 --hostlist="%~dp0files\list-general.txt" --dpi-desync=fake --dpi-desync-fake-tls-mod=none --dpi-desync-repeats=6 --dpi-desync-fooling=badseq --dpi-desync-badseq-increment=2 --new ^
--filter-udp=443 --ipset="%~dp0files\ipset-general.txt" --dpi-desync=fake --dpi-desync-repeats=6 --dpi-desync-fake-quic="%~dp0files\quic_initial_www_google_com.bin" --new ^
--filter-tcp=80 --ipset="%~dp0files\ipset-general.txt" --dpi-desync=fake,split2 --dpi-desync-autottl=2 --dpi-desync-fooling=badseq --dpi-desync-badseq-increment=2 --new ^
--filter-tcp=443,%GameFilter% --ipset="%~dp0files\ipset-general.txt" --dpi-desync=syndata --new ^
--filter-udp=%GameFilter% --ipset="%~dp0files\ipset-general.txt" --dpi-desync=fake --dpi-desync-autottl=2 --dpi-desync-repeats=12 --dpi-desync-any-protocol=1 --dpi-desync-fake-unknown-udp="%~dp0files\quic_initial_www_google_com.bin" --dpi-desync-cutoff=n2
::END