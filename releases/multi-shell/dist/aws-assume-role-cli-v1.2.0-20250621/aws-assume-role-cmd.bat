@echo off
REM AWS Assume Role - Command Prompt Wrapper
REM Usage: aws-assume-role-cmd.bat assume <role-name>

setlocal enabledelayedexpansion

set BINARY_PATH=
if exist "aws-assume-role-windows.exe" (
    set BINARY_PATH=aws-assume-role-windows.exe
) else if exist "aws-assume-role.exe" (
    set BINARY_PATH=aws-assume-role.exe
) else (
    where aws-assume-role-windows.exe >nul 2>&1
    if !errorlevel! equ 0 (
        set BINARY_PATH=aws-assume-role-windows.exe
    ) else (
        where aws-assume-role.exe >nul 2>&1
        if !errorlevel! equ 0 (
            set BINARY_PATH=aws-assume-role.exe
        ) else (
            echo ❌ AWS Assume Role binary not found
            exit /b 1
        )
    )
)

if "%1"=="assume" if not "%2"=="" (
    echo 🔄 Assuming role: %2
    for /f "delims=" %%i in ('!BINARY_PATH! assume %2 %3 %4 %5 %6 %7 %8 %9 --format export 2^>nul') do (
        %%i
    )
    if !errorlevel! equ 0 (
        echo 🎯 Role assumed successfully in current session!
        echo Current AWS identity:
        aws sts get-caller-identity --query "Arn" --output text 2>nul || echo Failed to verify identity
    )
) else (
    !BINARY_PATH! %*
)
