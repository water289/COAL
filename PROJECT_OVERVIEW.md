# COAL - x86 Assembly Development Environment
## Complete MASM32 + Irvine32 Setup

---

## 📁 Project Structure

```
d:\COAL\
│
├── 📂 src/                      # Source code directory
│   ├── sample.asm              # Sample program with multiple features
│   └── README.md               # Source directory guide
│
├── 📂 lib/                      # Library files
│   ├── Irvine32.lib            # [TO INSTALL] Main Irvine32 library
│   ├── kernel32.lib            # [TO INSTALL] Windows kernel library
│   ├── user32.lib              # [TO INSTALL] Windows user library
│   └── README.md               # Library installation instructions
│
├── 📂 include/                  # Include files
│   ├── Irvine32.inc            # [TO INSTALL] Irvine32 header file
│   └── README.md               # Include files guide
│
├── 📂 bin/                      # Compiled executables
│   └── README.md               # Binary directory info
│
├── 📂 docs/                     # Documentation
│   ├── SETUP_GUIDE.md          # Detailed installation guide
│   └── IRVINE32_REFERENCE.md   # Complete Irvine32 API reference
│
├── 📂 .vscode/                  # VS Code configuration
│   ├── settings.json           # Editor settings
│   ├── tasks.json              # Build tasks
│   ├── extensions.json         # Recommended extensions
│   └── COAL.code-workspace     # Workspace file
│
├── 📄 README.md                 # Main documentation
├── 📄 QUICKSTART.md             # Quick start guide
├── 📄 PROJECT_OVERVIEW.md       # This file
├── 📄 test.asm                  # Environment test program
├── 📄 build.bat                 # Build script
├── 📄 clean.ps1                 # Cleanup script
└── 📄 .gitignore                # Git ignore rules

```

---

## 🎯 Purpose

This repository provides a complete, ready-to-use development environment for learning and developing x86 Assembly Language programs using:

- **MASM32** - Microsoft Macro Assembler (32-bit)
- **Irvine32 Library** - Simplified I/O library by Kip Irvine
- **Windows API** - For system-level programming

---

## ✨ Features

### 📝 Complete Documentation
- **README.md** - Comprehensive main documentation
- **QUICKSTART.md** - Get started in 15 minutes
- **SETUP_GUIDE.md** - Detailed step-by-step installation
- **IRVINE32_REFERENCE.md** - Full API documentation with examples

### 🛠️ Build Tools
- **build.bat** - Automated build script with error checking
- **clean.ps1** - PowerShell cleanup utility
- **VS Code Tasks** - Integrated build tasks (Ctrl+Shift+B)

### 💻 Sample Programs
- **test.asm** - Environment verification program
- **sample.asm** - Feature-rich demonstration program
  - Arithmetic operations
  - Array processing
  - Fibonacci sequence
  - Menu-driven interface

### ⚙️ IDE Integration
- Visual Studio Code workspace configuration
- Syntax highlighting support
- Build task integration
- Recommended extensions list

### 📚 Learning Resources
- Comprehensive Irvine32 procedure reference
- Usage examples for all common operations
- Program templates and coding patterns
- Troubleshooting guides

---

## 🚀 Quick Start

### 1. Prerequisites

- Windows OS (7/8/10/11)
- Administrator access
- Text editor (VS Code recommended)

### 2. Install MASM32

```powershell
# Download from: http://www.masm32.com/
# Run install.exe as Administrator
# Install to: C:\masm32
```

### 3. Install Irvine32

```powershell
# Download from: http://asmirvine.com/
# Copy files to project:
Copy-Item "Irvine32.lib" -Destination "d:\COAL\lib\"
Copy-Item "Irvine32.inc" -Destination "d:\COAL\include\"

# Copy Windows libraries:
Copy-Item "C:\masm32\lib\kernel32.lib" -Destination "d:\COAL\lib\"
Copy-Item "C:\masm32\lib\user32.lib" -Destination "d:\COAL\lib\"
```

### 4. Configure Environment

```powershell
# Quick setup (temporary):
$env:PATH += ";C:\masm32\bin;d:\COAL\bin"
$env:INCLUDE = "C:\masm32\include;d:\COAL\include"
$env:LIB = "C:\masm32\lib;d:\COAL\lib"
```

### 5. Test Installation

```powershell
cd d:\COAL
.\build.bat test.asm
.\bin\test.exe
```

---

## 📖 Documentation Guide

| Document | Purpose | When to Read |
|----------|---------|--------------|
| **QUICKSTART.md** | Get started immediately | First time setup |
| **README.md** | Main reference | General usage |
| **SETUP_GUIDE.md** | Detailed installation | Troubleshooting setup |
| **IRVINE32_REFERENCE.md** | API documentation | Writing code |
| **src/README.md** | Source code guide | Creating programs |
| **lib/README.md** | Library installation | Setting up libraries |

---

## 🔧 Common Tasks

### Build a Program
```powershell
.\build.bat src\myprogram.asm
```

### Run a Program
```powershell
.\bin\myprogram.exe
```

### Build and Run
```powershell
.\build.bat src\myprogram.asm ; .\bin\myprogram.exe
```

### Clean Build Artifacts
```powershell
.\clean.ps1
```

### Using VS Code
```powershell
# Open project
code .

# Build current file
Ctrl + Shift + B

# Or use Command Palette
Ctrl + Shift + P → "Run Build Task"
```

