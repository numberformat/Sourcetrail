@echo off
setlocal enabledelayedexpansion

set "BUILD_TYPE=%~1"
if "%BUILD_TYPE%"=="" set "BUILD_TYPE=Release"

for %%I in ("%~dp0.") do set "SCRIPT_DIR=%%~fI"
set "BUILD_DIR=%SCRIPT_DIR%\build\%BUILD_TYPE%"
set "CONAN_OUTPUT_DIR=%BUILD_DIR%"
set "TOOLCHAIN_FILE=%CONAN_OUTPUT_DIR%\build\generators\conan_toolchain.cmake"

where conan >nul 2>nul
if errorlevel 1 (
    echo Error: conan is not in PATH. Install it first ^(e.g. "pip install conan"^). 1>&2
    exit /b 1
)

where cmake >nul 2>nul
if errorlevel 1 (
    echo Error: cmake is not in PATH. Install CMake 3.12+ and try again. 1>&2
    exit /b 1
)

set "CONAN_PROFILES_DIR=%USERPROFILE%\.conan2\profiles"
set "CONAN_DEFAULT_PROFILE=%CONAN_PROFILES_DIR%\default"
if not exist "%CONAN_DEFAULT_PROFILE%" (
    echo ==> Detecting Conan default profile
    conan profile detect
    if errorlevel 1 (
        echo Error: Failed to detect Conan profile automatically. 1>&2
        exit /b 1
    )
)

echo ==> Running Conan install (%BUILD_TYPE%)
conan install "%SCRIPT_DIR%" --output-folder="%CONAN_OUTPUT_DIR%" --build=missing -s build_type=%BUILD_TYPE%
if errorlevel 1 exit /b 1

if not exist "%TOOLCHAIN_FILE%" (
    echo Error: expected Conan toolchain at %TOOLCHAIN_FILE% but it was not generated. 1>&2
    exit /b 1
)

echo ==> Configuring CMake
cmake -S "%SCRIPT_DIR%" -B "%BUILD_DIR%" -DCMAKE_BUILD_TYPE="%BUILD_TYPE%" -DCMAKE_TOOLCHAIN_FILE="%TOOLCHAIN_FILE%"
if errorlevel 1 exit /b 1

echo ==> Building Sourcetrail
cmake --build "%BUILD_DIR%" --config "%BUILD_TYPE%" --target Sourcetrail
if errorlevel 1 exit /b 1

echo Build completed. Artifacts are in %BUILD_DIR%

endlocal
