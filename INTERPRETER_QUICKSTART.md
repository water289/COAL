# Scripting Language Interpreter - Quick Start Guide

## Installation & Running

### Step 1: Build
```batch
cd D:\COAL
build.bat
```

### Step 2: Run
```batch
.\bin\interpreter.exe
```

You'll see:
```
Scripting Language Interpreter v2.0
Type 'help' for commands, 'exit' to quit
>>> 
```

## Quick Commands

### Store Values
```
>>> store 42 in x
>>> show x
x = 42
```

### Print Text
```
>>> print Hello World
Hello World
```

### Output Numbers
```
>>> output 123
123
```

### Combine Commands
```
>>> store 100 in total
>>> print The total is:
The total is:
>>> output total
100
```

## Script Mode

### Create & Run Script
```
>>> start
SCRIPT> store 0 in counter
SCRIPT> print Starting
SCRIPT> finish
Executing script...
```

## Help & System

```
>>> help          # Show all commands
>>> clear         # Clear screen
>>> exit          # Exit interpreter
>>> quit          # Also exits
```

## Complete Example Session

```
>>> store 10 in x
>>> store 20 in y
>>> show x
x = 10
>>> show y
y = 20
>>> print Variables stored successfully
Variables stored successfully
>>> output x
10
>>> help
[Shows detailed command reference]
>>> clear
[Clears screen]
>>> exit
Goodbye!
```

## Data Limits

- Up to 64 variables per session
- Variable names: up to 20 characters
- Numbers: 32-bit signed integers (-2,147,483,648 to 2,147,483,647)
- Input lines: up to 256 characters
- Script lines: up to 100 commands

## Supported Commands

| Command | Syntax | Example |
|---------|--------|---------|
| store | store \<number\> in \<var\> | store 42 in answer |
| show | show \<var\> | show answer |
| print | print \<text\> | print Hello |
| output | output \<number\> | output 42 |
| script/start | script | script |
| finish | finish | finish |
| help | help | help |
| clear | clear | clear |
| exit/quit | exit | exit |

## Troubleshooting

### Program won't build
- Ensure MASM32 is installed
- Add MASM32 to PATH: `set PATH=%PATH%;C:\masm32\bin`

### Program exits immediately
- Try running: `.\bin\interpreter.exe`
- If issues persist, rebuild: `build.bat`

### Commands not recognized
- Use lowercase letters (automatically converted)
- Ensure proper spacing between words
- Type 'help' to see correct syntax

## File Structure

```
D:\COAL\
├── src/
│   ├── interpreter.asm              # Main source code
│   └── ScriptingLanguageInterpreter.asm  # Backup
├── bin/
│   └── interpreter.exe              # Compiled program
├── include/
│   ├── Irvine32.inc
│   └── macros.inc
├── lib/
│   └── Irvine32.lib
├── build.bat                        # Build script
└── INTERPRETER_DOCUMENTATION.md     # Full documentation
```

## Tips

1. **Variable Names**: Use descriptive names (myValue, total, counter, etc.)
2. **Script Mode**: Useful for storing multiple commands together
3. **Comments**: Lines starting with # are ignored
4. **Uppercase**: Commands work in uppercase or lowercase

## Next Steps

- Explore arithmetic operations (when implemented)
- Try creating scripts with multiple commands
- Use 'help' to see all features
- Review INTERPRETER_DOCUMENTATION.md for advanced usage

---
**Quick Start**: Run `.\bin\interpreter.exe` and type `help` at the prompt!
