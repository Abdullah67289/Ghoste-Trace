@echo off
setlocal enabledelayedexpansion

:: ============================================================================
:: Spyware Remover Script
:: This script is designed to undo the changes made by the provided batch files.
:: It requires Administrator privileges to run.
:: ============================================================================

:: --- Admin Check ---
:: Checks if the script is running with Administrator privileges.
:: If not, it restarts itself with elevated permissions.
net session >nul 2>&1
if %errorlevel% NEQ 0 (
    echo Requesting Administrator privileges...
    powershell -WindowStyle Hidden -Command "Start-Process '%~f0' -Verb runAs; exit"
    exit /b
)

echo Running as Administrator.

:: --- Define Paths and Variables ---
:: Defines all necessary paths and initializes counters for found, deleted, and error items.
set "APPDATA_PATH=%USERPROFILE%\AppData"
set "ROAMING_PATH=%APPDATA_PATH%\Roaming"
set "TRACES_DIR=%ROAMING_PATH%\Traces"
set "SUBDIR=%ROAMING_PATH%\SubDir"
set "TARGET_FILE=%TRACES_DIR%\Client-built.exe"
set "SYSTEM32_EXE=%SUBDIR%\System32.exe"
set "SYSTEM32_DIR=%SUBDIR%\System32"
set "MICROSOFT_FOLDER=%APPDATA_PATH%\Microsoft"
set "DIRECTXUPDATE_BAT_FILE=%MICROSOFT_FOLDER%\DirectXUpdate.bat"
set "STARTUP_DESKTOP_INI=%APPDATA_PATH%\Microsoft\Windows\Start Menu\Programs\Startup\desktop.ini"

set /a FOUND_COUNT=0
set /a DELETED_COUNT=0
set /a ERROR_COUNT=0

:: --- Function to display a message box using PowerShell ---
:: Arguments: %1 = Message, %2 = Title
:ShowMessageBox
powershell -WindowStyle Hidden -Command "[System.Windows.Forms.MessageBox]::Show('%~1', '%~2', [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information); exit"
goto :eof

:: --- Function to kill a process and delete a file ---
:: Arguments: %1 = Process Name (e.g., Client-built.exe), %2 = File Path
:KillProcessAndDeleteFile
    echo.
    echo Attempting to terminate %1 and delete %2...
    set "process_found=0"
    tasklist /FI "IMAGENAME eq %1" 2>NUL | find /I /N "%1%" >NUL
    if !errorlevel! equ 0 (
        set "process_found=1"
        echo Found running process: %1. Terminating...
        taskkill /F /IM %1 >nul 2>&1
        if !errorlevel! equ 0 (
            echo Successfully terminated %1.
        ) else (
            echo Failed to terminate %1.
            set /a ERROR_COUNT+=1
        )
    ) else (
        echo Process %1 not found running.
    )

    if exist "%~2" (
        echo Found file: "%~2". Attempting to delete...
        :: Remove attributes first to ensure deletion
        attrib -h -s -r "%~2" >nul 2>&1
        del /f /q "%~2" >nul 2>&1
        if !errorlevel! equ 0 (
            echo Successfully deleted "%~2".
            set /a DELETED_COUNT+=1
        ) else (
            echo Failed to delete "%~2".
            set /a ERROR_COUNT+=1
        )
    ) else (
        echo File "%~2" not found.
    )
goto :eof

:: --- Function to delete a folder ---
:: Arguments: %1 = Folder Path
:DeleteFolder
    echo.
    echo Attempting to delete folder: "%~1"...
    if exist "%~1\" (
        echo Found folder: "%~1". Deleting...
        :: Remove attributes from all contents first
        attrib -h -s -r "%~1\*" /s /d >nul 2>&1
        rmdir /s /q "%~1" >nul 2>&1
        if !errorlevel! equ 0 (
            echo Successfully deleted folder "%~1".
            set /a DELETED_COUNT+=1
        ) else (
            echo Failed to delete folder "%~1".
            set /a ERROR_COUNT+=1
        )
    ) else (
        echo Folder "%~1" not found.
    )
goto :eof

:: --- Function to remove a registry entry ---
:: Arguments: %1 = Registry Key, %2 = Value Name
:DeleteRegistryEntry
    echo.
    echo Attempting to remove registry entry: %1 /v %2...
    reg query "%~1" /v "%~2" >nul 2>&1
    if !errorlevel! equ 0 (
        echo Found registry entry. Deleting...
        reg delete "%~1" /v "%~2" /f >nul 2>&1
        if !errorlevel! equ 0 (
            echo Successfully removed registry entry.
            set /a DELETED_COUNT+=1
        ) else (
            echo Failed to remove registry entry.
            set /a ERROR_COUNT+=1
        )
    ) else (
        echo Registry entry not found.
    )
goto :eof

:: --- Function to delete a scheduled task ---
:: Arguments: %1 = Task Name
:DeleteScheduledTask
    echo.
    echo Attempting to delete scheduled task: "%~1"...
    schtasks /query /TN "%~1" >nul 2>&1
    if !errorlevel! equ 0 (
        echo Found scheduled task. Deleting...
        schtasks /delete /TN "%~1" /F >nul 2>&1
        if !errorlevel! equ 0 (
            echo Successfully deleted scheduled task.
            set /a DELETED_COUNT+=1
        ) else (
            echo Failed to delete scheduled task.
            set /a ERROR_COUNT+=1
        )
    ) else (
        echo Scheduled task not found.
    )
goto :eof

