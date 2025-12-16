@echo off
REM ============================================
REM build_v2.bat - Build Enhanced Interpreter
REM ============================================

echo Building Human Language Scripting Interpreter v2.0 (Enhanced)...
echo.

REM Check if MASM32 is in PATH
where ml >nul 2>&1
if errorlevel 1 (
    echo ERROR: MASM32 tools not found in PATH
    echo.
    echo Please ensure MASM32 is installed and in PATH
    echo Current PATH: %PATH:;=^
%
    echo.
    goto end
)

cd src

REM Assemble the enhanced interpreter
echo Assembling interpreter_v2.asm...
ml /c /coff /Cp /Zd /I"..\include" interpreter_v2.asm
if errorlevel 1 goto error

REM Link the interpreter
echo Linking executable...
link /SUBSYSTEM:CONSOLE /LIBPATH:"..\lib" /OUT:..\bin\interpreter_v2.exe interpreter_v2.obj Irvine32.lib kernel32.lib user32.lib
if errorlevel 1 goto error

REM Clean up object files
del interpreter_v2.obj

cd ..

echo.
echo ============================================
echo Build successful!
echo ============================================
echo Executable: bin\interpreter_v2.exe
echo.
echo To run the enhanced interpreter:
echo   bin\interpreter_v2.exe
echo.
goto end

:error
echo.
echo ============================================
echo Build failed!
echo ============================================
cd ..

:end
