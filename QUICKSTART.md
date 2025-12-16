# Quick Start Guide
## Getting Started with MASM32 and Irvine32

### Prerequisites Checklist

Before you begin, ensure you have:
- [ ] Windows OS installed
- [ ] Administrator access
- [ ] Internet connection for downloads

---

## Installation Steps (15 minutes)

### 1. Install MASM32 (5 minutes)

```powershell
# Download from: http://www.masm32.com/download.htm
# Run install.exe as Administrator
# Default install location: C:\masm32
```

### 2. Download Irvine32 Files (5 minutes)

Download these two files:
- `Irvine32.lib` - Library file
- `Irvine32.inc` - Include file

From: http://asmirvine.com/

### 3. Set Up Project (5 minutes)

```powershell
# Navigate to project directory
cd d:\COAL

# Copy library files
Copy-Item "path\to\Irvine32.lib" -Destination "lib\"
Copy-Item "path\to\Irvine32.inc" -Destination "include\"

# Copy Windows libraries
Copy-Item "C:\masm32\lib\kernel32.lib" -Destination "lib\"
Copy-Item "C:\masm32\lib\user32.lib" -Destination "lib\"
```

### 4. Configure Environment (2 minutes)

**Option A: Quick (Session Only)**
```powershell
$env:PATH += ";C:\masm32\bin;d:\COAL\bin"
$env:INCLUDE = "C:\masm32\include;d:\COAL\include"
$env:LIB = "C:\masm32\lib;d:\COAL\lib"
```

**Option B: Permanent (System Settings)**
1. Open System Properties → Advanced → Environment Variables
2. Add to PATH: `C:\masm32\bin` and `d:\COAL\bin`
3. Create INCLUDE: `C:\masm32\include;d:\COAL\include`
4. Create LIB: `C:\masm32\lib;d:\COAL\lib`

---

## Test Installation (2 minutes)

```powershell
# Build test program
cd d:\COAL
.\build.bat test.asm

# Run test program
.\bin\test.exe
```

**Expected Output:**
```
============================================
  MASM32 + Irvine32 Environment Test
============================================
...
All Tests PASSED!
```

---

## Your First Program (10 minutes)

### Create hello.asm

```asm
INCLUDE Irvine32.inc

.data
    greeting BYTE "Hello from Assembly!",0

.code
main PROC
    mov  edx, OFFSET greeting
    call WriteString
    call Crlf
    exit
main ENDP
END main
```

### Build and Run

```powershell
.\build.bat src\hello.asm
.\bin\hello.exe
```

---

## Common Commands

### Build a Program
```powershell
.\build.bat src\myprogram.asm
```

### Run a Program
```powershell
.\bin\myprogram.exe
```

### Clean Build Artifacts
```powershell
.\clean.ps1
```

### Manual Build (Advanced)
```powershell
# Assemble
ml /c /coff /Cp /nologo /I"include" src\program.asm

# Link
link /SUBSYSTEM:CONSOLE /LIBPATH:"lib" /OUT:bin\program.exe program.obj Irvine32.lib kernel32.lib user32.lib

# Clean
del *.obj
```

---

## Visual Studio Code Setup (Optional)

### 1. Install VS Code
Download from: https://code.visualstudio.com/

### 2. Install Extensions
Open VS Code and install:
- **MASM/TASM** (by 13xforever)
- **PowerShell** (by Microsoft)

### 3. Open Project
```
File → Open Folder → Select d:\COAL
```

### 4. Build with Keyboard Shortcut
Press `Ctrl + Shift + B` to build current file

---

## Essential Irvine32 Procedures

### Output
```asm
call WriteString     ; Display string (EDX = offset)
call WriteDec        ; Display unsigned integer (EAX = value)
call WriteInt        ; Display signed integer (EAX = value)
call WriteHex        ; Display hexadecimal (EAX = value)
call Crlf            ; Print newline
```

### Input
```asm
call ReadString      ; Read string (EDX = buffer, ECX = max chars)
call ReadInt         ; Read signed integer (returns in EAX)
call ReadDec         ; Read unsigned integer (returns in EAX)
```

### Debugging
```asm
call DumpRegs        ; Display all registers
call DumpMem         ; Display memory (ESI, ECX, EBX)
```

### Utility
```asm
call Clrscr          ; Clear screen
call WaitMsg         ; Wait for keypress
call Delay           ; Pause (EAX = milliseconds)
call Randomize       ; Initialize RNG
call Random32        ; Get random number
```

---

## Program Template

Use this template for new programs:

```asm
; ============================================
; Program: [Program Name]
; Author: [Your Name]
; Date: [Date]
; Description: [What the program does]
; ============================================

INCLUDE Irvine32.inc

; ============================================
; DATA SECTION
; ============================================
.data
    ; Declare your variables here
    message BYTE "Hello, World!",0
    number  DWORD 42

; ============================================
; CODE SECTION
; ============================================
.code
main PROC
    ; Your code here
    
    mov  edx, OFFSET message
    call WriteString
    call Crlf
    
    ; Always end with exit
    exit
main ENDP
END main
```

---

## Troubleshooting Quick Fixes

### "ml is not recognized"
```powershell
$env:PATH += ";C:\masm32\bin"
```

### "Cannot open file: Irvine32.inc"
```powershell
# Check file exists
dir include\Irvine32.inc

# Set INCLUDE path
$env:INCLUDE = "C:\masm32\include;d:\COAL\include"
```

### "Cannot open input file 'Irvine32.lib'"
```powershell
# Check file exists
dir lib\Irvine32.lib

# Set LIB path
$env:LIB = "C:\masm32\lib;d:\COAL\lib"
```

### Program crashes
- Missing `exit` at end of main PROC
- Unbalanced PUSH/POP operations
- Invalid memory access
- Check with `call DumpRegs` for debugging

---

## Next Steps

1. ✅ Complete installation
2. ✅ Build and run test.asm
3. ✅ Create your first program
4. 📚 Read `docs/IRVINE32_REFERENCE.md` for all procedures
5. 📚 Review `docs/SETUP_GUIDE.md` for detailed instructions
6. 💻 Start writing assembly programs in `src/` directory

---

## Resources

| Resource | Link |
|----------|------|
| **Irvine Website** | http://asmirvine.com/ |
| **MASM32 SDK** | http://www.masm32.com/ |
| **Intel Manuals** | https://software.intel.com/content/www/us/en/develop/articles/intel-sdm.html |
| **x86 Reference** | https://www.felixcloutier.com/x86/ |

---

## Project Structure

```
d:\COAL\
├── src\           # Your .asm source files
├── lib\           # Library files (.lib)
├── include\       # Include files (.inc)
├── bin\           # Compiled executables (.exe)
├── docs\          # Documentation
├── .vscode\       # VS Code configuration
├── build.bat      # Build script
├── test.asm       # Test program
├── clean.ps1      # Cleanup script
└── README.md      # Main documentation
```

---

**You're ready to start programming in x86 Assembly!** 🎉

For detailed documentation, see:
- `README.md` - Main documentation
- `docs/SETUP_GUIDE.md` - Detailed setup instructions  
- `docs/IRVINE32_REFERENCE.md` - Complete procedure reference
