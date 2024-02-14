@echo off

REM Check if script is already running with elevated permissions
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system" || (
    echo Error: Script must be run with elevated permissions.
    powershell -Command "Start-Process '%0' -Verb RunAs"

    exit /b 1
)

REM set the current directory of this script
set "script_dir=%~dp0"

REM This is the pathway to the currently active group policy
set "current_policy=C:\Windows\System32\GroupPolicy"

REM Delete all files within the folder
del /Q "%current_policy%\*" >nul 2>&1

REM Delete all subdirectories within the folder
for /d %%i in ("%current_policy%\*") do rd /s /q "%%i"

pause 

if errorlevel 1 (

        echo Error: Unable to remove group policy.
	pause

    ) else (

	echo Group policy deleted successfully.
)


REM Copy the Host Policy to the currently active group policy directory
set "host_policy=%script_dir%HostPolicy"

if not exist "%host_policy%" (
    echo Sorry the host policy is missing. Aborting.
    pause
    exit /b 1
)

xcopy /s /e /y "%host_policy%\*" "%current_policy%"

gpupdate /force

echo Updated Current Policy to Host GPO, Please restart to enact all changes

pause