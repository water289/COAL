@echo off
REM Build script for Enhanced Human Language Scripting Interpreter
REM Features: String storage, decrement, script mode, expressions

echo Building Enhanced Human Language Scripting Interpreter...
echo.

REM Check if MASM32 is in PATH
where ml >nul 2>nul
if errorlevel 1 (
    echo Error: MASM32 not found in PATH
    echo Please install MASM32 and add it to your PATH
    pause
    exit /b 1
)

REM Go to src directory
cd src

REM Assemble
echo Assembling: interpreter_enhanced.asm
ml /c /coff /Cp /Zd /I"..\include" interpreter_enhanced.asm
if errorlevel 1 (
    echo Assembly failed!
    cd ..
    pause
    exit /b 1
)

REM Link
echo Linking executable...
link /SUBSYSTEM:CONSOLE /LIBPATH:"..\lib" /OUT:..\bin\interpreter_enhanced.exe interpreter_enhanced.obj Irvine32.lib kernel32.lib user32.lib
if errorlevel 1 (
    echo Linking failed!
    del interpreter_enhanced.obj
    cd ..
    pause
    exit /b 1
)

REM Clean up object files
del interpreter_enhanced.obj

REM Return to root
cd ..

echo.
echo Build successful!
echo Executable: bin\interpreter_enhanced.exe
echo.
pause
