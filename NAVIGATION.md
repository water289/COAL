# 🧭 Navigation Guide - Where to Find Everything

## Quick Navigation Index

**Number of runnable commands implemented: 15**

---

## 🎯 I Want To...

### ...Build the Interpreter
```
📄 build.bat
   └─ Run this to build the project
   
📄 src/interpreter.asm
   └─ Main source code (auto-built by build.bat)
```

**Action**: `build.bat`

---

### ...Learn the Commands
```
📄 QUICKREF.md ⭐ START HERE
   └─ Quick reference card with all commands
   
📄 COMMANDS.md
   └─ Complete command reference with examples
   
📄 test_cases.txt
   └─ Test cases and example sessions
```

**Best Path**: QUICKREF.md → COMMANDS.md → test_cases.txt

---

### ...Understand the Code
```
📄 src/interpreter.asm ⭐ THE SOURCE
   └─ 850+ lines of assembly code
   
📄 PROJECT_README.md
   └─ Technical deep dive and architecture
   
📄 FILE_INDEX.md
   └─ Complete file listing and structure
```

**Best Path**: PROJECT_README.md → src/interpreter.asm

---

### ...Get Started Quickly
```
📄 README.md ⭐ START HERE
   └─ Project overview and quick start
   
📄 DELIVERY.md
   └─ Complete project summary
   
📄 STATUS.md
   └─ Project completion status
```

**Best Path**: README.md → DELIVERY.md

---

### ...Test the Interpreter
```
📄 test_cases.txt ⭐ ALL TESTS HERE
   └─ 15 comprehensive test cases
   
🔧 bin/interpreter.exe
   └─ Run after building
```

**Action**: 
1. `build.bat`
2. `bin\interpreter.exe`
3. Use test_cases.txt examples

---

### ...Troubleshoot Problems
```
📄 PROJECT_README.md (Troubleshooting section)
   └─ Common issues and solutions
   
📄 build.bat
   └─ Checks for MASM32 installation
   
📄 docs/SETUP_GUIDE.md
   └─ Environment setup help
```

**Action**: Read PROJECT_README.md troubleshooting section

---

### ...Add New Commands
```
📄 src/interpreter.asm
   └─ Line 300-600: ExecuteCommand PROC
   └─ Add new command handler
   
📄 PROJECT_README.md
   └─ Section: Implementation Details
```

**Best Path**: Study existing commands in interpreter.asm

---

### ...Clean Build Artifacts
```
📄 clean.bat ⭐ RUN THIS
   └─ Removes .obj and .exe files
```

**Action**: `clean.bat`

---

## 📚 Documentation Roadmap

### Beginner Path 🟢
```
1. STATUS.md          (What is this project?)
   ↓
2. README.md          (Quick overview)
   ↓
3. QUICKREF.md        (Command quick reference)
   ↓
4. COMMANDS.md        (Command details)
   ↓
5. test_cases.txt     (Try examples)
```

### Advanced Path 🟡
```
1. DELIVERY.md        (Complete project summary)
   ↓
2. PROJECT_README.md  (Technical architecture)
   ↓
3. src/interpreter.asm (Source code)
   ↓
4. FILE_INDEX.md      (File structure)
```

### Developer Path 🔴
```
1. PROJECT_README.md  (Architecture)
   ↓
2. src/interpreter.asm (Study procedures)
   ↓
3. build.bat          (Build process)
   ↓
4. Modify and extend  (Add features)
```

---

## 📂 File Directory Quick Reference

### Root Level (d:\COAL\)
```
build.bat              → Build script ⭐
clean.bat              → Clean script
README.md              → Project overview ⭐
COMMANDS.md            → Command reference ⭐
QUICKREF.md            → Quick reference ⭐
DELIVERY.md            → Project summary
PROJECT_README.md      → Technical docs
STATUS.md              → Completion status
FILE_INDEX.md          → File listing
NAVIGATION.md          → This file
test_cases.txt         → Test cases ⭐
```

### src/ Directory
```
interpreter.asm        → Main source code ⭐⭐⭐
sample.asm             → Sample program
README.md              → Source directory info
```

### bin/ Directory
```
interpreter.exe        → Built executable (after build) ⭐
README.md              → Binary directory info
```

### lib/ Directory
```
Irvine32.lib           → Irvine32 library ⭐
README.md              → Library directory info
```

### include/ Directory
```
Irvine32.inc           → Irvine32 headers ⭐
SmallWin.inc           → Windows API declarations
GraphWin.inc           → Graphics functions
Macros.inc             → Utility macros
README.md              → Include directory info
```

### docs/ Directory
```
IRVINE32_REFERENCE.md  → Irvine32 function reference
SETUP_GUIDE.md         → Environment setup
```

---

## 🎯 Common Tasks - Quick Commands

### Build
```cmd
cd d:\COAL
build.bat
```

### Run
```cmd
bin\interpreter.exe
```

### Clean
```cmd
clean.bat
```

### Rebuild
```cmd
clean.bat
build.bat
```

### Test
```cmd
bin\interpreter.exe
# Then copy/paste from test_cases.txt
```

---

