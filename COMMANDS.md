# Command Reference

**Number of runnable commands implemented: 15**

This document describes all available commands in the Human Language Scripting Interpreter.

## Command List

### 1. print <text>
Display text or variable value.

**Syntax:**
```
print <text>
print <variable>
print <number>
```

**Examples:**
```
print Hello World
print n
print 42
```

---

### 2. output <expr>
Display the result of an expression.

**Syntax:**
```
output <expression>
```

**Examples:**
```
output x
output 100
```

---

### 3. add <expr> and <expr>
Add two values and display the result.

**Syntax:**
```
add <expr> and <expr>
```

**Examples:**
```
add 5 and 3
add x and 10
add n and m
```

---

### 4. subtract <expr> from <expr>
Subtract the second value from the first and display the result.

**Syntax:**
```
subtract <expr> from <expr>
```

**Examples:**
```
subtract 5 from 10
subtract 1 from x
```

---

### 5. multiply <expr> and <expr>
Multiply two values and display the result.

**Syntax:**
```
multiply <expr> and <expr>
```

**Examples:**
```
multiply 5 and 3
multiply x and 2
```

---

### 6. divide <expr> by <expr>
Divide the first value by the second and display quotient and remainder.

**Syntax:**
```
divide <expr> by <expr>
```

**Examples:**
```
divide 10 by 3
# Output:
# Quotient: 3
# Remainder: 1
```

**Note:** Division by zero displays an error message.

---

### 7. store <expr> in <var>
Assign a value to a variable.

**Syntax:**
```
store <expression> in <variable>
```

**Examples:**
```
store 10 in x
store 0 in counter
store 100 in total
```

---

### 8. show <var>
Display the name and value of a variable.

**Syntax:**
```
show <variable>
```

**Examples:**
```
show x
# Output: x = 10
```

---

### 9. add 1 to <var>
Increment a variable by 1.

**Syntax:**
```
add 1 to <variable>
```

**Examples:**
```
add 1 to counter
add 1 to n
```

**Note:** The variable must exist before incrementing.

---

### 10. help
Display the list of all available commands.

**Syntax:**
```
help
```

---

### 11. clear
Clear the screen.

**Syntax:**
```
clear
```

---

### 12. exit / quit
Exit the interpreter.

**Syntax:**
```
exit
quit
```

---

### 13. loop (Not fully implemented in this version)
Repeat a block of commands.

**Note:** Loop functionality is partially implemented. Use semicolons to separate commands on one line:
```
store 0 in n; add 1 to n; show n
```

---

### 14. if (Not fully implemented in this version)
Conditional execution.

**Note:** Conditional statements are partially implemented.

---

### 15. # (Comments)
Line comments - any line starting with `#` is ignored.

**Syntax:**
```
# This is a comment
```

**Examples:**
```
# Initialize counter
store 0 in count
# Increment by one
add 1 to count
```

---

## Expression Grammar

An expression can be:
- **Integer literal**: `0`, `42`, `-10`
- **Variable name**: `x`, `counter`, `total`

### Notes:
- All commands and variable names are **case-insensitive**
- Variable names can be up to 20 characters
- Maximum of 64 variables can be stored
- Integer values are 32-bit signed integers (-2,147,483,648 to 2,147,483,647)

---

## Error Messages

- **"Unknown command"** - Command not recognized
- **"Variable not found"** - Attempting to use an undefined variable
- **"Division by zero"** - Attempting to divide by zero
- **"Syntax error"** - Invalid command syntax

---

## Tips

1. **Case doesn't matter**: `PRINT`, `Print`, and `print` are all the same
2. **Whitespace is flexible**: Extra spaces are ignored
3. **Comments are your friend**: Use `#` to document your scripts
4. **Variables auto-create**: Using `store` creates a new variable if it doesn't exist
5. **Check your syntax**: Most errors are due to incorrect command format

---

## Examples

### Basic Arithmetic
```
>>> add 10 and 20
30
>>> subtract 5 from 15
10
>>> multiply 6 and 7
42
>>> divide 10 by 3
Quotient: 3
Remainder: 1
```

### Variable Operations
```
>>> store 100 in balance
>>> show balance
balance = 100
>>> subtract 25 from balance
75
>>> add 1 to balance
>>> show balance
balance = 101
```

### Mixed Operations
```
>>> store 5 in x
>>> store 10 in y
>>> add x and y
15
>>> multiply x and y
50
```

---

For more examples, see [test_cases.txt](test_cases.txt).
