# Complete Setup Guide - Human Language Scripting Interpreter

## Prerequisites

You need to install MASM32 on your Windows system. This must be done manually as it requires:
1. Downloading from the official website
2. Running an installer
3. System environment configuration

**I cannot directly download and install software**, but I can guide you through every step.

---

## Step-by-Step Installation Guide

### Step 1: Download MASM32

**Website**: http://www.masm32.com/download.htm

**What to download**:
- File: `masm32v11r.zip` (or latest version - currently v11)
- Size: ~10 MB
- Contains: Assembler, linker, libraries, headers

**How to download**:
1. Go to http://www.masm32.com/download.htm
2. Click the download link for the latest version
3. Save to your Downloads folder
4. Extract the ZIP file

---

### Step 2: Install MASM32

After extracting the ZIP:

1. **Navigate to extracted folder**
   - You should see: `install.bat`, `bin\`, `lib\`, `include\`, etc.

2. **Run the installer** (as Administrator):
   ```cmd
   Right-click install.bat → Run as administrator
   ```
   - This will install MASM32 to `C:\masm32\`
   - Press Enter to confirm

3. **Verify installation**:
   ```cmd
   dir C:\masm32\bin\ml.exe
   ```
   - Should show the ml.exe file

---

### Step 3: Add MASM32 to Environment Variables

**Option A: Temporary (Current Session Only)**
```cmd
set PATH=%PATH%;C:\masm32\bin
```

**Option B: Permanent (Recommended)**

1. Press `Win + X` → Select "System"
2. Click "Advanced system settings"
3. Click "Environment Variables" button
4. Under "User variables", click "New"
   - Variable name: `PATH`
   - Variable value: `C:\masm32\bin`
5. Or edit existing `PATH` and add `;C:\masm32\bin` at the end
6. Click OK, OK, OK
7. **Restart your terminal/PowerShell**

**Verify it worked**:
```cmd
where ml
```
- Should show: `C:\masm32\bin\ml.exe`

---

### Step 4: Verify Your Project Has Libraries

Check that these files exist:
```
d:\COAL\lib\Irvine32.lib
d:\COAL\include\Irvine32.inc
```

If they don't exist, the Irvine32 library files need to be added. You can:
1. Copy from MASM32 installation: `C:\masm32\lib\Irvine32.lib`
2. Or provide them yourself

---

### Step 5: Build the Project

Once MASM32 is installed and in PATH:

```cmd
cd d:\COAL
build.bat
```

**Expected output**:
```
Building Human Language Scripting Interpreter...

[Assembler output]
[Linker output]

============================================
Build successful!
============================================
Executable: bin\interpreter.exe
```

---

### Step 6: Run the Interpreter

```cmd
bin\interpreter.exe
```

**Expected output**:
```
========================================
 Human Language Scripting Interpreter
 Number of runnable commands: 15
 Type 'help' for commands
 Type 'exit' to quit
========================================

>>>
```

---

## Troubleshooting

### Problem: "ml is not recognized as an internal or external command"

**Solution**: MASM32 is not in your PATH
1. Verify it's installed: `dir C:\masm32\bin\ml.exe`
2. Add to PATH (see Step 3 above)
3. Restart your terminal

### Problem: "Cannot open include file Irvine32.inc"

**Solution**: Headers are missing
1. Check: `dir d:\COAL\include\Irvine32.inc`
2. If missing, copy from MASM32: `C:\masm32\include\Irvine32.inc`

### Problem: "Cannot open library Irvine32.lib"

**Solution**: Library is missing
1. Check: `dir d:\COAL\lib\Irvine32.lib`
2. If missing, copy from MASM32: `C:\masm32\lib\Irvine32.lib`

### Problem: Build fails with linker error

**Solution**: Verify all files are present
1. Run: `setup-environment.bat` (created in project root)
2. Check all [OK] messages
3. Verify `C:\masm32\lib\` contains needed libraries

---

## What MASM32 Includes

When you install MASM32, you get:

**Assembler**: `ml.exe` - Converts .asm to .obj files  
**Linker**: `link.exe` - Combines .obj files into .exe  
**Libraries**: Including Irvine32.lib  
**Headers**: Including Irvine32.inc  
**Examples**: Sample assembly programs  

---

## Environment Variables Explained

**PATH** environment variable:
- Tells Windows where to find executable programs
- When you type a command, Windows searches PATH directories
- Adding `C:\masm32\bin` allows typing `ml` instead of `C:\masm32\bin\ml`

**Why you need it**:
- `build.bat` runs `ml` command
- Without PATH, Windows can't find `ml.exe`
- Build fails with "ml is not recognized"

---

## Verification Checklist

- [ ] Downloaded MASM32 from http://www.masm32.com/download.htm
- [ ] Extracted ZIP file
- [ ] Ran `install.bat` (as Administrator)
- [ ] Added `C:\masm32\bin` to PATH
- [ ] Restarted terminal
- [ ] Verified: `where ml` shows path
- [ ] Verified: `d:\COAL\lib\Irvine32.lib` exists
- [ ] Verified: `d:\COAL\include\Irvine32.inc` exists
- [ ] Ran: `cd d:\COAL && build.bat`
- [ ] Ran: `bin\interpreter.exe`
- [ ] Saw: `>>>` prompt
- [ ] Typed: `help` command worked

---

## Quick Reference

### Essential Commands

```cmd
REM Verify MASM32 installation
where ml

REM Check if file exists
dir C:\masm32\bin\ml.exe

REM Add to PATH (temporary)
set PATH=%PATH%;C:\masm32\bin

REM Build project
cd d:\COAL
build.bat

REM Run interpreter
bin\interpreter.exe

REM Clean build
clean.bat
```

---

## Need Help?

1. Check **PROJECT_README.md** - Technical documentation
2. Check **README.md** - Quick start guide
3. Review this guide - Step-by-step instructions
4. Run **setup-environment.bat** - Verification script

---

## Summary

**I cannot automate**:
- Downloading MASM32 (requires manual download from website)
- Installing MASM32 (requires running installer)
- Modifying Windows registry (requires admin permissions)

**You must do**:
1. Download MASM32 from http://www.masm32.com/download.htm
2. Extract the ZIP file
3. Run install.bat
4. Add C:\masm32\bin to PATH environment variable
5. Restart your terminal

**After that**:
- Just run: `cd d:\COAL && build.bat && bin\interpreter.exe`
- Everything else is automated!

---

**Once MASM32 is installed, your interpreter is ready to go!** 🚀
