# Source Code Directory

Place your assembly source code files (.asm) here.

## Example Program Structure

```asm
INCLUDE Irvine32.inc

.data
    ; Your data declarations

.code
main PROC
    ; Your code here
    
    exit
main ENDP
END main
```

## Building Your Programs

From the root directory:
```powershell
.\build.bat src\yourprogram.asm
```

The compiled executable will be placed in the `bin\` directory.

## Tips

- Use descriptive filenames (e.g., `calculator.asm`, `array_sort.asm`)
- Add comments to explain your code
- Test frequently using the build script
- Use `call DumpRegs` to debug register values
