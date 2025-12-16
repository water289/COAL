# Library Files Directory

Place your library files here:

- **Irvine32.lib** - Main Irvine32 library file
- **kernel32.lib** - Windows kernel library (copy from C:\masm32\lib\)
- **user32.lib** - Windows user interface library (copy from C:\masm32\lib\)

## Installation Instructions

### Copy from MASM32:
```powershell
Copy-Item "C:\masm32\lib\kernel32.lib" -Destination "d:\COAL\lib\"
Copy-Item "C:\masm32\lib\user32.lib" -Destination "d:\COAL\lib\"
```

### Download Irvine32.lib:
Visit http://asmirvine.com/ and download the Irvine32 library files.

Place `Irvine32.lib` in this directory.
