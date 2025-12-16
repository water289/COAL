# Include Files Directory

Place your include files here:

- **Irvine32.inc** - Main Irvine32 include file with procedure prototypes
- Optional: Additional include files from MASM32

## Installation Instructions

### Download Irvine32.inc:
Visit http://asmirvine.com/ and download the Irvine32 library files.

Place `Irvine32.inc` in this directory.

### Optional - Copy from MASM32:
```powershell
Copy-Item "C:\masm32\include\windows.inc" -Destination "d:\COAL\include\"
Copy-Item "C:\masm32\include\masm32.inc" -Destination "d:\COAL\include\"
```

## Usage in Assembly Programs

Include in your .asm files:
```asm
INCLUDE Irvine32.inc
```
