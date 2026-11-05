@echo off
setlocal
set "PS_URL=https://raw.githubusercontent.com/reasonaryai/rai-code/main/install.ps1"
if not defined TEMP set "TEMP=%LOCALAPPDATA%\Temp"
if not exist "%TEMP%" mkdir "%TEMP%" 2>nul
set "PS_FILE=%TEMP%\rai-install-%RANDOM%.ps1"
rem Run from the user profile. A protected working directory (for example
rem C:\Windows\System32) must never influence relative paths used by the
rem installer or the tools it starts.
pushd "%USERPROFILE%" 2>nul || pushd "%TEMP%"
powershell -NoProfile -ExecutionPolicy Bypass -Command "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; (New-Object Net.WebClient).DownloadFile('%PS_URL%', '%PS_FILE%'); & '%PS_FILE%'"
set "RAI_INSTALL_EXIT=%ERRORLEVEL%"
popd
del "%PS_FILE%" 2>nul
endlocal & exit /b %RAI_INSTALL_EXIT%
