# MASM32 + Irvine32 Setup Guide

Complete step-by-step instructions for setting up x86 Assembly development environment on Windows.

## Table of Contents
1. [System Requirements](#system-requirements)
2. [Installing MASM32](#installing-masm32)
3. [Installing Irvine32 Library](#installing-irvine32-library)
4. [Configuring Environment Variables](#configuring-environment-variables)
5. [Testing Your Installation](#testing-your-installation)
6. [IDE/Editor Setup](#ideeditor-setup)
7. [Troubleshooting](#troubleshooting)

---

## System Requirements

- **Operating System:** Windows 7/8/10/11 (32-bit or 64-bit)
- **Processor:** x86 or x64 compatible processor
- **Disk Space:** ~100 MB for MASM32 SDK
- **Permissions:** Administrator access for installation
- **Optional:** Text editor or IDE (VS Code, Notepad++, Visual Studio)

---

## Installing MASM32

### Step 1: Download MASM32 SDK

1. Open your web browser
2. Navigate to: **http://www.masm32.com/**
3. Click on **"Download"** in the menu
4. Download the latest version (typically named `masm32v11r.zip` or similar)
   - File size: approximately 10-15 MB
   - Alternative download link: http://www.masm32.com/download.htm

### Step 2: Extract MASM32

1. Locate the downloaded ZIP file (usually in Downloads folder)
2. Right-click the ZIP file
3. Select **"Extract All..."**
4. Choose a temporary extraction location (e.g., `C:\Temp\masm32`)
5. Click **"Extract"**

### Step 3: Run MASM32 Installer

1. Navigate to the extracted folder
2. Find `install.exe`
3. **Right-click** `install.exe`
4. Select **"Run as administrator"**
5. The installer will:
   - Create `C:\masm32` directory
   - Extract all files
   - Set up the environment
   - Create desktop shortcuts (optional)
6. Click **"OK"** when installation completes

### Step 4: Verify MASM32 Installation

Open PowerShell or Command Prompt and run:

```powershell
# Check if ml.exe (assembler) exists
dir C:\masm32\bin\ml.exe

# Check version
C:\masm32\bin\ml.exe /?
```

**Expected Output:** You should see the MASM assembler help message showing version information.

---

## Installing Irvine32 Library

### Step 1: Download Irvine32 Files

**Option A: From Kip Irvine's Website**

1. Visit: **http://asmirvine.com/**
2. Navigate to: **"Getting Started"** section
3. Download:
   - `Irvine32.lib` (Library file)
   - `Irvine32.inc` (Include file)
   - Optionally: `SmallWin.inc`, `GraphWin.inc`, `VirtualKeys.inc`

**Option B: From Textbook Resources**

1. If you have the textbook "Assembly Language for x86 Processors" by Kip Irvine
2. Access the companion website
3. Download the Example Programs package
4. Extract and locate `Irvine32.lib` and `Irvine32.inc`

**Option C: Alternative Download**

- GitHub repositories often have Irvine32 files
- Search for "Irvine32 library download"
- Ensure you download from a trusted source

### Step 2: Install Irvine32 Files

**Method 1: Using PowerShell (Recommended)**

```powershell
# Navigate to your COAL project directory
cd d:\COAL

# Copy Irvine32.lib to lib folder (adjust source path as needed)
Copy-Item "C:\Users\YourUsername\Downloads\Irvine32.lib" -Destination "lib\"

# Copy Irvine32.inc to include folder
Copy-Item "C:\Users\YourUsername\Downloads\Irvine32.inc" -Destination "include\"

# Verify files were copied
dir lib\Irvine32.lib
dir include\Irvine32.inc
```

**Method 2: Manual Copy**

1. Open File Explorer
2. Navigate to where you downloaded Irvine32 files
3. Copy `Irvine32.lib` to `d:\COAL\lib\`
4. Copy `Irvine32.inc` to `d:\COAL\include\`

### Step 3: Copy Windows System Libraries

The Irvine32 library depends on Windows system libraries. Copy them to your project:

```powershell
# Copy kernel32.lib (Windows kernel functions)
Copy-Item "C:\masm32\lib\kernel32.lib" -Destination "d:\COAL\lib\"

# Copy user32.lib (Windows user interface functions)
Copy-Item "C:\masm32\lib\user32.lib" -Destination "d:\COAL\lib\"

# Verify
dir d:\COAL\lib\
```

**Expected Output:**
```
Irvine32.lib
kernel32.lib
user32.lib
```

### Step 4: Optional - Copy Additional Include Files

```powershell
# Copy Windows API includes (optional but useful)
Copy-Item "C:\masm32\include\windows.inc" -Destination "d:\COAL\include\"
Copy-Item "C:\masm32\include\masm32.inc" -Destination "d:\COAL\include\"
```

---

## Configuring Environment Variables

Environment variables allow the assembler and linker to find necessary files automatically.

### Option 1: System-Wide Configuration (Recommended for permanent setup)

#### Step 1: Open Environment Variables Dialog

**Windows 10/11:**
1. Press `Win + X`
2. Select **"System"**
3. Click **"Advanced system settings"** on the right
4. Click **"Environment Variables..."** button

**Alternative Method:**
1. Right-click **"This PC"** or **"My Computer"**
2. Select **"Properties"**
3. Click **"Advanced system settings"**
4. Click **"Environment Variables..."**

#### Step 2: Configure PATH Variable

1. In the **"System variables"** section (lower pane), find **"Path"**
2. Select **"Path"** and click **"Edit..."**
3. Click **"New"** and add: `C:\masm32\bin`
4. Click **"New"** and add: `d:\COAL\bin`
5. Click **"OK"**

#### Step 3: Create INCLUDE Variable

1. In **"System variables"**, click **"New..."**
2. Variable name: `INCLUDE`
3. Variable value: `C:\masm32\include;d:\COAL\include`
4. Click **"OK"**

#### Step 4: Create LIB Variable

1. In **"System variables"**, click **"New..."**
2. Variable name: `LIB`
3. Variable value: `C:\masm32\lib;d:\COAL\lib`
4. Click **"OK"**

#### Step 5: Apply Changes

1. Click **"OK"** on all dialogs
2. **Close and reopen** any command prompts or PowerShell windows
3. **Restart** your IDE if running

### Option 2: Session-Specific Configuration (Temporary)

If you don't have administrator access or prefer not to modify system settings:

**PowerShell:**
```powershell
# Add to PATH
$env:PATH += ";C:\masm32\bin;d:\COAL\bin"

# Set INCLUDE
$env:INCLUDE = "C:\masm32\include;d:\COAL\include"

# Set LIB
$env:LIB = "C:\masm32\lib;d:\COAL\lib"

# Verify
echo $env:PATH
echo $env:INCLUDE
echo $env:LIB
```

**Command Prompt:**
```cmd
set PATH=%PATH%;C:\masm32\bin;d:\COAL\bin
set INCLUDE=C:\masm32\include;d:\COAL\include
set LIB=C:\masm32\lib;d:\COAL\lib
```

**Note:** These changes only last for the current session. You'll need to run them again each time you open a new terminal.

### Option 3: PowerShell Profile (Automatic for PowerShell sessions)

Create a PowerShell profile that automatically sets variables:

```powershell
# Create profile if it doesn't exist
if (!(Test-Path $PROFILE)) {
    New-Item -Path $PROFILE -Type File -Force
}

# Edit profile
notepad $PROFILE

# Add these lines to the profile:
$env:PATH += ";C:\masm32\bin;d:\COAL\bin"
$env:INCLUDE = "C:\masm32\include;d:\COAL\include"
$env:LIB = "C:\masm32\lib;d:\COAL\lib"
```

Save and close. The variables will be set automatically in future PowerShell sessions.

### Verify Environment Variables

```powershell
# Check PATH
echo $env:PATH

# Check INCLUDE
echo $env:INCLUDE

# Check LIB
echo $env:LIB

# Test ml.exe is accessible
ml /?
```

---

## Testing Your Installation

### Step 1: Navigate to Project Directory

```powershell
cd d:\COAL
```

### Step 2: Build the Test Program

```powershell
.\build.bat test.asm
```

**Expected Output:**
```
============================================
Building: test.asm
Output: d:\COAL\bin\test.exe
============================================

[1/3] Assembling...
[1/3] Assembly successful

[2/3] Linking...
[2/3] Linking successful

[3/3] Cleaning up...

============================================
BUILD SUCCESSFUL!
============================================
Executable: d:\COAL\bin\test.exe

To run: d:\COAL\bin\test.exe
Or: cd bin && test.exe
============================================
```

### Step 3: Run the Test Program

```powershell
.\bin\test.exe
```

**Expected Output:**
```
============================================
  MASM32 + Irvine32 Environment Test
============================================

Test 1: String Output
Hello, Assembly World!

Test 2: Integer Output
Decimal value: 42
Hexadecimal value: 0000002A
Binary value: 00000000000000000000000000101010

Test 3: Register Dump
[Register dump display]

Test 4: User Input
Enter your name: [Type your name]
Hello, [Your name]!

============================================
  All Tests PASSED!
  Environment is configured correctly!
============================================

Press any key to continue...
```

### Step 4: Verify Success

If you see the above output, **congratulations!** Your environment is correctly configured.

---

## IDE/Editor Setup

### Visual Studio Code

#### Step 1: Install VS Code

1. Download from: https://code.visualstudio.com/
2. Run installer
3. Complete installation

#### Step 2: Install MASM Extension

1. Open VS Code
2. Press `Ctrl + Shift + X` (Extensions)
3. Search for: **"MASM"** or **"x86 Assembly"**
4. Install: **"MASM/TASM"** by 13xforever
5. Reload VS Code

#### Step 3: Open Project Folder

1. File → Open Folder
2. Navigate to `d:\COAL`
3. Click **"Select Folder"**

#### Step 4: Configure Build Task (Optional)

Create `.vscode\tasks.json`:

```json
{
    "version": "2.0.0",
    "tasks": [
        {
            "label": "Build ASM",
            "type": "shell",
            "command": "${workspaceFolder}\\build.bat",
            "args": ["${file}"],
            "group": {
                "kind": "build",
                "isDefault": true
            },
            "presentation": {
                "reveal": "always",
                "panel": "new"
            },
            "problemMatcher": []
        }
    ]
}
```

Now you can press `Ctrl + Shift + B` to build the current file.

### Notepad++

1. Download from: https://notepad-plus-plus.org/
2. Install
3. Assembly syntax highlighting is built-in
4. Use Run menu to execute build.bat

### Visual Studio (Full IDE)

1. Download Visual Studio Community (free)
2. Install with C++ Desktop Development workload
3. MASM support is included
4. Create Win32 Console Application
5. Add .asm files to project

---

## Troubleshooting

### ml.exe Not Found

**Problem:** `'ml' is not recognized as an internal or external command`

**Solutions:**
1. Verify MASM32 is installed: `dir C:\masm32\bin\ml.exe`
2. Add to PATH: `$env:PATH += ";C:\masm32\bin"`
3. Use full path: `C:\masm32\bin\ml.exe`
4. Restart terminal after changing environment variables

### Irvine32.inc Not Found

**Problem:** `error A1000: cannot open file : Irvine32.inc`

**Solutions:**
1. Check file exists: `dir d:\COAL\include\Irvine32.inc`
2. Use `/I` flag: `ml /c /coff /I"d:\COAL\include" file.asm`
3. Set INCLUDE variable: `$env:INCLUDE = "C:\masm32\include;d:\COAL\include"`
4. Verify case sensitivity (should be `Irvine32.inc`, not `irvine32.inc`)

### Irvine32.lib Not Found

**Problem:** `LINK : fatal error LNK1181: cannot open input file 'Irvine32.lib'`

**Solutions:**
1. Check file exists: `dir d:\COAL\lib\Irvine32.lib`
2. Use `/LIBPATH:` flag in link command
3. Set LIB variable: `$env:LIB = "C:\masm32\lib;d:\COAL\lib"`

### Build Script Doesn't Run

**Problem:** Build.bat fails or doesn't execute

**Solutions:**
1. Check execution policy (PowerShell): `Set-ExecutionPolicy -Scope CurrentUser RemoteSigned`
2. Run from correct directory: `cd d:\COAL`
3. Use full path: `d:\COAL\build.bat test.asm`
4. Check file permissions

### Access Denied Errors

**Problem:** Cannot install or run programs

**Solutions:**
1. Run PowerShell/CMD as Administrator
2. Right-click → "Run as administrator"
3. Check antivirus isn't blocking installation
4. Disable UAC temporarily during installation

### Program Assembles but Doesn't Run

**Problem:** .exe file created but crashes or doesn't execute

**Solutions:**
1. Missing `exit` or `call ExitProcess` at end of program
2. Stack imbalance (PUSH without POP)
3. Run in debugger to identify issue
4. Check for infinite loops

### 64-bit Windows Issues

**Problem:** MASM32 is 32-bit, won't run on 64-bit Windows

**Solution:** MASM32 produces 32-bit code that runs on 64-bit Windows through WOW64 (Windows-on-Windows 64-bit). This is normal and expected. Your programs will work fine.

---

## Next Steps

After successful installation:

1. ✅ Read through `README.md` for quick reference
2. ✅ Review `docs\IRVINE32_REFERENCE.md` for procedure documentation
3. ✅ Examine `test.asm` to understand program structure
4. ✅ Create your first program in the `src\` directory
5. ✅ Build and run using `build.bat`

## Additional Resources

- **Irvine's Website:** http://asmirvine.com/
- **MASM32 Forum:** http://www.masm32.com/board/
- **Intel Manuals:** https://software.intel.com/content/www/us/en/develop/articles/intel-sdm.html
- **x86 Instruction Reference:** https://www.felixcloutier.com/x86/

## Support

If you encounter issues not covered here:
1. Check error messages carefully
2. Search MASM32 forums
3. Review Stack Overflow (tag: [masm])
4. Consult Irvine's textbook

---

**Installation complete!** You're ready to program in x86 Assembly!
