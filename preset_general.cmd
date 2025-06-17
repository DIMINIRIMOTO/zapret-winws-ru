cd /d "%~dp0"
set BIN=%~dp0bins\

start "zapret: http,https,quic" /min "%BIN%winws.exe" ^
--wf-tcp=80,443,444-65535 --wf-udp=443,444-65535,50000-50099 ^
--filter-udp=443 --hostlist="%~dp0files\list-general.txt" --dpi-desync=fake --dpi-desync-repeats=6 --dpi-desync-fake-quic="%~dp0files\quic_initial_www_google_com.bin" --new ^
--filter-tcp=80 --hostlist="%~dp0files\list-general.txt" --dpi-desync=fake,split2 --dpi-desync-autottl=2 --dpi-desync-fooling=md5sig --new ^
--filter-tcp=443 --hostlist="%~dp0files\list-general.txt" --dpi-desync=split2 --dpi-desync-split-seqovl=681 --dpi-desync-split-pos=2 --dpi-desync-split-seqovl-pattern="%~dp0files\tls_clienthello_www_google_com.bin" --new ^
--filter-udp=443 --ipset="%~dp0files\ipset-general.txt" --dpi-desync=fake --dpi-desync-repeats=6 --dpi-desync-fake-quic="%~dp0files\quic_initial_www_google_com.bin" --new ^
--filter-tcp=80 --ipset="%~dp0files\ipset-general.txt" --dpi-desync=fake,split2 --dpi-desync-autottl=2 --dpi-desync-fooling=md5sig --new ^
--filter-tcp=443 --ipset="%~dp0files\ipset-general.txt" --dpi-desync=split2 --dpi-desync-split-seqovl=681 --dpi-desync-split-pos=2 --dpi-desync-split-seqovl-pattern="%~dp0files\tls_clienthello_www_google_com.bin" --new ^
--filter-udp=444-65535 --ipset="%LISTS%ipset-all.txt" --dpi-desync-ttl=8 --dpi-desync-repeats=20 --dpi-desync-fooling=none --dpi-desync-any-protocol=1 --dpi-desync-fake-unknown-udp="%BIN%quic_initial_www_google_com.bin" --dpi-desync=fake --dpi-desync-cutoff=n10 --new ^
--filter-udp=50000-50099 --filter-l7=discord,stun --dpi-desync=fake --dpi-desync-repeats=6