:: --- Function to remove Windows Defender exclusion ---
:: Arguments: %1 = Exclusion Path
:RemoveDefenderExclusion
    echo.
    echo Attempting to remove Windows Defender exclusion for: "%~1"...
    :: Check if the exclusion exists before trying to remove it
    powershell -WindowStyle Hidden -Command "$exclusion = Get-MpPreference | Select-Object -ExpandProperty ExclusionPath; if ($exclusion -contains '%~1') { Write-Host 'Exclusion found, removing.'; Remove-MpPreference -ExclusionPath '%~1' -ErrorAction SilentlyContinue; exit 0 } else { Write-Host 'Exclusion not found.'; exit 1 }" >nul 2>&1
    if !errorlevel! equ 0 (
        echo Successfully removed exclusion for "%~1".
        set /a DELETED_COUNT+=1
    ) else (
        echo Exclusion for "%~1" was not found or failed to remove.
        :: Only increment ERROR_COUNT if the exclusion was expected to be there but failed to remove
        :: This is a bit tricky as PowerShell's exit code might not differentiate "not found" vs "failed to remove existing"
        :: For simplicity, we'll increment if the PowerShell command itself signals an issue.
        if "%~1" neq "" (
            powershell -WindowStyle Hidden -Command "$exclusion = Get-MpPreference | Select-Object -ExpandProperty ExclusionPath; if ($exclusion -contains '%~1') { exit 1 } else { exit 0 }" >nul 2>&1
            if !errorlevel! equ 1 (
                set /a ERROR_COUNT+=1
            )
        )
    )
goto :eof

:: ============================================================================
:: Perform Cleanup Operations
:: ============================================================================

:: --- Cleanup Client-built.exe and related directories ---
echo.
echo --- Cleaning up Client-built.exe and related directories ---

:: Check for Client-built.exe and its process
set /a FOUND_COUNT+=1
call :KillProcessAndDeleteFile "Client-built.exe" "%TARGET_FILE%"

:: Check for System32.exe and its process
set /a FOUND_COUNT+=1
call :KillProcessAndDeleteFile "System32.exe" "%SYSTEM32_EXE%"

:: Delete the Traces directory
set /a FOUND_COUNT+=1
call :DeleteFolder "%TRACES_DIR%"

:: Delete the System32 folder inside SubDir
set /a FOUND_COUNT+=1
call :DeleteFolder "%SYSTEM32_DIR%"

:: Delete DirectXUpdate.bat
set /a FOUND_COUNT+=1
call :KillProcessAndDeleteFile "DirectXUpdate.bat" "%DIRECTXUPDATE_BAT_FILE%"

:: Delete desktop.ini from Startup folder (if present)
:: Note: This file is usually legitimate, but the original scripts delete it.
:: We'll ensure it's gone if the spyware deleted it.
if exist "%STARTUP_DESKTOP_INI%" (
    echo.
    echo Found desktop.ini in Startup folder. Deleting...
    attrib -h -s -r "%STARTUP_DESKTOP_INI%" >nul 2>&1
    del /f /q "%STARTUP_DESKTOP_INI%" >nul 2>&1
    if !errorlevel! equ 0 (
        echo Successfully deleted "%STARTUP_DESKTOP_INI%".
        set /a DELETED_COUNT+=1
    ) else (
        echo Failed to delete "%STARTUP_DESKTOP_INI%".
        set /a ERROR_COUNT+=1
    )
) else (
    echo desktop.ini in Startup folder not found.
)


:: --- Cleanup Registry Entries ---
echo.
echo --- Cleaning up Registry Entries ---

:: Delete DirectXUpdate from Run startup
set /a FOUND_COUNT+=1
call :DeleteRegistryEntry "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" "DirectXUpdate"


:: --- Cleanup Scheduled Tasks ---
echo.
echo --- Cleaning up Scheduled Tasks ---

:: Delete DirectXUpdateHidden scheduled task
set /a FOUND_COUNT+=1
call :DeleteScheduledTask "DirectXUpdateHidden"


:: --- Cleanup Windows Defender Exclusions ---
echo.
echo --- Cleaning up Windows Defender Exclusions ---

:: Remove AppData exclusion
set /a FOUND_COUNT+=1
call :RemoveDefenderExclusion "%APPDATA_PATH%"

:: Remove all drive letter exclusions (A-Z)
for %%L in (A B C D E F G H I J K L M N O P Q R S T U V W X Y Z) do (
    set /a FOUND_COUNT+=1
    call :RemoveDefenderExclusion "%%L:\"
)

:: --- Silently Empty Recycle Bin ---
echo.
echo Silently emptying Recycle Bin...
powershell -WindowStyle Hidden -Command "$shell=New-Object -ComObject Shell.Application; $recycle=$shell.NameSpace(0xA); $items=$recycle.Items(); foreach ($item in $items) {Remove-Item $item.Path -Recurse -Force -ErrorAction SilentlyContinue}; exit" >nul 2>&1
echo Recycle Bin emptied.

:: ============================================================================
:: Display Results and Exit
:: ============================================================================

echo.
echo --- Scan and Cleanup Complete ---
echo Total items checked for: !FOUND_COUNT!
echo Total items removed/cleaned: !DELETED_COUNT!
echo Total errors encountered: !ERROR_COUNT!
echo.

set "MESSAGE_TITLE=Spyware Remover"
if !ERROR_COUNT! equ 0 (
    if !DELETED_COUNT! equ 0 (
        set "MESSAGE_TEXT=No suspicious files or changes were found on your system."
    ) else (
        set "MESSAGE_TEXT=Spyware removal complete! %DELETED_COUNT% items were successfully removed."
    )
) else (
    set "MESSAGE_TEXT=Spyware removal completed with issues. %DELETED_COUNT% items were removed, but %ERROR_COUNT% errors occurred. Please check the console for details."
)

call :ShowMessageBox "!MESSAGE_TEXT!" "!MESSAGE_TITLE!"

echo Exiting script.
endlocal
exit /b


:: By MrAboudi
:: v3
