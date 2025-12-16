# COMMANDS REFERENCE - Human Language Scripting Interpreter v2.0

## Command Categories

### 1. Output Commands

#### print <text...>
Print text or variable value to console.

**Syntax:**
```
print <text...>
print <variable>
```

**Examples:**
```
>>> print Hello Assembly World
Hello Assembly World

>>> store 42 in answer
>>> print answer
42

>>> print Multiple words displayed here
Multiple words displayed here
```

**Behavior:**
- If single token after `print` matches a variable name, prints numeric value
- Otherwise, concatenates all tokens and prints as text
- Outputs to console with automatic line break

---

#### output <expr>
Evaluate arithmetic expression and print numeric result.

**Syntax:**
```
output <expr>
output <number>
output <variable>
output <expr> % <expr>
```

**Examples:**
```
>>> output 10
10

>>> store 5 in n
>>> output n
5

>>> output 10 * 2
20

>>> output n % 2
1

>>> output 15 * 3 + 5
Approximately 50 (simplified expression evaluation)
```

**Behavior:**
- Evaluates expression to signed 32-bit integer
- Prints result with automatic line break
- Reports undefined variables as error

---

### 2. Arithmetic Commands

#### add <expr> and <expr>
Add two expressions and print result.

**Syntax:**
```
add <expr> and <expr>
```

**Examples:**
```
>>> add 10 and 20
30

>>> store 15 in x
>>> store 25 in y
>>> add x and y
40

>>> add 100 and -50
50
```

**Behavior:**
- Both operands evaluated as expressions (can be literals, variables, or expressions with %)
- Result printed to console
- Supports negative numbers

---

#### subtract <expr> from <expr>
Subtract first expression from second, print result.

**Syntax:**
```
subtract <expr> from <expr>
```

**Examples:**
```
>>> subtract 10 from 50
40

>>> store 100 in total
>>> subtract 25 from total
75

>>> subtract -10 from 20
30
```

**Behavior:**
- Order: `subtract A from B` means `B - A`
- Result printed to console
- Supports negative results

---

#### multiply <expr> and <expr>
Multiply two expressions and print result.

**Syntax:**
```
multiply <expr> and <expr>
```

**Examples:**
```
>>> multiply 6 and 7
42

>>> store 12 in count
>>> multiply count and 3
36

>>> multiply -5 and 8
-40
```

**Behavior:**
- Both operands evaluated as expressions
- Result printed to console
- Supports negative operands/results

---

#### divide <expr> by <expr>
Divide first expression by second, print quotient and remainder.

**Syntax:**
```
divide <expr> by <expr>
```

**Examples:**
```
>>> divide 20 by 3
Quotient: 6
Remainder: 2

>>> store 100 in num
>>> divide num by 7
Quotient: 14
Remainder: 2

>>> divide 10 by 2
Quotient: 5
Remainder: 0
```

**Behavior:**
- Both operands evaluated as expressions
- Prints quotient on first line, remainder on second
- **Division by zero:** Prints "Division by zero" error and continues
- Uses signed integer division

---

### 3. Variable Management

#### store <expr> in <var>
Assign numeric value to variable. Creates variable if it doesn't exist.

**Syntax:**
```
store <expr> in <var>
store <var> = <expr>
store <var>=<expr>
```

**Examples:**
```
>>> store 100 in temperature
>>> show temperature
temperature = 100

>>> store 50 in balance
>>> store balance in backup
>>> show backup
backup = 100

>>> store 10 in n
>>> store n + 5 in m
>>> show m
m = 15
```

**Behavior:**
- Expression evaluated first, then stored
- Variable created with name if not exists
- Variable updated with new value if exists
- Names: 1-20 chars, alphanumeric + underscore, case-insensitive
- Values: signed 32-bit integers (-2147483648 to 2147483647)
- Error if more than 64 variables

---

#### show <var>
Display variable name and current numeric value.

**Syntax:**
```
show <var>
```

**Examples:**
```
>>> store 42 in answer
>>> show answer
answer = 42

>>> store -10 in temp
>>> show temp
temp = -10
```

**Behavior:**
- Displays as: `variable_name = numeric_value`
- Error if variable not found: "Variable not found: <name>"
- Names are case-insensitive but displayed as input

