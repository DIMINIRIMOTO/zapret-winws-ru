@echo off

cd /d "%~dp0"
set BIN_PATH=%~dp0bins\

set ARGS=^
--wf-tcp=80,443 --wf-udp=443,50000-50099 ^
--wf-tcp=80,443 --wf-udp=443,50000-50099 ^
--filter-udp=443 --hostlist="%~dp0files\list-general.txt" --dpi-desync=fake --dpi-desync-repeats=6 --dpi-desync-fake-quic="%~dp0files\quic_initial_www_google_com.bin" --new ^
--filter-tcp=80 --hostlist="%~dp0files\list-general.txt" --dpi-desync=fake,split2 --dpi-desync-autottl=2 --dpi-desync-fooling=md5sig --new ^
--filter-tcp=443 --hostlist="%~dp0files\list-general.txt" --dpi-desync=split2 --dpi-desync-split-seqovl=681 --dpi-desync-split-pos=2 --dpi-desync-split-seqovl-pattern="%~dp0files\tls_clienthello_www_google_com.bin" --new ^
--filter-udp=50000-50099 --filter-l7=discord,stun --dpi-desync=fake --dpi-desync-repeats=6

set SRVCNAME=zapret

net stop "%SRVCNAME%"
sc delete "%SRVCNAME%"
sc create "%SRVCNAME%" binPath= "\"%BIN_PATH%winws.exe\" %ARGS%" DisplayName= "zapret DPI bypass : winws1" start= auto
sc description "%SRVCNAME%" "zapret DPI bypass software"
sc start "%SRVCNAME%"

pause
