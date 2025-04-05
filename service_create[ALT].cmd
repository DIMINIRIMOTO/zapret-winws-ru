@echo off
pushd "%~dp0"

sc query ZapretService >nul 2>&1
IF %ERRORLEVEL% EQU 0 (
    sc stop "ZapretService"
    sc delete "ZapretService"
)
chcp 1251 > nul

cd /d "%~dp0"
set BIN_PATH=%~dp0bins\

set ARGS=^
--wf-tcp=80,443 --wf-udp=443,50000-50099 ^
--filter-udp=443 --hostlist=\"%~dp0files\list-general.txt\" --dpi-desync=fake --dpi-desync-repeats=6 --dpi-desync-fake-quic="%~dp0files\quic_initial_www_google_com.bin" --new ^
--filter-udp=50000-50099 --ipset=\"%~dp0files\ipset-discord.txt\" --dpi-desync=fake --dpi-desync-any-protocol --dpi-desync-cutoff=d3 --dpi-desync-repeats=6 --new ^
--filter-tcp=80 --hostlist=\"%~dp0files\list-general.txt\" --dpi-desync=fake,split2 --dpi-desync-autottl=2 --dpi-desync-fooling=md5sig --new ^
--filter-tcp=443 --hostlist=\"%~dp0files\list-general.txt\" --dpi-desync=fake --dpi-desync-fooling=md5sig --dpi-desync-fake-tls-mod=rnd,rndsni,padencap

sc create "ZapretService" binPath= "\"%BIN_PATH%winws.exe\" %ARGS%" DisplayName= "ZapretService" start= auto
sc description "ZapretService" "ZapretService"
sc start "ZapretService"

pause
