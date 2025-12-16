# 📁 Complete Directory Structure
## COAL x86 Assembly Environment

```
d:\COAL\
│
├── 📄 INDEX.md                     ⭐ START HERE - Documentation index
├── 📄 SETUP_COMPLETE.md            ⭐ Environment overview & checklist
├── 📄 QUICKSTART.md                ⭐ 15-minute setup guide
├── 📄 README.md                    📖 Main documentation & reference
├── 📄 PROJECT_OVERVIEW.md          📖 Complete project guide
├── 📄 INSTALL_CHECKLIST.md         ✅ Installation verification
├── 📄 DOWNLOADS.md                 📥 Download links & resources
├── 📄 .gitignore                   🔧 Git configuration
│
├── 🔨 build.bat                    🔧 Build script (main)
├── 🔨 clean.ps1                    🔧 Cleanup utility
├── 📝 test.asm                     💻 Environment test program
│
├── 📂 src/                         💻 Source Code Directory
│   ├── 📝 sample.asm              💡 Feature demonstration program
│   └── 📄 README.md               📖 Source directory guide
│
├── 📂 lib/                         📚 Library Files
│   ├── 🔧 Irvine32.lib            ⚠️  [TO INSTALL] Main library
│   ├── 🔧 kernel32.lib            ⚠️  [TO INSTALL] Windows kernel
│   ├── 🔧 user32.lib              ⚠️  [TO INSTALL] Windows UI
│   └── 📄 README.md               📖 Library installation guide
│
├── 📂 include/                     📑 Include Files
│   ├── 📑 Irvine32.inc            ⚠️  [TO INSTALL] Main header
│   └── 📄 README.md               📖 Include files guide
│
├── 📂 bin/                         ⚙️  Compiled Executables
│   └── 📄 README.md               📖 Binary directory info
│
├── 📂 docs/                        📚 Documentation
│   ├── 📘 SETUP_GUIDE.md          📖 Detailed installation guide
│   └── 📗 IRVINE32_REFERENCE.md   📖 Complete API reference
│
└── 📂 .vscode/                     🎨 VS Code Configuration
    ├── ⚙️  settings.json          🔧 Editor settings
    ├── ⚙️  tasks.json             🔧 Build tasks
    ├── ⚙️  extensions.json        🔧 Recommended extensions
    └── ⚙️  COAL.code-workspace    🔧 Workspace file
```

---

## 📊 File Statistics

### Total Files: 30+

**Documentation:** 15 files
- Setup & Installation: 6
- Reference & Learning: 5
- Directory Guides: 4

**Source Code:** 2 files
- test.asm (beginner)
- src/sample.asm (intermediate)

**Build Scripts:** 2 files
- build.bat (Windows batch)
- clean.ps1 (PowerShell)

**Configuration:** 5 files
- .gitignore
- 4 VS Code config files

---

## 📋 File Purposes

### 📄 Documentation Files

| File | Size | Purpose | Priority |
|------|------|---------|----------|
| **INDEX.md** | 15 KB | Documentation navigator | ⭐⭐⭐ |
| **SETUP_COMPLETE.md** | 12 KB | Quick overview | ⭐⭐⭐ |
| **QUICKSTART.md** | 10 KB | Fast setup guide | ⭐⭐⭐ |
| **README.md** | 20 KB | Main reference | ⭐⭐⭐ |
| **PROJECT_OVERVIEW.md** | 18 KB | Project architecture | ⭐⭐ |
| **INSTALL_CHECKLIST.md** | 14 KB | Setup verification | ⭐⭐⭐ |
| **DOWNLOADS.md** | 12 KB | Download resources | ⭐⭐⭐ |
| **docs/SETUP_GUIDE.md** | 25 KB | Detailed installation | ⭐⭐ |
| **docs/IRVINE32_REFERENCE.md** | 35 KB | API documentation | ⭐⭐⭐ |

### 💻 Source Files

| File | Lines | Purpose | Level |
|------|-------|---------|-------|
| **test.asm** | ~150 | Environment test | Beginner |
| **src/sample.asm** | ~250 | Feature demo | Intermediate |

### 🔧 Build Scripts

| File | Type | Purpose |
|------|------|---------|
| **build.bat** | Batch | Automated build |
| **clean.ps1** | PowerShell | Cleanup utility |

### ⚙️  Configuration

| File | Format | Purpose |
|------|--------|---------|
| **.gitignore** | Text | Git exclusions |
| **.vscode/settings.json** | JSON | Editor settings |
| **.vscode/tasks.json** | JSON | Build tasks |
| **.vscode/extensions.json** | JSON | Extension recommendations |
| **.vscode/COAL.code-workspace** | JSON | Workspace config |

---

## 🎯 Directory Purposes

### 📂 src/ - Source Code
**Purpose:** Store your assembly source files (.asm)

**Contents:**
- sample.asm - Demonstration program
- Your custom programs

**Usage:**
```powershell
# Create new program
New-Item src\myprogram.asm

# Build program
.\build.bat src\myprogram.asm
```

---

### 📂 lib/ - Libraries
**Purpose:** Store library files (.lib)

**Required Files:**
- ⚠️  Irvine32.lib (download from asmirvine.com)
- ⚠️  kernel32.lib (copy from C:\masm32\lib\)
- ⚠️  user32.lib (copy from C:\masm32\lib\)

**Installation:**
```powershell
Copy-Item "C:\masm32\lib\kernel32.lib" -Destination "lib\"
Copy-Item "C:\masm32\lib\user32.lib" -Destination "lib\"
```

---

### 📂 include/ - Include Files
**Purpose:** Store include files (.inc)

