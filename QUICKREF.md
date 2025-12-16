# Quick Reference Card - Human Language Scripting Interpreter

## 15 Commands at a Glance

### Arithmetic
| Command | Syntax | Example |
|---------|--------|---------|
| **add** | `add X and Y` | `add 5 and 3` → 8 |
| **subtract** | `subtract X from Y` | `subtract 5 from 10` → 5 |
| **multiply** | `multiply X and Y` | `multiply 6 and 7` → 42 |
| **divide** | `divide X by Y` | `divide 10 by 3` → Q:3 R:1 |

### Variables
| Command | Syntax | Example |
|---------|--------|---------|
| **store** | `store X in VAR` | `store 100 in balance` |
| **show** | `show VAR` | `show balance` → balance = 100 |
| **add 1 to** | `add 1 to VAR` | `add 1 to counter` |

### Output
| Command | Syntax | Example |
|---------|--------|---------|
| **print** | `print TEXT` | `print Hello World` |
| **output** | `output EXPR` | `output x` → 42 |

### Utility
| Command | Syntax | Example |
|---------|--------|---------|
| **help** | `help` | Shows all commands |
| **clear** | `clear` | Clears screen |
| **exit** | `exit` or `quit` | Exits interpreter |

### Special
| Command | Syntax | Example |
|---------|--------|---------|
| **#** | `# comment` | `# This is a comment` |
| **loop** | (partial) | Not fully implemented |

---

## Quick Start

```cmd
cd d:\COAL
build.bat
bin\interpreter.exe
```

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
>>> exit
Goodbye!
```

## Error Messages
- **Unknown command** - Command not recognized
- **Variable not found** - Undefined variable used
- **Division by zero** - Attempted to divide by 0
- **Syntax error** - Invalid command format

## Tips
✓ Commands are case-insensitive  
✓ Variables are case-insensitive  
✓ Use # for comments  
✓ Max 64 variables  
✓ Integer values only  

---

**Number of runnable commands: 15**
