# Download Links & Resources
## MASM32 and Irvine32 Installation Files

This document contains direct links and instructions for downloading all required software.

---

## 🔗 Required Downloads

### 1. MASM32 SDK (Required)

**Official Website:**
- Primary: http://www.masm32.com/
- Download Page: http://www.masm32.com/download.htm

**Direct Download:**
- Latest Version: http://www.masm32.com/install.exe
- Alternative: Search for "masm32v11r.zip" (approximately 10-15 MB)

**Installation:**
- Run `install.exe` as Administrator
- Default install location: `C:\masm32`
- Includes: ml.exe, link.exe, libraries, and documentation

---

### 2. Irvine32 Library (Required)

**Official Website:**
- Kip Irvine's Site: http://asmirvine.com/

**Download Locations:**

**Option A: Getting Started Page**
- http://asmirvine.com/gettingStartedVS2019/index.htm
- Look for "Download Irvine32 Library"
- Files needed:
  - `Irvine32.lib` (library file)
  - `Irvine32.inc` (include file)

**Option B: GitHub Repository**
- Search GitHub for "Irvine32 library"
- Look for repositories containing:
  - Irvine32.lib
  - Irvine32.inc
  - Optionally: SmallWin.inc, GraphWin.inc

**Option C: Textbook Companion**
- If you have "Assembly Language for x86 Processors" by Kip Irvine
- Access companion website through your textbook
- Download Example Programs package
- Extract Irvine32.lib and Irvine32.inc

**Files You Need:**
```
Essential:
├── Irvine32.lib    (Main library file)
└── Irvine32.inc    (Include file with prototypes)

Optional:
├── SmallWin.inc    (Small Windows applications)
├── GraphWin.inc    (Graphics operations)
└── VirtualKeys.inc (Virtual key codes)
```

---

## 🛠️ Optional Tools

### Visual Studio Code (Recommended Editor)

**Download:**
- Official Site: https://code.visualstudio.com/
- Windows 64-bit: https://code.visualstudio.com/sha/download?build=stable&os=win32-x64-user

**Extensions (Install from VS Code Marketplace):**
1. **MASM/TASM** by 13xforever
   - Extension ID: `13xforever.language-x86-64-assembly`
   - Features: Syntax highlighting, basic IntelliSense

2. **PowerShell** by Microsoft
   - Extension ID: `ms-vscode.powershell`
   - Features: PowerShell scripting support

3. **ASM Code Lens** by maziac
   - Extension ID: `maziac.asm-code-lens`
   - Features: Code navigation, variable tracking

---

### Debuggers (Optional but Useful)

**OllyDbg** (32-bit debugger)
- Official: http://www.ollydbg.de/
- Download: http://www.ollydbg.de/odbg201.zip
- Use: Debugging assembly programs

**x64dbg** (Modern debugger)
- Official: https://x64dbg.com/
- GitHub: https://github.com/x64dbg/x64dbg/releases
- Use: 32-bit and 64-bit debugging

**WinDbg** (Microsoft Debugger)
- Part of Windows SDK
- Download: https://docs.microsoft.com/en-us/windows-hardware/drivers/debugger/

---

## 📚 Documentation & Learning Resources

### Official Documentation

**MASM32:**
- Documentation: http://www.masm32.com/masmdoc/
- Forum: http://www.masm32.com/board/
- Tutorials: http://www.masm32.com/tutorials.htm

**Irvine:**
- Main Site: http://asmirvine.com/
- Book Website: http://asmirvine.com/gettingStartedVS2019/
- Examples: Available on main site

**Intel:**
- Software Developer Manuals: https://software.intel.com/content/www/us/en/develop/articles/intel-sdm.html
- x86 Instruction Set Reference: https://www.felixcloutier.com/x86/

---

### Textbooks & Tutorials

**Recommended Book:**
- **"Assembly Language for x86 Processors"** by Kip R. Irvine
  - Latest Edition: 8th Edition
  - ISBN-13: 978-0135381656
  - Companion Website: http://asmirvine.com/

**Free Online Resources:**
- **PC Assembly Tutorial**: http://www.drpaulcarter.com/pcasm/
- **Art of Assembly**: https://www.plantation-productions.com/Webster/www.artofasm.com/index.html
- **x86 Assembly Guide**: https://www.cs.virginia.edu/~evans/cs216/guides/x86.html

---

### Video Tutorials

**YouTube Channels:**
- **Davy Wybiral**: x86 Assembly tutorials
- **Brian Will**: Computer architecture and assembly
- **Derek Banas**: Assembly language tutorial series

**Search Terms:**
- "x86 assembly tutorial"
- "MASM32 programming"
- "Irvine32 library tutorial"
- "assembly language for beginners"

---

## 🌐 Community Resources

### Forums & Communities

**MASM32 Forum:**
- URL: http://www.masm32.com/board/
- Topics: MASM programming, Windows API, optimization
- Activity: Very active, helpful community

**Stack Overflow:**
- Tags: `[masm]`, `[x86]`, `[assembly]`, `[irvine32]`
- URL: https://stackoverflow.com/questions/tagged/masm

**Reddit:**
- r/asm - Assembly programming
- r/learnprogramming - General programming help

