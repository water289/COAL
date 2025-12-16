# Scripting Language Interpreter - MASM Implementation

## Overview

This is a comprehensive implementation of a scripting language interpreter in x86 Assembly (MASM) using the Irvine32 library. The interpreter provides a complete command-line interface for executing commands, managing variables, and executing scripts.

## Features

### Core Functionality

1. **Variable Management**
   - Store values in named variables: `store 42 in x`
   - Display variable values: `show x`
   - Supports up to 64 variables
   - Case-insensitive variable names
   - Values persist across commands

2. **Text Output**
   - `print <text>` - Output text to console
   - `output <expr>` - Evaluate and output expressions
   - Direct character output with proper formatting

3. **Arithmetic Operations** (Foundation)
   - Number parsing
   - Value storage and retrieval
   - Expression evaluation framework
   - Ready for extension: add, subtract, multiply, divide

4. **Script Mode**
   - `script` or `start` - Enter script mode
   - Multiple command entry
   - `finish` or blank line - Exit script mode
   - Script execution support

5. **System Commands**
   - `help` - Display comprehensive command reference
   - `clear` - Clear the screen
   - `exit` / `quit` - Exit the interpreter

## Building the Program

### Prerequisites
- MASM32 installed and in PATH
- Irvine32 library available
- Windows environment

### Compilation Steps

```batch
cd D:\COAL
build.bat
```

Output:
- Executable: `bin\interpreter.exe`
- Object files cleaned automatically

## Running the Interpreter

```batch
.\bin\interpreter.exe
```

The program will display a welcome message and show the `>>>` prompt.

## Command Reference

### Basic Commands

```
store <number> in <variable>    - Store a value in a variable
show <variable>                 - Display variable value
print <text>                    - Print text to console
output <number>                 - Output a number/expression
help                            - Show command help
clear                           - Clear screen
exit / quit                     - Exit interpreter
```

### Script Mode

```
start / script              - Enter script mode (SCRIPT> prompt)
<commands>                  - Enter multiple commands
finish / [blank line]       - Exit script mode and execute
```

## Implementation Details

### Architecture

The interpreter follows a modular design with separate procedures for:

- **String Utilities**
  - `StringToLower` - Convert input to lowercase for case-insensitive processing
  - `TrimString` - Remove leading/trailing whitespace
  - `CompareString` / `CompareStringCI` - String comparison routines
  - `ExtractToken` - Parse individual tokens from input

- **Variable Management**
  - `FindVariable` - Locate variable by name
  - `GetVariableValue` - Retrieve variable value
  - `SetVariableValue` - Store/create variable
  - `CreateVariable` - Initialize new variable

- **Parsing**
  - `ParseNumber` - Convert text to integer
  - Expression evaluation framework

- **Command Handlers**
  - `HandlePrint` - Process print command
  - `HandleOutput` - Process output command
  - `HandleStore` - Process store command
  - `HandleShow` - Display variable
  - `HandleScript` - Enter script mode
  - `HandleClear` - Clear display
  - `HandleHelp` - Show help

- **Main Loop**
  - `ProcessCommand` - Parse and dispatch commands
  - `main` - Main interpreter loop
  - `ExecuteScript` - Run stored scripts

### Data Structures

```asm
; Variables Storage (64 max)
var_names    BYTE MAX_VARIABLES * 20 DUP(0)  ; 20-char names
var_values   DWORD MAX_VARIABLES DUP(0)      ; Integer values
var_count    DWORD 0                          ; Number of variables

; Buffers
user_input   BYTE MAX_INPUT_SIZE DUP(?)      ; 256-byte input
token        BYTE 32 DUP(?)                  ; Token buffer
command      BYTE 32 DUP(?)                  ; Command buffer

; Script Mode
script_mode  BYTE 0                          ; Flag for script mode
script_lines BYTE MAX_SCRIPT_LINES * MAX_INPUT_SIZE DUP(?)
script_line_count DWORD 0
```

### Control Flow

```
main
├── Initialize (clear screen, show welcome)
└── Main Loop
    ├── Check script_mode flag
    ├── If script_mode = 1
    │   ├── Show SCRIPT> prompt
    │   ├── Read command
    │   ├── Check for "finish"
    │   └── Store command line
    └── If script_mode = 0
        ├── Show >>> prompt
        ├── Read command
        ├── ProcessCommand
        │   ├── StringToLower
        │   ├── TrimString
        │   ├── Parse command name
        │   └── Dispatch to handler
        └── Check for exit signal
```