---

## 📝 Creating Your First Program

### 1. Create a new file: `src/hello.asm`

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

### 2. Build it

```powershell
.\build.bat src\hello.asm
```

### 3. Run it

```powershell
.\bin\hello.exe
```

---

## 🎓 Learning Path

### Beginner
1. ✅ Install and test environment (`test.asm`)
2. ✅ Create "Hello World" program
3. ✅ Learn basic I/O (WriteString, ReadInt, WriteDec)
4. ✅ Understand registers and data types
5. ✅ Practice arithmetic operations

### Intermediate
1. ✅ Study `sample.asm` for structured programs
2. ✅ Learn procedures and stack operations
3. ✅ Work with arrays and strings
4. ✅ Implement loops and conditionals
5. ✅ Master debugging with DumpRegs

### Advanced
1. ✅ Windows API integration
2. ✅ File I/O operations
3. ✅ Advanced data structures
4. ✅ Optimization techniques
5. ✅ Mixed-language programming

---

## 🔍 Troubleshooting

### Installation Issues

| Problem | Solution |
|---------|----------|
| `ml` not found | Add `C:\masm32\bin` to PATH |
| Irvine32.inc missing | Check `include\` folder, set INCLUDE variable |
| Irvine32.lib missing | Check `lib\` folder, set LIB variable |
| Build script fails | Run as Administrator, check paths |

### Runtime Issues

| Problem | Solution |
|---------|----------|
| Program crashes | Check for missing `exit`, unbalanced PUSH/POP |
| Wrong output | Use `call DumpRegs` to debug registers |
| Infinite loop | Add breakpoints, check loop conditions |
| Access violation | Verify array bounds, pointer validity |

See **SETUP_GUIDE.md** for detailed troubleshooting.

---

## 📚 Resources

### Official Documentation
- **Irvine Website**: http://asmirvine.com/
- **MASM32 Home**: http://www.masm32.com/
- **MASM32 Forum**: http://www.masm32.com/board/

### Reference Manuals
- **Intel x86 Manual**: https://software.intel.com/content/www/us/en/develop/articles/intel-sdm.html
- **x86 Instruction Reference**: https://www.felixcloutier.com/x86/
- **Windows API Reference**: https://docs.microsoft.com/en-us/windows/win32/api/

### Learning Resources
- **Irvine's Textbook**: "Assembly Language for x86 Processors"
- **Stack Overflow**: Tag `[masm]` or `[x86]`
- **YouTube**: Search "x86 assembly tutorial"

---

## 🎯 Sample Programs Included

### test.asm
**Purpose**: Verify environment setup

**Features**:
- String output demonstration
- Numeric output (decimal, hex, binary)
- Register dump display
- User input handling
- All basic Irvine32 procedures

**Use**: First program to run after installation

### sample.asm
**Purpose**: Demonstrate program structure

**Features**:
- Menu-driven interface
- Arithmetic operations (add, subtract, multiply)
- Array processing and sum calculation
- Fibonacci sequence generation
- Procedure definitions
- Stack operations
- Loop and conditional statements

**Use**: Reference for writing structured programs

---

## 🛡️ Best Practices

### Code Organization
```asm
; 1. Header comments (purpose, author, date)
; 2. INCLUDE directives
; 3. .data section (variables)
; 4. .code section (procedures)
; 5. main PROC (entry point)
; 6. Helper procedures
; 7. END directive
```

### Naming Conventions
- **Variables**: descriptive names (counter, userName, total)
- **Labels**: camelCase or snake_case
- **Procedures**: PascalCase (CalculateSum, DisplayMenu)
- **Constants**: UPPERCASE (MAX_SIZE, BUFFER_LEN)

### Comments
- Explain WHY, not WHAT
- Document procedure parameters and returns
- Add section dividers for clarity
- Keep comments up-to-date

### Error Handling
- Check return flags (ZF, CF, OF)
- Validate user input
- Handle edge cases
- Use defensive programming

---

## 🤝 Contributing

This is a learning environment. Feel free to:
- Add your own programs to `src/`
- Improve documentation
- Share interesting examples
- Report issues or suggestions

---

## 📜 License

Educational use. MASM32 and Irvine32 have their own respective licenses.

---

## 📞 Support

For help:
1. Check **QUICKSTART.md** for common issues
2. Read **SETUP_GUIDE.md** troubleshooting section
3. Search MASM32 forums
4. Ask on Stack Overflow with `[masm]` tag

---

## ✅ Checklist

### Installation Complete
- [ ] MASM32 installed at `C:\masm32`
- [ ] Irvine32.lib in `lib/` folder
- [ ] Irvine32.inc in `include/` folder
- [ ] Environment variables configured
- [ ] test.asm builds and runs successfully

### Ready to Code
- [ ] Understand directory structure
- [ ] Know how to use build.bat
- [ ] Reviewed sample.asm
- [ ] Read IRVINE32_REFERENCE.md
- [ ] Created first custom program

### Next Steps
- [ ] Complete tutorial exercises
- [ ] Implement data structures (stack, queue, linked list)
- [ ] Practice algorithm implementation
- [ ] Explore Windows API integration
- [ ] Build a complete application

---

**Happy Assembly Programming! 🚀**

Last Updated: December 7, 2025
