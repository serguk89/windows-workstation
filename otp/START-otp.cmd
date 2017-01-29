@echo off
::
:: Browser appliance.
::
:: AUTHOR       :Viktor Szépe <viktor@szepe.net>
:: INSTALLER    :https://www.mozilla.org/en-US/firefox/organizations/all/
:: DEPENDS      :7za.exe from 7z*-extra.7z in http://sourceforge.net/projects/sevenzip/files/7-Zip/
:: DEPENDS      :wget.exe https://eternallybored.org/misc/wget/ https://github.com/szepeviktor/windows-workstation#wget
:: EXTRA_PREF   :user_pref("security.tls.version.min", 3);

set HOME_URL="https://www.otpbank.hu/portal/hu/OTPdirekt/Belepes"
set SETUP_URL="https://download.mozilla.org/?product=firefox-45.6.0esr-SSL&os=win64&lang=hu"

:: Make sure we are in batch file's directory
cd /D %~dp0
call :Exit_if_running "%CD%"

:: Download installer
title Checking/downloading installer ...
if NOT EXIST .\"Firefox Setup"*.exe wget -nv --content-disposition %SETUP_URL%
7za l -y .\"Firefox Setup"*.exe > NUL || (
    del /Q .\"Firefox Setup"*.exe
    wget -nv --content-disposition %SETUP_URL%
    7za l -y .\"Firefox Setup"*.exe > NUL || exit 2
)

:: Show the current directory in window title
title %CD%

:: Unpack installer - Don't use ".\core\"
7za x -y .\"Firefox Setup"*.exe "core\"
:: Prevent pending updates
rmdir /Q /S %LOCALAPPDATA%\Mozilla\Firefox\firefox\updates\ > NUL 2>&1
set PROFILEDIR=".\data"
mkdir %PROFILEDIR%

:: Remove built-in certificates
del /Q .\core\nssckbi.dll

:: Premade certificate and key databases
if EXIST .\certdbs\cert8.db if EXIST .\certdbs\key3.db if EXIST .\certdbs\secmod.db (
    copy /Y .\certdbs\cert8.db %PROFILEDIR%\cert8.db
    copy /Y .\certdbs\key3.db %PROFILEDIR%\key3.db
    copy /Y .\certdbs\secmod.db %PROFILEDIR%\secmod.db
)

:: Settings
if EXIST .\user.js copy /Y .\user.js %PROFILEDIR%\ > NUL

:: Start Firefox
title %CD% - Started
start /WAIT .\core\firefox.exe -safe-mode -no-remote -profile %PROFILEDIR% %HOME_URL%

:: Remove Firefox
rmdir /S /Q %PROFILEDIR%
rmdir /S /Q .\core\

exit /B 0

:Exit_if_running
wmic process where "name='firefox.exe'" get ExecutablePath /format:list 2> NUL | find /I "%~1\core\firefox.exe" > NUL
if NOT ERRORLEVEL 1 exit 1
goto :EOF
