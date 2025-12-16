# Compiled Executables Directory

This directory contains the compiled .exe files from your assembly programs.

## Usage

After building a program:
```powershell
.\build.bat src\myprogram.asm
```

The executable will be created here: `bin\myprogram.exe`

## Running Programs

From the root directory:
```powershell
.\bin\myprogram.exe
```

Or navigate to bin directory:
```powershell
cd bin
.\myprogram.exe
```

## Note

This directory is tracked by git, but .exe files are ignored via .gitignore.
Only the structure is maintained in version control.
