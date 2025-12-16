@echo off
REM ============================================
REM clean.bat - Clean build artifacts
REM ============================================

echo Cleaning build artifacts...

if exist src\*.obj del src\*.obj
if exist bin\interpreter.exe del bin\interpreter.exe

echo Done!