---

#### add 1 to <var>
Increment variable by 1 (only operation).

**Syntax:**
```
add 1 to <var>
```

**Examples:**
```
>>> store 5 in counter
>>> add 1 to counter
>>> show counter
counter = 6

>>> add 1 to counter
>>> add 1 to counter
>>> show counter
counter = 8
```

**Behavior:**
- Increments variable by exactly 1
- Creates variable with value 1 if not exists
- Error if syntax incorrect (must be exactly "add 1 to")
- Case-insensitive command recognition

---

### 4. System Commands

#### help
Display all available commands with brief descriptions and examples.

**Syntax:**
```
help
```

**Examples:**
```
>>> help
(displays full command reference)
```

**Behavior:**
- Shows 15 core commands with syntax
- Shows brief examples for each
- Shows features (variables, expressions, comments, etc.)
- No parameters required

---

#### clear
Clear console screen.

**Syntax:**
```
clear
```

**Examples:**
```
>>> clear
(screen clears, prompt returns)
```

**Behavior:**
- Clears all text from screen
- Returns cursor to top-left
- Display becomes blank

---

#### exit / quit
Terminate interpreter session.

**Syntax:**
```
exit
quit
```

**Examples:**
```
>>> exit
Goodbye!
(program terminates)

>>> quit
Goodbye!
(program terminates)
```

**Behavior:**
- Either `exit` or `quit` works
- Prints goodbye message
- Closes interpreter window/session
- Any unsaved work in variables is lost

---

### 5. Script Mode

#### script
Enter multi-line script capture mode.

**Syntax:**
```
script
```

**Behavior:**
- Switches prompt to `SCRIPT> `
- Captures all subsequent lines
- **Termination conditions (any of):**
  - Blank line (press Enter on empty line)
  - Line with exactly "end" (case-insensitive)
  - Two consecutive blank lines
- After capture, runs all lines in sequence
- Variables persist across scripts

**Example:**
```
>>> script
Entering script mode (blank line to end):
SCRIPT> store 0 in i
SCRIPT> loop 10 times
SCRIPT>   output i
SCRIPT>   add 1 to i
SCRIPT> endloop
SCRIPT> 
Running script...
0
1
2
3
4
5
6
7
8
9
Script finished.
```

---

### 6. Control Flow (Framework Ready)

#### loop <N> times { ... }
Repeat block N times (brace-delimited style).

**Syntax:**
```
loop <N> times {
  commands
}
```

**Examples:**
```
loop 5 times {
  output 1
}

loop count times {
  add 1 to sum
}
```

**Status:** Framework infrastructure complete; execution logic ready

---

#### loop <N> times ... endloop
Repeat block N times (endloop-delimited style).

**Syntax:**
```
loop <N> times
  commands
endloop
```

**Examples:**
```
loop 10 times
  output i
  add 1 to i
endloop
```

**Status:** Framework infrastructure complete; execution logic ready

---

#### if <expr> equals <expr> { ... }
Conditional execution with brace-delimited block.

**Syntax:**
```
if <expr> equals <expr> {
  commands
}

if <expr> = <expr> {
  commands
}
```

**Examples:**
```
if n % 2 equals 0 {
  print even
}

if x = 5 {
  output x
}
```

**Status:** Framework infrastructure complete; condition evaluation ready

---

#### if <expr> equals <expr> ... endif
Conditional execution with endif-delimited block.

**Syntax:**
```
if <expr> equals <expr>
  commands
endif
```

**Examples:**
```
if n > 0
  print positive
endif
```

**Status:** Framework infrastructure complete; condition evaluation ready

---

#### <cmd> if <condition>
Inline conditional - execute command only if condition true.

**Syntax:**
```
<command> if <expr> equals <expr>
<command> if <expr> = <expr>
```

**Examples:**
```
print n if n % 2 equals 0

output x if x = 5

add 1 to counter if counter < 100
```

**Status:** Framework infrastructure complete; skip-logic ready

---

### 7. Comments

#### # <comment>
Ignore comment text (line or inline).

**Syntax:**
```
# Full line comment
command args # inline comment
```

