@echo off
setlocal
set "PS_URL=https://raw.githubusercontent.com/reasonaryai/rai-code/main/install.ps1"
if not defined LOCALAPPDATA set "LOCALAPPDATA=%USERPROFILE%\AppData\Local"
if not defined TEMP set "TEMP=%LOCALAPPDATA%\Temp"
if not exist "%TEMP%\" mkdir "%TEMP%" 2>nul
set "PS_FILE=%TEMP%\rai-install-%RANDOM%.ps1"
rem Run from a writable directory so a protected working directory (for example
rem C:\Windows\System32) cannot influence relative paths used by the installer
rem or the tools it starts. Tracked with an if-test rather than "||" because an
rem internal command's ERRORLEVEL is not a reliable success signal here.
set "RAI_PUSHD="
if exist "%USERPROFILE%\" (
  pushd "%USERPROFILE%" 2>nul && set "RAI_PUSHD=1"
)
if not defined RAI_PUSHD if exist "%TEMP%\" (
  pushd "%TEMP%" 2>nul && set "RAI_PUSHD=1"
)
powershell -NoProfile -ExecutionPolicy Bypass -Command "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; (New-Object Net.WebClient).DownloadFile('%PS_URL%', '%PS_FILE%'); & '%PS_FILE%'"
set "RAI_INSTALL_EXIT=%ERRORLEVEL%"
if defined RAI_PUSHD popd
del "%PS_FILE%" 2>nul
endlocal & exit /b %RAI_INSTALL_EXIT%
