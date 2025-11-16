@echo off
setlocal

for %%I in ("%~dp0.") do set "SCRIPT_DIR=%%~fI"
set "BUILD_DIR=%SCRIPT_DIR%\build"

if exist "%BUILD_DIR%" (
    echo Removing "%BUILD_DIR%"
    rmdir /s /q "%BUILD_DIR%"
) else (
    echo No build directory found at "%BUILD_DIR%"
)

echo Clean complete.

endlocal
