@echo off
setlocal
set "PS_URL=https://raw.githubusercontent.com/reasonaryai/rai-code/main/install.ps1"
if not defined LOCALAPPDATA set "LOCALAPPDATA=%USERPROFILE%\AppData\Local"
if not defined TEMP set "TEMP=%LOCALAPPDATA%\Temp"
if not exist "%TEMP%\" mkdir "%TEMP%" 2>nul
set "PS_FILE=%TEMP%\rai-install-%RANDOM%.ps1"
rem The working directory is moved inside the PowerShell process only, so a
rem protected one (for example C:\Windows\System32) cannot affect the installer
rem and the caller's own directory is left untouched.
powershell -NoProfile -ExecutionPolicy Bypass -Command "Set-Location -LiteralPath $env:USERPROFILE; [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; (New-Object Net.WebClient).DownloadFile('%PS_URL%', '%PS_FILE%'); & '%PS_FILE%'"
set "RAI_INSTALL_EXIT=%ERRORLEVEL%"
del "%PS_FILE%" 2>nul
endlocal & exit /b %RAI_INSTALL_EXIT%
