# Installation Checklist
## MASM32 + Irvine32 Environment Setup

Use this checklist to ensure your environment is properly configured.

---

## 📋 Pre-Installation

- [ ] **Windows OS** installed (7/8/10/11)
- [ ] **Administrator access** available
- [ ] **Internet connection** active
- [ ] At least **100 MB** free disk space
- [ ] **PowerShell** or **Command Prompt** access

---

## 📥 Downloads

### MASM32 SDK
- [ ] Visited http://www.masm32.com/download.htm
- [ ] Downloaded MASM32 installer (masm32v11r.zip or similar)
- [ ] File size approximately 10-15 MB
- [ ] Virus scanned (optional but recommended)

### Irvine32 Library
- [ ] Visited http://asmirvine.com/
- [ ] Located "Getting Started" or "Downloads" section
- [ ] Downloaded **Irvine32.lib** (library file)
- [ ] Downloaded **Irvine32.inc** (include file)

**Alternative Sources:**
- [ ] Checked textbook companion website
- [ ] Searched for "Irvine32 library download"

---

## 🔧 MASM32 Installation

### Installation Steps
- [ ] Located downloaded MASM32 ZIP file
- [ ] Extracted ZIP file to temporary location
- [ ] Found **install.exe** in extracted folder
- [ ] Right-clicked install.exe
- [ ] Selected **"Run as administrator"**
- [ ] Followed installation prompts
- [ ] Installed to default location: **C:\masm32**
- [ ] Installation completed without errors

### Verification
- [ ] Folder exists: `C:\masm32`
- [ ] Subfolder exists: `C:\masm32\bin`
- [ ] File exists: `C:\masm32\bin\ml.exe`
- [ ] File exists: `C:\masm32\bin\link.exe`

**Test Command:**
```powershell
dir C:\masm32\bin\ml.exe
```
- [ ] Command shows ml.exe file

---

## 📂 Project Setup

### Directory Structure
- [ ] Navigated to project location: `d:\COAL`
- [ ] Verified folders exist:
  - [ ] `src/`
  - [ ] `lib/`
  - [ ] `include/`
  - [ ] `bin/`
  - [ ] `docs/`
  - [ ] `.vscode/`

### Copy Library Files

**Irvine32 Files:**
```powershell
# Adjust source path to where you downloaded files
Copy-Item "C:\Users\YourName\Downloads\Irvine32.lib" -Destination "d:\COAL\lib\"
Copy-Item "C:\Users\YourName\Downloads\Irvine32.inc" -Destination "d:\COAL\include\"
```
- [ ] Copied Irvine32.lib to `lib/` folder
- [ ] Copied Irvine32.inc to `include/` folder

**Windows Libraries:**
```powershell
Copy-Item "C:\masm32\lib\kernel32.lib" -Destination "d:\COAL\lib\"
Copy-Item "C:\masm32\lib\user32.lib" -Destination "d:\COAL\lib\"
```
- [ ] Copied kernel32.lib to `lib/` folder
- [ ] Copied user32.lib to `lib/` folder

### Verify Files
```powershell
dir d:\COAL\lib\
dir d:\COAL\include\
```

**Expected files in lib/:**
- [ ] Irvine32.lib
- [ ] kernel32.lib
- [ ] user32.lib

**Expected files in include/:**
- [ ] Irvine32.inc

---

## ⚙️ Environment Variables

### Option A: System-Wide (Recommended)

**Step 1: Open Environment Variables**
- [ ] Pressed `Win + X`
- [ ] Selected **"System"**
- [ ] Clicked **"Advanced system settings"**
- [ ] Clicked **"Environment Variables..."**

**Step 2: Update PATH**
- [ ] Found **"Path"** in System variables
- [ ] Clicked **"Edit..."**
- [ ] Clicked **"New"**
- [ ] Added: `C:\masm32\bin`
- [ ] Clicked **"New"** again
- [ ] Added: `d:\COAL\bin`
- [ ] Clicked **"OK"**

**Step 3: Create INCLUDE**
- [ ] In System variables, clicked **"New..."**
- [ ] Variable name: `INCLUDE`
- [ ] Variable value: `C:\masm32\include;d:\COAL\include`
- [ ] Clicked **"OK"**

**Step 4: Create LIB**
- [ ] In System variables, clicked **"New..."**
- [ ] Variable name: `LIB`
- [ ] Variable value: `C:\masm32\lib;d:\COAL\lib`
- [ ] Clicked **"OK"**

**Step 5: Apply Changes**
- [ ] Clicked **"OK"** on all dialogs
- [ ] Closed and reopened PowerShell/CMD
- [ ] Restarted VS Code if open

### Option B: Session-Specific (Temporary)

```powershell
$env:PATH += ";C:\masm32\bin;d:\COAL\bin"
$env:INCLUDE = "C:\masm32\include;d:\COAL\include"
$env:LIB = "C:\masm32\lib;d:\COAL\lib"
```
- [ ] Ran above commands in PowerShell
- [ ] No errors occurred

### Verify Environment Variables

```powershell
echo $env:PATH
echo $env:INCLUDE
echo $env:LIB
```
- [ ] PATH contains `C:\masm32\bin`
- [ ] PATH contains `d:\COAL\bin`
- [ ] INCLUDE is set correctly
- [ ] LIB is set correctly

