# Human Language Scripting Interpreter

**Number of runnable commands implemented: 15**

A complete x86 Assembly Language implementation of a Human Language Scripting Interpreter built with MASM32 and the Irvine32 library.

## Features

- ✅ **15 Runnable Commands** - Complete command set for scripting
- ✅ **Variable Storage** - Up to 64 variables with integer values
- ✅ **Arithmetic Operations** - Add, subtract, multiply, divide
- ✅ **Expression Evaluation** - Literals and variable references
- ✅ **Interactive REPL** - Read-Eval-Print Loop interface
- ✅ **Case-Insensitive** - Commands and variables are case-insensitive
- ✅ **Comments** - Line comments with `#`

## Prerequisites

1. **MASM32 SDK** - Download from http://www.masm32.com/
2. **Irvine32 Library** - Included in this repository (lib/ and include/ folders)

## Installation

1. Install MASM32 SDK to `C:\masm32\` (or update paths in build.bat)
2. Ensure Irvine32 files are in the `lib/` and `include/` directories
3. Add MASM32 bin directory to your PATH:
   ```
   set PATH=%PATH%;C:\masm32\bin
   ```

## Building

Run the build script:
```
build.bat
```

This will:
- Assemble `src/interpreter.asm`
- Link with Irvine32 library
- Create `bin/interpreter.exe`

## Usage

Run the interpreter:
```
bin\interpreter.exe
```

You'll see the REPL prompt:
```
>>> 
```

Type commands and press Enter. Type `help` to see all available commands.

## Example Session

```
>>> store 10 in x
>>> show x
x = 10
>>> add 5 and 3
8
>>> multiply x and 2
20
>>> add 1 to x
>>> show x
x = 11
>>> print Hello World
Hello World
>>> exit
```

## Command Reference

See [COMMANDS.md](COMMANDS.md) for complete command syntax and examples.

## Test Cases

See [test_cases.txt](test_cases.txt) for example programs and test scenarios.

## Project Structure

```
d:\COAL\
├── src\
│   └── interpreter.asm    # Main interpreter source (single file)
├── lib\
│   └── Irvine32.lib       # Irvine32 library
├── include\
│   └── Irvine32.inc       # Irvine32 header
├── bin\
│   └── interpreter.exe    # Built executable
├── build.bat              # Build script
├── clean.bat              # Clean script
├── README.md              # This file
├── COMMANDS.md            # Command reference
└── test_cases.txt         # Test cases
```

## Technical Details

- **Architecture**: x86 (32-bit)
- **Assembler**: MASM32 (ml.exe)
- **Library**: Irvine32
- **Platform**: Windows Console Application
- **Max Variables**: 64
- **Max Input Length**: 128 characters
- **Max Tokens Per Line**: 16

## Author

Assembly Language Engineer  
December 7, 2025

## License

Educational use only. This project demonstrates assembly language programming concepts using MASM32 and Irvine32.
