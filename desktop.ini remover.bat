@echo off
setlocal EnableDelayedExpansion

:: Set success flag
set "found=0"
set "error=0"

:: Set startup paths
set "userStartup=%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup\desktop.ini"
set "commonStartup=%ProgramData%\Microsoft\Windows\Start Menu\Programs\Startup\desktop.ini"

:: Function to check and delete file
call :check_delete "%userStartup%"
call :check_delete "%commonStartup%"

:: Check registry Run keys
for %%A in ("HKCU\Software\Microsoft\Windows\CurrentVersion\Run" ^
            "HKLM\Software\Microsoft\Windows\CurrentVersion\Run") do (
    for /f "tokens=*" %%B in ('reg query %%A 2^>nul') do (
        reg query %%A /v "desktop.ini" >nul 2>&1
        if not errorlevel 1 (
            reg delete %%A /v "desktop.ini" /f >nul 2>&1
            if errorlevel 1 (
                set "error=1"
            ) else (
                set "found=1"
            )
        )
    )
)

:: Show result in a Message Box
if "!error!"=="1" (
    powershell -Command "Add-Type -AssemblyName PresentationFramework;[System.Windows.MessageBox]::Show('Operation failed. Could not delete all desktop.ini entries.','Error',[System.Windows.MessageBoxButton]::OK,[System.Windows.MessageBoxImage]::Error)"
    exit /b
)

if "!found!"=="1" (
    powershell -Command "Add-Type -AssemblyName PresentationFramework;[System.Windows.MessageBox]::Show('desktop.ini files found and deleted from startup locations.','Success',[System.Windows.MessageBoxButton]::OK,[System.Windows.MessageBoxImage]::Information)"
) else (
    powershell -Command "Add-Type -AssemblyName PresentationFramework;[System.Windows.MessageBox]::Show('No desktop.ini files found in startup locations.','Info',[System.Windows.MessageBoxButton]::OK,[System.Windows.MessageBoxImage]::Information)"
)

exit /b

:: Function: check_delete
:check_delete
set "filePath=%~1"
if exist "%filePath%" (
    del /f /q "%filePath%" >nul 2>&1
    if errorlevel 1 (
        set "error=1"
    ) else (
        set "found=1"
    )
)
exit /b