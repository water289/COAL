# Test Commands for interpreter_hl.exe

## Quick Test (Single Commands)

### Basic Variable Operations
```powershell
# Store a value
echo "store 5 in n" | bin\interpreter_hl.exe

# Show a value  
echo "show n" | bin\interpreter_hl.exe

# Increment
echo "increment n" | bin\interpreter_hl.exe

# Decrement
echo "decrement n by 2" | bin\interpreter_hl.exe
```

### Comprehensive Test File
```powershell
# Run multi-line test
Get-Content test_hl_commands.txt | bin\interpreter_hl.exe
```

## Manual Interactive Testing

### Test 1: Basic REPL
```
bin\interpreter_hl.exe
>>> help
>>> store 10 in x
>>> show x
>>> exit
```

### Test 2: Arithmetic
```
>>> store 100 in value
>>> decrement value by 25
>>> show value
>>> increment value by 50
>>> show value
>>> exit
```

### Test 3: Multiple Variables
```
>>> store 1 in a
>>> store 2 in b
>>> store 3 in c
>>> show a
>>> show b
>>> show c
>>> clear
>>> show a
>>> exit
```

### Test 4: Print with Repetition
```
>>> print 42
>>> print 7 3 times
>>> exit
```

### Test 5: Case Insensitivity
```
>>> STORE 5 in TEST
>>> Show TEST
>>> INCREMENT test
>>> show TeSt
>>> exit
```

## Automated Test Scripts

### Create test files for different scenarios

#### test_basic.txt
```
store 0 in counter
increment counter
show counter
exit
```

#### test_arithmetic.txt
```
store 100 in num
decrement num by 30
show num
increment num by 50
show num
exit
```

#### test_print.txt
```
print 42
print 5 3 times
store 99 in x
print x
exit
```

### Run tests
```powershell
# Test basic operations
Get-Content test_basic.txt | bin\interpreter_hl.exe

# Test arithmetic
Get-Content test_arithmetic.txt | bin\interpreter_hl.exe

# Test print
Get-Content test_print.txt | bin\interpreter_hl.exe
```

## Debugging Commands

### Check if executable exists and timestamp
```powershell
Get-Item bin\interpreter_hl.exe | Select-Object Name, Length, LastWriteTime
```

### Verify MASM32 installation
```powershell
Test-Path "D:\masm32\bin\ml.exe"
```

### Compare old vs new executable
```powershell
# Get file hashes to see if rebuild actually changed anything
Get-FileHash bin\interpreter_hl.exe
```

### Test single command output
```powershell
# This should output "OK" if working
echo "store 5 in n" | bin\interpreter_hl.exe 2>&1 | Select-Object -First 5
```

## Build Commands

### Full rebuild from source
```powershell
# Add MASM32 to PATH
$env:PATH += ";D:\masm32\bin"

# Clean old files
Remove-Item bin\interpreter_hl.exe -ErrorAction SilentlyContinue

# Build
cd src
ml /c /coff /Cp /Zd /I"..\include" interpreter_hl.asm
link /SUBSYSTEM:CONSOLE /LIBPATH:"..\lib" /OUT:..\bin\interpreter_hl.exe interpreter_hl.obj Irvine32.lib kernel32.lib user32.lib
del interpreter_hl.obj
cd ..
```

### Quick rebuild
```powershell
$env:PATH += ";D:\masm32\bin"; cd src; ml /c /coff /Cp /Zd /I"..\include" interpreter_hl.asm; link /SUBSYSTEM:CONSOLE /LIBPATH:"..\lib" /OUT:..\bin\interpreter_hl.exe interpreter_hl.obj Irvine32.lib kernel32.lib user32.lib; del interpreter_hl.obj; cd ..
```

## Expected Outputs

### Successful "store 5 in n" command:
```
>>> OK
>>> 
```

### Successful "show n" command:
```
>>> 5
>>> 
```

### Help command:
```
>>> === Human Language Interpreter ===
Available Commands:
[... full help text ...]
>>> 
```

## Current Bug Status

❌ **Known Issue**: The current build enters an infinite loop showing `>>>` prompts without processing input.
This indicates a problem with the main REPL loop or command processing.

The bug appears to be related to:
- Stack corruption in the main loop
- Incorrect return from command processing
- exitFlag not being checked correctly
