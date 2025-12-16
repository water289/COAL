@echo off
REM Build script for Human Language Interpreter (HL)

cd /d D:\COAL

REM Delete old executable if it exists
if exist bin\interpreter_hl.exe del bin\interpreter_hl.exe

REM Assemble
echo Assembling interpreter_hl.asm...
cd src
set PATH=%PATH%;D:\masm32\bin
D:\masm32\bin\ml /c /coff /Cp /Zd /I"D:\masm32\include" interpreter_hl.asm

if errorlevel 1 (
    echo ERROR: Assembly failed!
    exit /b 1
)

REM Link
echo Linking...
cd ..
D:\masm32\bin\link /SUBSYSTEM:CONSOLE /LIBPATH:"D:\COAL\lib" /OUT:bin\interpreter_hl.exe src\interpreter_hl.obj Irvine32.lib Kernel32.Lib User32.Lib

if errorlevel 1 (
    echo ERROR: Linking failed!
    exit /b 1
)

echo Build complete! Executable: bin\interpreter_hl.exe
echo To run the interpreter, type: bin\interpreter_hl.exe
