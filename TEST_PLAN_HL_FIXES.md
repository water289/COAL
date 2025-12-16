# Test Plan for interpreter_hl.asm Fixes

## Prerequisites
- MASM32 SDK installed at `C:\masm32\`
- PATH includes `C:\masm32\bin`

## Build Instructions

```batch
cd D:\COAL
build.bat src\interpreter_hl.asm
```

Or manually:
```batch
cd src
ml /c /coff /Cp /Zd /I"..\include" interpreter_hl.asm
link /SUBSYSTEM:CONSOLE /LIBPATH:"..\lib" /OUT:..\bin\interpreter_hl.exe interpreter_hl.obj Irvine32.lib kernel32.lib user32.lib
del interpreter_hl.obj
cd ..
```

## Test Cases

### Test 1: Basic Variable Storage
```
>>> store 5 in n
OK
>>> show n
5
>>> exit
```

**Expected**: Should store value 5 in variable n and display it correctly without exiting prematurely.

### Test 2: Increment Operations
```
>>> store 0 in counter
OK
>>> increment counter
OK
>>> show counter
1
>>> increment counter by 10
OK
>>> show counter
11
>>> exit
```

**Expected**: All increment operations should work correctly.

### Test 3: Decrement Operations
```
>>> store 100 in value
OK
>>> decrement value
OK
>>> show value
99
>>> decrement value by 50
OK
>>> show value
49
>>> exit
```

**Expected**: All decrement operations should work correctly.

### Test 4: Print Operations
```
>>> print 42
42
>>> print 7 3 times
7
7
7
>>> exit
```

**Expected**: Print should display values correctly with optional repetition.

### Test 5: Expression Evaluation
```
>>> store 10 in x
OK
>>> store 20 in y
OK
>>> print x
10
>>> print y
20
>>> exit
```

**Expected**: Variables should be evaluated correctly when used in print commands.

### Test 6: Case Insensitivity
```
>>> STORE 5 in test
OK
>>> Show TEST
5
>>> INCREMENT test
OK
>>> show TeSt
6
>>> exit
```

**Expected**: Commands and variable names should be case-insensitive.

### Test 7: REPL Continuity (Critical Fix Test)
```
>>> store 1 in a
OK
>>> store 2 in b
OK
>>> store 3 in c
OK
>>> show a
1
>>> show b
2
>>> show c
3
>>> clear
OK
>>> show a
ERROR: Variable not defined: a
>>> exit
```

**Expected**: The REPL should NOT exit prematurely after any command. This was the main bug caused by stack corruption.

### Test 8: Error Handling
```
>>> show undefined_var
ERROR: Variable not defined: undefined_var
>>> store 5
ERROR: Invalid syntax!
Example: store 0 in n
>>> unknown_command
ERROR: Unrecognised command!
Type 'help' for available commands.
>>> exit
```

**Expected**: Error messages should display without crashing the interpreter.

### Test 9: Help Command
```
>>> help
=== Human Language Interpreter ===
Available Commands:
[... full help text ...]
>>> exit
```

**Expected**: Help should display completely and return to REPL prompt.

### Test 10: Piped Input (Automated Test)
Create a test file `test_hl_commands.txt`:
```
store 5 in n
show n
increment n
show n
decrement n by 2
show n
exit
```

Run:
```batch
type test_hl_commands.txt | bin\interpreter_hl.exe
```

**Expected Output**:
```
>>> OK
>>> 5
>>> OK
>>> 6
>>> OK
>>> 4
>>> 
```

## What Was Fixed

### 1. CompareStringsCase Parameter Order
**Before**: `push OFFSET keyword; push tokenPtr`
**After**: `push tokenPtr; push OFFSET keyword`

This standardization ensures consistent comparison behavior across all command matching.

### 2. FindVariable Calling Convention
**Before**: Used various patterns with push/pop
**After**: Consistent use of ESI register for parameter passing

This eliminates stack corruption that caused premature REPL exit.

### 3. StringToInt Stack Management
**Before**: Direct call without preserving EAX
**After**: `push eax; call StringToInt; pop eax` where needed

Prevents register corruption during numeric parsing.

### 4. Reduced Stack Operations
- Removed unnecessary push/pop in `StoreVariable` copy loop
- Removed ESI from push/pop in `EvaluateExpression`
- Added proper register preservation where needed

## Success Criteria

✅ All test cases should complete without crashes
✅ REPL should remain active until explicit `exit` command
✅ Variable storage and retrieval should work correctly
✅ All arithmetic operations (increment/decrement) should work
✅ Error messages should display without crashing
✅ Case-insensitive command matching should work
✅ Help command should display and return to prompt

## Known Issues Before Fix

- ❌ REPL exiting prematurely after simple commands
- ❌ Stack corruption from inconsistent calling conventions
- ❌ Variable lookup failures due to parameter order mismatch
- ❌ Register corruption in numeric evaluation

## Known Issues After Fix

- ✅ All major issues resolved
- ⚠️ Limited to integer arithmetic (by design)
- ⚠️ Maximum 64 variables (by design)
- ⚠️ Variable names limited to 20 characters (by design)
