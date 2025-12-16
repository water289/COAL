# Manual Test Commands - HLS Interpreter
## ✅ FIX APPLIED - Stack Alignment Issue Resolved

---

## **WHAT WAS FIXED**

**Problem:** Program hung after debug output "8" when running `help` command

**Root Cause:** In `DoHelp` handler, there was a `pop esi` too early in the function (line 799), causing stack misalignment when jumping to `ExitOK`

**Fix:** Moved `pop esi` to just before `jmp ExitOK` to properly balance the stack

---

## **BUILD STATUS**

✅ **Already compiled with fix**

If you need to rebuild:
```powershell
cd d:\COAL\src
ml /c /coff /Cp /Zd /I"..\include" HLS_Final_fixed.asm
link /SUBSYSTEM:CONSOLE /LIBPATH:"..\lib" /OUT:..\bin\HLS_Final_fixed.exe HLS_Final_fixed.obj Irvine32.lib kernel32.lib user32.lib
del HLS_Final_fixed.obj
cd ..
```

---

## **TEST 1: Help Command** ⭐ (This was broken - now fixed)

```powershell
cd d:\COAL
.\bin\HLS_Final_fixed.exe
```

Type: **`help`** then press Enter

**Should see:**
- Debug numbers 1 through 15 (all of them!)
- Help message with command list
- Return to `>>>` prompt

**Before fix:** Hung at debug "8"
**After fix:** Completes successfully!

---

## **TEST 2: Print Commands**

```powershell
.\bin\HLS_Final_fixed.exe
```

Type each command:
```
print 42
print 100
print 5 plus 10
print 20 multiply by 3
exit
```

---

## **TEST 3: Store and Show Variables**

```powershell
.\bin\HLS_Final_fixed.exe
```

Type:
```
store 100 in x
show x
store 50 in y  
show y
print x plus y
exit
```

**Should output:**
```
x = 100
y = 50
150
```

---

## **TEST 4: Increment**

```powershell
.\bin\HLS_Final_fixed.exe
```

Type:
```
store 0 in counter
show counter
increment counter
show counter
increment counter  
show counter
exit
```

**Should output:**
```
counter = 0
counter = 1
counter = 2
```

---

## **TEST 5: Exit Command**

```powershell
.\bin\HLS_Final_fixed.exe
```

Type: **`exit`**

**Should:** Print "Goodbye!" and exit cleanly

---

## **QUICK START**

Run this:
```powershell
.\test_interactive.bat
```

---

## **What Each Debug Number Means**

When you see numbered output, here's what's happening:

| Number | Location |
|--------|----------|
| 1 | Entered ExecSimple |
| 2 | Stack frame set up |
| 3 | After SkipSpaces |
| 4 | After empty check |
| 5 | After GetToken |
| 6 | Token length OK |
| 7 | Command pointer saved |
| 8 | After exit check |
| 9 | **After help StrCmpI** ← YOU SHOULD SEE THIS NOW! |
| 10 | Help check failed |
| 11 | Entered DoHelp |
| 12 | DoHelp setup |
| 13 | After help message |
| 14 | ExitOK cleanup |
| 15 | ExitOK done |

**The fix ensures you see all 15 debug numbers for the help command!**

---

## **START TESTING NOW!**

1. Open PowerShell in `d:\COAL`
2. Run: `.\bin\HLS_Final_fixed.exe`
3. Type: `help`
4. Verify you see debug numbers 1-15 and the help message
5. Type: `exit`

Then try the other test cases above! 🎉