**Test ml.exe accessibility:**
```powershell
ml /?
```
- [ ] Shows MASM assembler help (not "command not found")

---

## ✅ Test Installation

### Build Test Program

```powershell
cd d:\COAL
.\build.bat test.asm
```

**Expected Output:**
- [ ] `[1/3] Assembling...`
- [ ] `[1/3] Assembly successful`
- [ ] `[2/3] Linking...`
- [ ] `[2/3] Linking successful`
- [ ] `[3/3] Cleaning up...`
- [ ] `BUILD SUCCESSFUL!`
- [ ] No error messages

**Check for executable:**
```powershell
dir bin\test.exe
```
- [ ] test.exe exists in bin/ folder

### Run Test Program

```powershell
.\bin\test.exe
```

**Expected Output:**
- [ ] Displays welcome banner
- [ ] Shows "Test 1: String Output"
- [ ] Shows "Hello, Assembly World!"
- [ ] Shows "Test 2: Integer Output" with values
- [ ] Shows "Test 3: Register Dump" with register values
- [ ] Shows "Test 4: User Input" prompt
- [ ] After entering name, shows greeting
- [ ] Shows "All Tests PASSED!"
- [ ] Shows "Press any key to continue..."

### Build Sample Program

```powershell
.\build.bat src\sample.asm
.\bin\sample.exe
```
- [ ] sample.asm builds successfully
- [ ] sample.exe runs and shows menu
- [ ] Can perform arithmetic operations
- [ ] Program exits properly

---

## 🎨 IDE Setup (Optional)

### Visual Studio Code

**Installation:**
- [ ] Downloaded VS Code from https://code.visualstudio.com/
- [ ] Installed VS Code
- [ ] Launched VS Code

**Extensions:**
- [ ] Opened Extensions panel (`Ctrl + Shift + X`)
- [ ] Searched for "MASM"
- [ ] Installed **"MASM/TASM"** by 13xforever
- [ ] Searched for "PowerShell"
- [ ] Installed **"PowerShell"** by Microsoft

**Open Project:**
- [ ] Clicked **File → Open Folder**
- [ ] Selected `d:\COAL`
- [ ] Folder opened in VS Code

**Test Build Task:**
- [ ] Opened test.asm
- [ ] Pressed `Ctrl + Shift + B`
- [ ] Selected "Build Current ASM File"
- [ ] Build succeeded

**Workspace Settings:**
- [ ] Verified `.vscode/settings.json` exists
- [ ] Verified `.vscode/tasks.json` exists
- [ ] Syntax highlighting works for .asm files

---

## 🔍 Troubleshooting

### If ml.exe not found:
- [ ] Verified MASM32 installation path
- [ ] Checked PATH environment variable
- [ ] Restarted terminal
- [ ] Used full path: `C:\masm32\bin\ml.exe`

### If Irvine32.inc not found:
- [ ] Verified file in `d:\COAL\include\`
- [ ] Checked INCLUDE environment variable
- [ ] Restarted terminal
- [ ] Used /I flag in build command

### If Irvine32.lib not found:
- [ ] Verified file in `d:\COAL\lib\`
- [ ] Checked LIB environment variable
- [ ] Restarted terminal
- [ ] Used /LIBPATH flag in link command

### If build.bat fails:
- [ ] Ran PowerShell as Administrator
- [ ] Checked file exists: `dir build.bat`
- [ ] Verified file permissions
- [ ] Tried running manually: `.\build.bat test.asm`

### If program crashes:
- [ ] Verified all library files present
- [ ] Checked for syntax errors
- [ ] Reviewed test.asm for errors
- [ ] Tried rebuilding: `.\build.bat test.asm`

---

## 📚 Next Steps

### Learn the Basics
- [ ] Read **QUICKSTART.md**
- [ ] Review **README.md**
- [ ] Study **test.asm** source code
- [ ] Study **sample.asm** source code

### Documentation
- [ ] Bookmarked **IRVINE32_REFERENCE.md**
- [ ] Read **SETUP_GUIDE.md** troubleshooting section
- [ ] Reviewed program templates

### Start Programming
- [ ] Created first "Hello World" program
- [ ] Built and ran custom program
- [ ] Experimented with Irvine32 procedures
- [ ] Started learning x86 instructions

### Resources
- [ ] Bookmarked http://asmirvine.com/
- [ ] Bookmarked http://www.masm32.com/
- [ ] Found Intel instruction reference
- [ ] Joined MASM32 forum or community

---

## ✨ Installation Complete!

If all checkboxes are marked, your environment is ready! 🎉

### Quick Reference

**Build a program:**
```powershell
.\build.bat src\myprogram.asm
```

**Run a program:**
```powershell
.\bin\myprogram.exe
```

**Clean artifacts:**
```powershell
.\clean.ps1
```

**Get help:**
- Check **QUICKSTART.md**
- Review **IRVINE32_REFERENCE.md**
- Visit **docs/SETUP_GUIDE.md**

---

**Happy Coding! 🚀**

---

## 📝 Notes

Use this section to track any custom configurations or issues:

```
Date: ___________
Issue/Note: ________________________________________
Solution: __________________________________________

Date: ___________
Issue/Note: ________________________________________
Solution: __________________________________________

Date: ___________
Issue/Note: ________________________________________
Solution: __________________________________________
```

---

Last Updated: December 7, 2025
