cd /d "%~dp0"
set BIN=%~dp0bins\

start "zapret: http,https,quic" /min "%BIN%winws.exe" ^
--wf-tcp=443 --wf-udp=443,50000-50099 ^
--filter-udp=443 --hostlist="%~dp0files\list-general.txt" --dpi-desync=fake --dpi-desync-repeats=6 --dpi-desync-fake-quic="%~dp0files\quic_initial_www_google_com.bin" --new ^
--filter-udp=50000-50099 --filter-l7=discord,stun --dpi-desync=fake --dpi-desync-repeats=6 --new ^
--filter-tcp=443 --hostlist="%~dp0files\list-general.txt" --dpi-desync=split --dpi-desync-split-pos=1 --dpi-desync-autottl --dpi-desync-fooling=badseq --dpi-desync-repeats=8