**Required Files:**
- ⚠️  Irvine32.inc (download from asmirvine.com)

**Optional:**
- windows.inc
- masm32.inc

**Usage in Code:**
```asm
INCLUDE Irvine32.inc
```

---

### 📂 bin/ - Executables
**Purpose:** Store compiled programs (.exe)

**Auto-Generated:**
- Executables created by build.bat
- Example: test.exe, sample.exe

**Git:** .exe files are ignored via .gitignore

---

### 📂 docs/ - Documentation
**Purpose:** Detailed reference materials

**Files:**
- SETUP_GUIDE.md (30+ pages)
- IRVINE32_REFERENCE.md (50+ pages)

**Usage:** Reference while coding

---

### 📂 .vscode/ - VS Code Config
**Purpose:** IDE integration

**Files:**
- settings.json - Editor behavior
- tasks.json - Build tasks (Ctrl+Shift+B)
- extensions.json - Recommended plugins
- COAL.code-workspace - Workspace settings

---

## 🔍 File Relationships

### Build Process Flow
```
source.asm
    ↓
build.bat
    ↓
    ├─→ ml.exe (assembler)
    │   ├─→ include/Irvine32.inc
    │   └─→ creates .obj file
    ↓
link.exe (linker)
    ├─→ lib/Irvine32.lib
    ├─→ lib/kernel32.lib
    ├─→ lib/user32.lib
    └─→ creates bin/program.exe
```

### Documentation Flow
```
New User
    ↓
INDEX.md ─────→ Find topic
    ↓
SETUP_COMPLETE.md ─→ Overview
    ↓
QUICKSTART.md ─────→ Install
    ↓
INSTALL_CHECKLIST.md ─→ Verify
    ↓
README.md ─────────→ Reference
    ↓
IRVINE32_REFERENCE.md ─→ Code
```

---

## 📦 Size Information

### Total Project Size: ~500 KB
- Documentation: ~200 KB
- Sample Code: ~50 KB
- Configuration: ~10 KB
- Build Scripts: ~10 KB

### After Installation:
- With libraries: ~1 MB
- With MASM32: ~100 MB (separate install)
- With executables: varies

---

## 🎨 File Icons Legend

| Icon | Meaning |
|------|---------|
| 📄 | Documentation file |
| 📝 | Source code file |
| 🔧 | Configuration/Script |
| 📂 | Directory |
| 💻 | Executable/Program |
| 📚 | Library file |
| 📑 | Include file |
| ⭐ | Important/Priority |
| ⚠️  | Needs installation |
| ✅ | Checklist/Verification |
| 📖 | Reference material |
| 🎨 | IDE/Editor config |

---

## 🗂️  Organization Principles

### Documentation
- Root level: Quick access docs
- docs/: Detailed references
- Each directory: Own README

### Code
- Root: Test program
- src/: All source code
- Separation of concerns

### Output
- bin/: Executables only
- Temporary files cleaned automatically
- .gitignore protects repo

### Configuration
- .vscode/: IDE-specific
- Root: General configs
- Portable and shareable

---

## 📝 Naming Conventions

### Documentation
- UPPERCASE.md - Important docs
- lowercase.md - Standard docs
- directory/README.md - Directory guides

### Code
- lowercase.asm - Source files
- descriptive names (sample.asm, not prog1.asm)

### Scripts
- lowercase.bat - Batch files
- lowercase.ps1 - PowerShell scripts

---

## 🔄 Version Control

### Tracked by Git
- All documentation
- All source code
- Build scripts
- Configuration files
- Directory structure

### Ignored by Git (via .gitignore)
- *.obj files
- *.exe files
- *.lst files
- *.pdb files
- Temporary files

---

## ✅ Directory Verification

### Check All Directories Exist
```powershell
# Verify structure
dir d:\COAL\src
dir d:\COAL\lib
dir d:\COAL\include
dir d:\COAL\bin
dir d:\COAL\docs
dir d:\COAL\.vscode
```

### Check Required Files
```powershell
# Documentation
dir d:\COAL\INDEX.md
dir d:\COAL\README.md
dir d:\COAL\QUICKSTART.md

# Build scripts
dir d:\COAL\build.bat
dir d:\COAL\clean.ps1

# Sample code
dir d:\COAL\test.asm
dir d:\COAL\src\sample.asm
```

---

## 🎯 Quick Access Paths

### Most Used Files
```
Quick Reference:
d:\COAL\INDEX.md
d:\COAL\README.md
d:\COAL\docs\IRVINE32_REFERENCE.md

Build:
d:\COAL\build.bat
d:\COAL\test.asm

Source:
d:\COAL\src\sample.asm
d:\COAL\src\[your programs]
```

### Most Important Directories
```
Development:
d:\COAL\src\      (your code)
d:\COAL\bin\      (your executables)

Reference:
d:\COAL\docs\     (documentation)

Configuration:
d:\COAL\lib\      (libraries)
d:\COAL\include\  (headers)
```

---

## 📊 Directory Tree (Compact View)

```
COAL/
├── docs/
│   ├── SETUP_GUIDE.md
│   └── IRVINE32_REFERENCE.md
├── src/
│   ├── sample.asm
│   └── README.md
├── lib/
│   └── README.md
├── include/
│   └── README.md
├── bin/
│   └── README.md
├── .vscode/
│   ├── settings.json
│   ├── tasks.json
│   ├── extensions.json
│   └── COAL.code-workspace
├── [15 documentation files]
├── test.asm
├── build.bat
└── clean.ps1
```

---

**Last Updated:** December 7, 2025

**Note:** ⚠️  marked files require installation. See DOWNLOADS.md and QUICKSTART.md.
