@echo off

REM Check if script is already running with elevated permissions
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system" || (
    echo Error: Script must be run with elevated permissions.
    powershell -Command "Start-Process '%0' -Verb RunAs"

    exit /b 1
)


REM Set username to rGuest
set username="rGuest"

REM Check if the user already exists
net user "%username%" >nul 2>&1
if %errorlevel% equ 0 (
    echo Error: User "%username%" already exists.
    pause
    exit /b 1
)

REM Create the user account
net user "%username%" /add

REM Check if user creation was successful
if %errorlevel% neq 0 (
    echo Error: Failed to create user account.
    pause
    exit /b 1
)

REM Add the user to the remote desktop users group
net localgroup "Remote Desktop Users" "%username%" /add

REM Check if adding user to the guest group was successful
if %errorlevel% neq 0 (
    echo Error: Failed to add user to the guest group.
    pause
    exit /b 1
)

echo User "%username%" has been created and added to the guest group successfully.
pause

REM set the current directory of this script
set "script_dir=%~dp0"

REM This is the pathway to the currently active group policy
set "current_policy=C:\Windows\System32\GroupPolicy"

REM Copy the currently active policy to the Guest Host Policy directory
set "host_policy=%script_dir%HostPolicy"

if not exist "%host_policy%" (
    echo Sorry the host policy is missing. Aborting.
    pause
    exit /b 1
)

xcopy /s /e /y "%current_policy%\*" "%host_policy%"

echo Updated Host Policy
pause