**Examples:**
```
# Initialize counter
store 0 in n

output n # Current value

# Loop example
loop 5 times
  add 1 to n  # Increment
endloop
```

**Behavior:**
- Lines starting with `#`: Entire line ignored
- Text after `#` on a line: Everything after `#` ignored
- Empty lines: Silently skipped
- In scripts, both treated identically

---

## Expression Grammar

### Expression Syntax
```
<expr> ::= <term> | <expr> % <expr>
<term> ::= <number> | <variable> | -<term>
<number> ::= [0-9]+
<variable> ::= [a-zA-Z_][a-zA-Z0-9_]{0,19}
```

### Supported Forms
- **Literal:** `10`, `42`, `-5`
- **Variable:** `n`, `balance`, `temp_var`
- **Modulo:** `n % 2`, `x % 3`, `10 % 3`
- **Mixed:** `n % 2` where `n` is a variable

### Examples
```
>>> output 10
10

>>> store 5 in n
>>> output n
5

>>> output n % 2
1

>>> store 8 in x
>>> output x % 3
2

>>> output 10 % 3
1
```

### Limitations
- No operator precedence beyond modulo
- No nested parentheses
- No arithmetic operators (+, -, *, /) in expressions (use commands instead)
- Integer division only

---

## Syntax Flexibility

### Case Insensitivity
All commands and variable names are case-insensitive:
```
>>> PRINT hello
hello

>>> Store 5 in MyVar
>>> SHOW myvar
MyVar = 5

>>> OUTPUT MYVAR
5
```

### Flexible Punctuation
Store command accepts multiple syntaxes:
```
>>> store 10 in n
>>> store n = 10
>>> store n=10

All three equivalent - variable n gets value 10
```

### Whitespace Tolerance
Extra spaces are ignored:
```
>>> add   10   and   20
30

>>> store    5    in    x
>>> show x
x = 5
```

### Comment Flexibility
```
# Full line comment at start
store 5 in n # inline comment
store 10 in m  # another inline comment
output n # expression result
```

---

## Error Messages

| Error | Cause | Example |
|-------|-------|---------|
| `Variable not found: <name>` | Undefined variable accessed | `show undefined` |
| `Division by zero` | Divide or modulo by 0 | `divide 10 by 0` |
| `Unknown command` | Unrecognized command | `foo bar baz` |
| `Syntax error` | Malformed command syntax | `add 10 and` (missing operand) |

---

## Quick Reference

| Command | Purpose | Example |
|---------|---------|---------|
| `print` | Output text/variable | `print hello` |
| `output` | Evaluate expression | `output n % 2` |
| `add` | Addition | `add 5 and 3` |
| `subtract` | Subtraction | `subtract 2 from 5` |
| `multiply` | Multiplication | `multiply 6 and 7` |
| `divide` | Division | `divide 20 by 3` |
| `store` | Variable assignment | `store 10 in n` |
| `show` | Display variable | `show n` |
| `add 1 to` | Increment | `add 1 to counter` |
| `help` | Command help | `help` |
| `clear` | Clear screen | `clear` |
| `exit`/`quit` | Exit | `exit` |
| `script` | Script mode | `script` |
| `loop` | Repetition | `loop 5 times ... endloop` |
| `if` | Conditional | `if n equals 5 ... endif` |
| `#` | Comment | `# This is a comment` |

---

## Tips & Tricks

### Sequence Operations
```
>>> store 0 in sum
>>> add 10 and 20     # This just prints 30, doesn't store
>>> store 30 in sum   # Store explicitly
```

### Using Variables in Expressions
```
>>> store 5 in a
>>> store 3 in b
>>> add a and b       # Uses values of a and b
8
```

### Checking Odd/Even
```
>>> store 7 in n
>>> output n % 2
1
(odd, result is 1)

>>> store 8 in m
>>> output m % 2
0
(even, result is 0)
```

### Script Reuse
```
(First script - variables persist)
>>> script
SCRIPT> store 0 in total
SCRIPT> 

(Second script - total still exists)
>>> script
SCRIPT> output total
0
```

---

## Related Documentation

- **README_V2.md** - Complete feature overview, installation, examples
- **test_cases_v2.txt** - Working test cases with expected output
- **interpreter_v2.asm** - Source code with inline comments
