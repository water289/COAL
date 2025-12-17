@echo off
REM ============================================
REM build.bat - Build the interpreter
REM ============================================

echo Building Human Language Scripting Interpreter...
echo.

REM Check if MASM32 is in PATH
where ml >nul 2>&1
if errorlevel 1 (
    echo ERROR: MASM32 tools not found in PATH
    echo.
    echo Please install MASM32 from: http://www.masm32.com/
    echo Or add MASM32 to your PATH:
    echo   set PATH=%%PATH%%;C:\masm32\bin
    echo.
    goto end
)

REM Delete old executable if it exists
if exist bin\interpreter.exe del bin\interpreter.exe

cd src

REM Assemble the interpreter
ml /c /coff /Cp /Zd /I"..\include" interpreter_incremental.asm
if errorlevel 1 goto error

REM Link the interpreter
link /SUBSYSTEM:CONSOLE /LIBPATH:"..\lib" /OUT:..\bin\interpreter.exe interpreter_incremental.obj Irvine32.lib kernel32.lib user32.lib
if errorlevel 1 goto error

REM Clean up object files
del interpreter_incremental.obj

cd ..

echo.
echo ============================================
echo Build successful!
echo ============================================
echo Executable: bin\interpreter.exe
echo.
echo To run the interpreter:
echo   bin\interpreter.exe
echo.
goto end

:error
echo.
echo ============================================
echo Build failed!
echo ============================================
cd ..

:end
