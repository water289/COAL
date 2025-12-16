# 📥 Installing MASM32 - Step by Step

You've downloaded `masm32v11.zip`. Here's exactly what to do next:

## Step 1️⃣: Extract the ZIP File

**Where you downloaded it**: Probably `C:\Users\YourName\Downloads\masm32v11.zip`

**How to extract**:
1. Right-click `masm32v11.zip`
2. Select "Extract All..."
3. Choose location: `C:\masm32\` (recommended)
4. Click "Extract"

**Result**: You should now have `C:\masm32\` folder with:
- `bin/` folder
- `lib/` folder
- `include/` folder
- `install.bat` file
- Many other files

## Step 2️⃣: Run the Installer

**Method 1 - Easy (Recommended)**:
```cmd
1. Open PowerShell or Command Prompt as Administrator
   - Right-click PowerShell
   - Select "Run as Administrator"

2. Navigate to extracted folder:
   cd C:\masm32
   
3. Run installer:
   .\install.bat
   
4. Press Enter when prompted
5. Wait for completion
```

**Method 2 - Using Helper Script**:
1. Copy `masm32v11.zip` to `C:\masm32.zip`
2. Extract it
3. Run: `d:\COAL\INSTALL_MASM32.bat`
4. Follow the prompts

**Expected output**:
```
MASM32 Installation v11
...
Press any key to continue...
```

## Step 3️⃣: Verify Installation

**Check if installed correctly**:
```cmd
1. Close your current terminal completely
2. Open a NEW PowerShell or Command Prompt window
3. Type: where ml
```

**Expected output**:
```
C:\masm32\bin\ml.exe
```

**If you see an error** "ml is not recognized":
- Installation may have failed
- Try running installer again as Administrator
- Make sure you're in a NEW terminal window (not the old one)

## Step 4️⃣: Add to System PATH (IMPORTANT!)

**Why?** So Windows can find `ml.exe` from anywhere

**Option A - Command Line (Quickest)**:
```cmd
setx PATH "%PATH%;C:\masm32\bin"
```
Then close and reopen your terminal.

**Option B - GUI Settings**:
1. Right-click on "This PC" or "My Computer"
2. Select "Properties"
3. Click "Advanced system settings"
4. Click "Environment Variables" button
5. Under "User variables", click "New"
   - Variable name: `PATH`
   - Variable value: `C:\masm32\bin`
6. Click OK, OK, OK
7. Close all terminals and open a new one

**Verify it worked**:
```cmd
where ml
```
Should show: `C:\masm32\bin\ml.exe`

## Step 5️⃣: Build Your Interpreter

Once PATH is set and verified:

```cmd
1. Open a new terminal
2. Navigate to project:
   cd d:\COAL

3. Build:
   build.bat

4. Run:
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

## ✅ Complete Checklist

- [ ] Downloaded `masm32v11.zip`
- [ ] Extracted to `C:\masm32\`
- [ ] Verified folder exists with `install.bat`
- [ ] Ran `install.bat` as Administrator
- [ ] Closed all terminal windows
- [ ] Opened NEW terminal window
- [ ] Ran: `where ml`
- [ ] Saw: `C:\masm32\bin\ml.exe`
- [ ] Added `C:\masm32\bin` to PATH (or ran `setx` command)
- [ ] Closed and reopened terminal again
- [ ] Ran: `cd d:\COAL && build.bat`
- [ ] Build completed successfully
- [ ] Ran: `bin\interpreter.exe`
- [ ] Saw the `>>>` prompt
- [ ] Tried: `help` command
- [ ] All commands work!

## 🆘 Troubleshooting

### Problem: "ml is not recognized"
```
Error: 'ml' is not recognized as an internal or external command
```

**Causes & Solutions**:
1. **MASM32 not installed**
   - Check: `dir C:\masm32\bin\ml.exe`
   - If missing: Re-run install.bat

2. **PATH not updated**
   - Run: `setx PATH "%PATH%;C:\masm32\bin"`
   - Close ALL terminals
   - Open NEW terminal
   - Try: `where ml` again

3. **Using old terminal session**
   - Solution: Close terminal completely
   - Open a completely NEW terminal window
   - Try: `where ml` again

### Problem: "Permission denied" when running installer
```
Error: Access Denied
```

**Solution**:
1. Right-click Command Prompt
2. Select "Run as Administrator"
3. Navigate to C:\masm32
4. Run: `install.bat`

### Problem: install.bat file not found
```
Error: 'install.bat' is not recognized...
```

**Solution**:
1. Make sure you extracted the ZIP file
2. Check: `dir C:\masm32\install.bat`
3. Navigate to that folder: `cd C:\masm32`
4. Then run: `install.bat`

### Problem: build.bat fails with "Cannot open include file"
```
Error: Cannot open include file 'Irvine32.inc'
```

**Causes & Solutions**:
1. **Irvine32 headers not in include folder**
   - Check: `dir d:\COAL\include\Irvine32.inc`
   - If missing: Copy from MASM32:
     ```cmd
     copy C:\masm32\include\Irvine32.inc d:\COAL\include\
     ```

2. **Wrong include path in build.bat**
   - Check: `build.bat` line with `/I`
   - Should be: `/I"..\include"`

### Problem: build.bat fails with "Cannot open library"
```
Error: Cannot open library file 'Irvine32.lib'
```

**Solution**:
```cmd
copy C:\masm32\lib\Irvine32.lib d:\COAL\lib\
```

## 📋 Quick Reference

### Essential Commands
```cmd
REM Extract ZIP (Windows Explorer)
Right-click masm32v11.zip → Extract All... → C:\masm32

REM Run installer
cd C:\masm32
install.bat

REM Add to PATH
setx PATH "%PATH%;C:\masm32\bin"

REM Verify installation
where ml

REM Build project
cd d:\COAL
build.bat

REM Run interpreter
bin\interpreter.exe
```

### File Locations to Remember
```
Downloaded ZIP:         C:\Users\YourName\Downloads\masm32v11.zip
Extracted folder:       C:\masm32\
Assembler executable:   C:\masm32\bin\ml.exe
Linker executable:      C:\masm32\bin\link.exe
Irvine32 library:       C:\masm32\lib\Irvine32.lib
Your project:           d:\COAL\
Your interpreter:       d:\COAL\bin\interpreter.exe
```

## 🎯 You're Almost There!

Once `where ml` shows `C:\masm32\bin\ml.exe`, you're done with setup. Then just:

```cmd
cd d:\COAL
build.bat
bin\interpreter.exe
```

## 📞 Still Stuck?

1. **Check**: Did you close and reopen your terminal after adding PATH?
2. **Verify**: Run `where ml` - should show path
3. **Test**: Copy this command exactly: `setx PATH "%PATH%;C:\masm32\bin"`
4. **Restart**: Close all terminals completely, open a new one
5. **Try**: `where ml` again
6. **Build**: `build.bat`

---

**You're so close! The hardest part is done (downloading). Now just extract, install, and build!** 🚀
