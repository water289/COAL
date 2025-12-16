@echo off
REM ============================================
REM MASM32 Installation Helper Script
REM ============================================
REM Run this after extracting masm32v11.zip

echo.
echo ============================================
echo MASM32 Installation Setup
echo ============================================
echo.

REM Check if we're in the right directory
if not exist "install.bat" (
    echo ERROR: install.bat not found
    echo.
    echo This script should be run from the extracted masm32v11 folder
    echo where install.bat is located.
    echo.
    pause
    exit /b 1
)

echo Found install.bat - Ready to install
echo.
echo NOTE: This script will now attempt to run install.bat
echo You may need to run it as Administrator.
echo.
echo If you get permission errors:
echo   1. Right-click cmd.exe
echo   2. Select "Run as Administrator"
echo   3. Run this script again
echo.
pause

REM Run the installer
echo.
echo Starting MASM32 installation...
echo.
call install.bat

if errorlevel 1 (
    echo.
    echo ERROR: Installation failed
    echo.
    echo Try running as Administrator:
    echo   1. Right-click this .bat file
    echo   2. Select "Run as Administrator"
    echo.
    pause
    exit /b 1
)

echo.
echo ============================================
echo Installation Complete!
echo ============================================
echo.
echo MASM32 should now be installed to: C:\masm32\
echo.
echo NEXT STEPS:
echo   1. Close all terminals/PowerShell windows
echo   2. Open a NEW terminal window
echo   3. Verify installation: where ml
echo   4. You should see: C:\masm32\bin\ml.exe
echo.
echo Then:
echo   cd d:\COAL
echo   build.bat
echo   bin\interpreter.exe
echo.
pause
