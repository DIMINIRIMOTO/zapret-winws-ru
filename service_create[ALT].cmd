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
--wf-tcp=443 --wf-udp=443,50000-50099 ^
--filter-udp=443 --hostlist="%~dp0files\list-general.txt" --dpi-desync=fake --dpi-desync-repeats=6 --dpi-desync-fake-quic="%~dp0files\quic_initial_www_google_com.bin" --new ^
--filter-tcp=443 --hostlist="%~dp0files\list-general.txt" --dpi-desync=fake,fakedsplit --dpi-desync-repeats=6 --dpi-desync-fooling=badseq --dpi-desync-fake-tls-mod=none --new ^
--filter-udp=50000-50099 --filter-l7=discord,stun --dpi-desync=fake --dpi-desync-repeats=6

sc create "ZapretService" binPath= "\"%BIN_PATH%winws.exe\" %ARGS%" DisplayName= "ZapretService" start= auto
sc description "ZapretService" "ZapretService"
sc start "ZapretService"

pause