## 📖 Documentation by Purpose

### Quick Start
- **README.md** - First file to read
- **QUICKREF.md** - Quick command reference
- **DELIVERY.md** - What you get

### Learning
- **COMMANDS.md** - All command syntax
- **test_cases.txt** - Examples and tests
- **PROJECT_README.md** - How it works

### Reference
- **FILE_INDEX.md** - All files listed
- **STATUS.md** - Completion status
- **NAVIGATION.md** - This guide

### Development
- **src/interpreter.asm** - Source code
- **PROJECT_README.md** - Architecture
- **build.bat** - Build process

---

## 🔍 Search Guide

### Find Command Syntax
```
Look in: QUICKREF.md or COMMANDS.md
```

### Find Example Usage
```
Look in: test_cases.txt
```

### Find Technical Details
```
Look in: PROJECT_README.md
```

### Find File Information
```
Look in: FILE_INDEX.md
```

### Find Procedure Implementation
```
Look in: src/interpreter.asm
```

### Find Build Instructions
```
Look in: README.md or PROJECT_README.md
```

---

## ⭐ Must-Read Files

### Top 5 Essential Files
1. **README.md** - Start here
2. **QUICKREF.md** - Quick command reference
3. **src/interpreter.asm** - The source code
4. **test_cases.txt** - Examples
5. **PROJECT_README.md** - Technical guide

### Top 3 for Quick Start
1. **README.md**
2. **build.bat**
3. **QUICKREF.md**

### Top 3 for Learning
1. **COMMANDS.md**
2. **test_cases.txt**
3. **PROJECT_README.md**

---

## 🗺️ Visual Navigation Map

```
START HERE
    │
    ├─── Quick Start? ────────────> README.md
    │                                   │
    │                                   ├─> build.bat
    │                                   ├─> QUICKREF.md
    │                                   └─> Run interpreter
    │
    ├─── Learn Commands? ─────────> COMMANDS.md
    │                                   │
    │                                   ├─> QUICKREF.md
    │                                   └─> test_cases.txt
    │
    ├─── Understand Code? ────────> PROJECT_README.md
    │                                   │
    │                                   ├─> src/interpreter.asm
    │                                   └─> FILE_INDEX.md
    │
    ├─── Test It? ────────────────> build.bat
    │                                   │
    │                                   ├─> bin/interpreter.exe
    │                                   └─> test_cases.txt
    │
    └─── Add Features? ───────────> src/interpreter.asm
                                        │
                                        ├─> PROJECT_README.md
                                        └─> build.bat
```

---

## 💡 Pro Tips

### Tip 1: Start Small
```
1. Read README.md (5 minutes)
2. Read QUICKREF.md (2 minutes)
3. Run build.bat (30 seconds)
4. Try interpreter (5 minutes)
```

### Tip 2: Test First
```
1. Build with build.bat
2. Run bin/interpreter.exe
3. Copy test cases from test_cases.txt
4. See it work!
```

### Tip 3: Learn by Doing
```
1. Read COMMANDS.md
2. Try each command in interpreter
3. Look at implementation in interpreter.asm
4. Modify and experiment
```

### Tip 4: Use Documentation Hierarchy
```
Quick Answer    → QUICKREF.md
Detailed Answer → COMMANDS.md
Deep Dive       → PROJECT_README.md
Source Truth    → interpreter.asm
```

---

## 🎯 By User Type

### Casual User
```
1. README.md
2. build.bat
3. bin/interpreter.exe
4. QUICKREF.md
```

### Student
```
1. README.md
2. COMMANDS.md
3. test_cases.txt
4. PROJECT_README.md
5. src/interpreter.asm
```

### Developer
```
1. DELIVERY.md
2. PROJECT_README.md
3. src/interpreter.asm
4. build.bat
```

### Instructor
```
1. STATUS.md
2. PROJECT_README.md
3. test_cases.txt
4. FILE_INDEX.md
```

---

## 📍 You Are Here

```
d:\COAL\
    │
    ├── ⭐ START: README.md
    ├── 🚀 BUILD: build.bat
    ├── 📖 LEARN: COMMANDS.md
    ├── 🧪 TEST: test_cases.txt
    ├── 💻 CODE: src/interpreter.asm
    └── 🗺️ GUIDE: NAVIGATION.md (you are here)
```

---

## 🎊 Ready to Start?

### Fastest Path to Running Code
```
1. cd d:\COAL
2. build.bat
3. bin\interpreter.exe
```

### Fastest Path to Understanding
```
1. Open: README.md
2. Then: QUICKREF.md
3. Then: Try interpreter
```

### Fastest Path to Mastery
```
1. Read: PROJECT_README.md
2. Study: src/interpreter.asm
3. Modify: Add new command
4. Test: build.bat and run
```

---

**Choose your path and start exploring!** 🚀

---

## 📞 Still Lost?

### Quick Answers
- **What is this?** → STATUS.md
- **How to build?** → README.md
- **What commands?** → QUICKREF.md
- **How does it work?** → PROJECT_README.md
- **All files?** → FILE_INDEX.md

---

**Happy Navigating!** 🧭✨