## Example Usage

### Basic Variable Operations

```
>>> store 42 in answer
>>> show answer
answer = 42
>>> print The answer is:
The answer is:
>>> output answer
42
```

### Multiple Variables

```
>>> store 10 in x
>>> store 20 in y
>>> store 30 in z
>>> show x
x = 10
>>> show y
y = 20
>>> show z
z = 30
```

### Script Mode

```
>>> start
SCRIPT> store 100 in total
SCRIPT> print Processing complete
SCRIPT> finish
Executing script...
>>> 
```

## Error Handling

The interpreter includes error handling for:
- Unknown commands
- Variable not found
- Syntax errors in commands
- Division by zero (framework in place)
- Buffer overflow protection

Error messages are displayed to the console with descriptive text.

## Extensibility

The modular design allows easy addition of new features:

### Adding a New Command

1. Create a handler procedure:
```asm
HandleNewCommand PROC
    ; Implementation here
    ret
HandleNewCommand ENDP
```

2. Add command string in data section:
```asm
newcmd BYTE "newcommand", 0
```

3. Add comparison in `ProcessCommand`:
```asm
mov esi, offset command
mov edi, offset newcmd
call CompareString
jc cmd_is_new
```

4. Add case label:
```asm
cmd_is_new:
    call HandleNewCommand
    jmp cmd_continue
```

### Arithmetic Operations

The framework for arithmetic is in place. To implement `add`, `subtract`, `multiply`, `divide`:

1. Enhance `ParseExpression` to handle operators
2. Implement operator dispatch
3. Perform calculations and return results
4. Add error handling for division by zero

### Conditional Execution

To implement `if` conditions:

1. Parse condition syntax: `if <expr> <op> <expr>`
2. Evaluate expressions
3. Compare values based on operator (<, >, =, !=, etc.)
4. Execute conditional block

### Loop Constructs

To implement loops:

1. Parse loop syntax
2. Initialize loop counter
3. Execute loop body repeatedly
4. Check exit condition

## Technical Notes

### Register Usage Convention
- EAX: Return values, accumulator
- EBX: Loop counters, temporary storage
- ECX: Counter for string operations
- EDX: Data operands
- ESI: Source pointer (strings, data)
- EDI: Destination pointer

### Irvine32 Library Functions Used
- `ReadString` - Read user input
- `WriteString` - Output string
- `WriteChar` - Output single character
- `WriteInt` - Output integer
- `Crlf` - Output newline
- `Clrscr` - Clear screen

### Known Limitations
- Variable names limited to 20 characters
- Maximum 64 variables per session
- Maximum 100 script lines
- Numeric values are 32-bit signed integers
- No floating-point arithmetic

## Performance

- Command parsing: O(n) where n is input length
- Variable lookup: O(m) where m is number of variables
- String comparison: O(k) where k is name length

## Future Enhancements

1. **Advanced Arithmetic**
   - Floating-point support
   - Complex expressions with parentheses
   - Function calls

2. **Control Flow**
   - If/else conditionals
   - For/while loops
   - Break/continue statements

3. **Data Structures**
   - Arrays
   - String manipulation
   - Dynamic memory

4. **Input/Output**
   - File operations
   - Formatted output
   - Input validation

5. **Debugging**
   - Variable inspection
   - Step-through execution
   - Breakpoints

## Files

- `src/interpreter.asm` - Main interpreter source code
- `src/ScriptingLanguageInterpreter.asm` - Backup of comprehensive implementation
- `bin/interpreter.exe` - Compiled executable
- `include/Irvine32.inc` - Irvine32 library definitions
- `lib/Irvine32.lib` - Irvine32 library (linked)

## Compilation Notes

- Warning "multiple .MODEL directives found" is from SmallWin.inc and is harmless
- All warnings are pre-existing and do not affect functionality
- The executable is console-based and requires Windows

## License and Attribution

This implementation demonstrates:
- x86 Assembly programming fundamentals
- Irvine32 library usage
- Interpreter/scripting language design
- String parsing and tokenization
- Dynamic data structure management
- User interaction and command dispatch

---

**Created**: December 7, 2025  
**MASM Version**: 6.14  
**Irvine32**: Version 4.x  
**Platform**: Windows x86
