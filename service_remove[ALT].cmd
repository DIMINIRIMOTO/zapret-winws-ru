@echo off

set SRVCNAME=ZapretService

net stop "%SRVCNAME%"
sc delete "%SRVCNAME%"

pause
