@echo off

set SFEMAIL_NOTIFY=carl.seelye@solidfire.com,randy.hinds@solidfire.com
set SFMVIP=172.25.104.200
set SFSVIP=10.5.5.200
set SFUSERNAME=script_user
set SFPASSWORD=solidfire
set SFIPMI_USER=root
set SFIPMI_PASS=ironclads


for /f %%a in ('"python ..\get_active_nodes.py --mvip=%SFMVIP% --csv"') do set SFNODE_IPS=%%a

echo.
echo The following variables are now available:
set | find "SF" | find /v "PATHEXT"
