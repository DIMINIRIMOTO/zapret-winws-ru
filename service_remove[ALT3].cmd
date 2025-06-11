@echo off

set SRVCNAME=ZapretService3

net stop "%SRVCNAME%"
sc delete "%SRVCNAME%"

pause