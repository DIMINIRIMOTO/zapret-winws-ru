@echo off

set SRVCNAME=ZapretService2

net stop "%SRVCNAME%"
sc delete "%SRVCNAME%"

pause