---

## 📖 Reference Materials

### Quick References

**x86 Instruction Set:**
- Felix Cloutier's Reference: https://www.felixcloutier.com/x86/
- Intel Intrinsics Guide: https://software.intel.com/sites/landingpage/IntrinsicsGuide/

**Windows API:**
- Microsoft Docs: https://docs.microsoft.com/en-us/windows/win32/api/
- Win32 API Index: https://docs.microsoft.com/en-us/windows/win32/apiindex/windows-api-list

**ASCII Table:**
- http://www.asciitable.com/
- Essential for character operations

---

## 🔧 Installation File Checksums

When downloading, verify file integrity:

### MASM32 SDK
```
File: masm32v11r.zip (or install.exe)
Size: ~10-15 MB
Note: Exact checksum varies by version
Verify from: Official MASM32 website
```

### Irvine32 Files
```
Irvine32.lib
Size: ~50-100 KB (varies by version)
Note: Verify from trusted source

Irvine32.inc
Size: ~20-40 KB (varies by version)
Note: Contains procedure prototypes
```

---

## 📥 Download Checklist

Use this checklist while downloading:

### Essential Downloads
- [ ] Downloaded MASM32 SDK installer
- [ ] Downloaded Irvine32.lib
- [ ] Downloaded Irvine32.inc
- [ ] Verified downloads are from official sources
- [ ] Scanned files for viruses (optional)

### Optional Downloads
- [ ] Downloaded VS Code
- [ ] Downloaded debugger (OllyDbg/x64dbg)
- [ ] Downloaded textbook examples (if available)
- [ ] Downloaded additional reference materials

---

## 🚨 Important Notes

### Trusted Sources Only
- **Always download from official websites**
- MASM32: Only from http://www.masm32.com/
- Irvine32: Only from http://asmirvine.com/ or textbook companion
- VS Code: Only from https://code.visualstudio.com/

### Version Compatibility
- MASM32: Latest stable version (v11r recommended)
- Irvine32: Version compatible with your textbook
- Windows: Works on Windows 7/8/10/11 (32-bit or 64-bit)

### File Locations After Download
```
After downloading, place files here:

Irvine32.lib  → d:\COAL\lib\
Irvine32.inc  → d:\COAL\include\

From MASM32 installation:
kernel32.lib  → Copy from C:\masm32\lib\ to d:\COAL\lib\
user32.lib    → Copy from C:\masm32\lib\ to d:\COAL\lib\
```

---

## 🔄 Alternative Sources

If official sites are unavailable:

### MASM32
- **Archive.org**: Search for "masm32" (backup copies)
- **GitHub**: Some repositories mirror MASM32 tools

### Irvine32
- **GitHub**: Search "Irvine32 library"
- **University Websites**: Many CS departments host copies
- **Textbook Resources**: Check publisher's website

**Note:** Always verify file integrity from alternative sources!

---

## 📞 Help Finding Downloads

If you have trouble locating files:

### Search Terms
```
Google/Bing Search:
- "MASM32 SDK download"
- "Irvine32 library download"
- "Kip Irvine assembly language resources"
- "MASM assembler Windows"
```

### University Resources
- Many universities provide mirrors
- Check your school's CS department resources
- Ask your instructor for download links

### Textbook Support
- Contact Pearson (publisher) support
- Check MyLab resources if enrolled
- Access companion site through textbook code

---

## ✅ Verification

After downloading, verify you have:

### MASM32
```powershell
# After installation, check:
dir C:\masm32\bin\ml.exe
dir C:\masm32\bin\link.exe
dir C:\masm32\lib\kernel32.lib
```

### Irvine32
```powershell
# Check downloaded files:
dir d:\COAL\lib\Irvine32.lib
dir d:\COAL\include\Irvine32.inc
```

---

## 🎯 Next Steps After Download

1. **Install MASM32**
   - Run install.exe as Administrator
   - Follow prompts
   - Install to C:\masm32

2. **Copy Irvine32 Files**
   ```powershell
   Copy-Item "Downloads\Irvine32.lib" -Destination "d:\COAL\lib\"
   Copy-Item "Downloads\Irvine32.inc" -Destination "d:\COAL\include\"
   ```

3. **Copy Windows Libraries**
   ```powershell
   Copy-Item "C:\masm32\lib\kernel32.lib" -Destination "d:\COAL\lib\"
   Copy-Item "C:\masm32\lib\user32.lib" -Destination "d:\COAL\lib\"
   ```

4. **Set Environment Variables**
   - See QUICKSTART.md or SETUP_GUIDE.md

5. **Test Installation**
   ```powershell
   .\build.bat test.asm
   ```

---

## 📚 Additional Resources

### Online Assemblers (For Testing)
- **godbolt.org**: Compiler Explorer (supports MASM)
- **onlinegdb.com**: Online assembly compiler

### Cheat Sheets
- x86 Instruction Reference Cards
- ASCII Table
- Windows API Quick Reference
- Irvine32 Procedure List (in IRVINE32_REFERENCE.md)

---

**Last Updated:** December 7, 2025

**Note:** URLs may change over time. If links are broken, use search engines with the provided search terms or consult the community forums.
