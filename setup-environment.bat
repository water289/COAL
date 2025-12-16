@echo off
REM ============================================
REM setup-environment.bat - Automated Setup Helper
REM ============================================
REM This script helps set up the interpreter environment
REM Run this as Administrator for best results

echo.
echo ============================================
echo Human Language Scripting Interpreter Setup
echo ============================================
echo.

REM Check if MASM32 is already installed
where ml >nul 2>&1
if %errorlevel% equ 0 (
    echo [OK] MASM32 is already in PATH
    goto check_lib
)

echo [INFO] MASM32 not found in PATH
echo.
echo To install MASM32:
echo 1. Visit: http://www.masm32.com/download.htm
echo 2. Download masm32v11r.zip (or latest version)
echo 3. Extract to C:\masm32\
echo 4. Run: C:\masm32\install.bat
echo 5. Restart your terminal
echo.
echo After installation, verify with: where ml
echo.
pause

:check_lib
echo Checking for Irvine32 library...
if exist "..\lib\Irvine32.lib" (
    echo [OK] Irvine32.lib found
) else (
    echo [ERROR] Irvine32.lib not found
    echo Check that lib\ directory exists in project root
)

if exist "..\include\Irvine32.inc" (
    echo [OK] Irvine32.inc found
) else (
    echo [ERROR] Irvine32.inc not found
    echo Check that include\ directory exists in project root
)

echo.
echo ============================================
echo Setup Check Complete
echo ============================================
echo.
echo If all checks passed [OK], you can now:
echo   1. cd d:\COAL
echo   2. build.bat
echo   3. bin\interpreter.exe
echo.
echo If you see errors, follow the instructions above.
echo.
pause
