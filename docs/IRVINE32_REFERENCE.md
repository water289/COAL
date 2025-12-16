# Irvine32 Library Reference

Complete reference guide for the Irvine32 library procedures and macros.

## Table of Contents
1. [Console I/O Procedures](#console-io-procedures)
2. [String Procedures](#string-procedures)
3. [Numeric I/O Procedures](#numeric-io-procedures)
4. [Time and Date Procedures](#time-and-date-procedures)
5. [Memory and Register Procedures](#memory-and-register-procedures)
6. [Graphics Procedures](#graphics-procedures)
7. [Utility Procedures](#utility-procedures)
8. [Macros](#macros)
9. [Usage Examples](#usage-examples)

---

## Console I/O Procedures

### Clrscr
**Description:** Clears the console screen and resets cursor to top-left.

**Syntax:**
```asm
call Clrscr
```

**Parameters:** None

**Returns:** None

**Example:**
```asm
call Clrscr          ; Clear the screen
mov  edx, OFFSET msg
call WriteString     ; Display on clean screen
```

---

### Crlf
**Description:** Writes a carriage return and line feed (newline) to the console.

**Syntax:**
```asm
call Crlf
```

**Parameters:** None

**Returns:** None

**Example:**
```asm
mov  edx, OFFSET msg1
call WriteString
call Crlf            ; Move to next line
mov  edx, OFFSET msg2
call WriteString
```

---

### GetMaxXY
**Description:** Gets the maximum X and Y coordinates of the console window.

**Syntax:**
```asm
call GetMaxXY
```

**Parameters:** None

**Returns:**
- `AX` = number of rows (Y coordinate)
- `DX` = number of columns (X coordinate)

**Example:**
```asm
call GetMaxXY
movzx eax, ax        ; Rows in EAX
movzx edx, dx        ; Columns in EDX
```

---

### Gotoxy
**Description:** Positions the cursor at specified X (column) and Y (row) coordinates.

**Syntax:**
```asm
call Gotoxy
```

**Parameters:**
- `DH` = Y coordinate (row, 0-based)
- `DL` = X coordinate (column, 0-based)

**Returns:** None

**Example:**
```asm
mov  dh, 10          ; Row 10
mov  dl, 20          ; Column 20
call Gotoxy
mov  edx, OFFSET msg
call WriteString     ; Write at position (20,10)
```

---

### GetTextColor
**Description:** Gets the current console text color.

**Syntax:**
```asm
call GetTextColor
```

**Parameters:** None

**Returns:**
- `AL` = current color attribute

**Example:**
```asm
call GetTextColor
mov  savedColor, al  ; Save current color
```

---

### SetTextColor
**Description:** Sets the console text foreground and background colors.

**Syntax:**
```asm
call SetTextColor
```

**Parameters:**
- `EAX` = color attribute (0-255)
  - Bits 0-3: Foreground color
  - Bits 4-7: Background color

**Returns:** None

**Color Values:**
- 0 = Black, 1 = Blue, 2 = Green, 3 = Cyan
- 4 = Red, 5 = Magenta, 6 = Brown, 7 = Light Gray
- 8 = Dark Gray, 9 = Light Blue, 10 = Light Green, 11 = Light Cyan
- 12 = Light Red, 13 = Light Magenta, 14 = Yellow, 15 = White

**Example:**
```asm
mov  eax, white + (blue * 16)  ; White text on blue background
call SetTextColor
mov  edx, OFFSET msg
call WriteString
```

---

## String Procedures

### WriteString
**Description:** Writes a null-terminated string to the console.

**Syntax:**
```asm
call WriteString
```

**Parameters:**
- `EDX` = offset of null-terminated string

**Returns:** None

**Example:**
```asm
.data
    message BYTE "Hello, World!",0

.code
    mov  edx, OFFSET message
    call WriteString
```

---

### ReadString
**Description:** Reads a string from the keyboard into a buffer.

**Syntax:**
```asm
call ReadString
```

**Parameters:**
- `EDX` = offset of input buffer
- `ECX` = maximum characters to read (buffer size - 1)

**Returns:**
- `EAX` = number of characters actually read (not including null terminator)

**Example:**
```asm
.data
    buffer BYTE 50 DUP(0)

.code
    mov  edx, OFFSET buffer
    mov  ecx, SIZEOF buffer - 1
    call ReadString          ; Read up to 49 characters
    ; EAX now contains the number of characters read
```

---

### Str_length
**Description:** Returns the length of a null-terminated string.

**Syntax:**
```asm
call Str_length
```

**Parameters:**
- `EDX` = offset of string

**Returns:**
- `EAX` = length of string (excluding null terminator)

**Example:**
```asm
mov  edx, OFFSET myString
call Str_length
; EAX contains the length
```

---

### Str_copy
**Description:** Copies a source string to a destination string.

**Syntax:**
```asm
call Str_copy
```

**Parameters:**
- `ESI` = offset of source string
- `EDI` = offset of destination string

**Returns:** None

**Example:**
```asm
.data
    source BYTE "Hello",0
    dest   BYTE 50 DUP(0)

.code
    mov  esi, OFFSET source
    mov  edi, OFFSET dest
    call Str_copy
```

---

### Str_compare
**Description:** Compares two strings (case-sensitive).

**Syntax:**
```asm
call Str_compare
```

**Parameters:**
- `ESI` = offset of first string
- `EDI` = offset of second string

**Returns:**
- Sets Zero flag (ZF) if strings are equal
- Sets Carry flag (CF) if string1 < string2

**Example:**
```asm
mov  esi, OFFSET string1
mov  edi, OFFSET string2
call Str_compare
je   stringsEqual        ; Jump if equal
```

---

### Str_trim
**Description:** Removes leading and trailing whitespace from a string.

**Syntax:**
```asm
call Str_trim
```

**Parameters:**
- `ESI` = offset of string to trim
- `EDI` = offset of destination string

**Returns:** None

**Example:**
```asm
mov  esi, OFFSET source  ; "  Hello  "
mov  edi, OFFSET dest
call Str_trim            ; Result: "Hello"
```

---

## Numeric I/O Procedures

### WriteDec
**Description:** Writes an unsigned 32-bit integer in decimal format.

**Syntax:**
```asm
call WriteDec
```

**Parameters:**
- `EAX` = unsigned integer to display

**Returns:** None

**Example:**
```asm
mov  eax, 1234
call WriteDec        ; Displays: 1234
```

---

### WriteInt
**Description:** Writes a signed 32-bit integer in decimal format.

**Syntax:**
```asm
call WriteInt
```

**Parameters:**
- `EAX` = signed integer to display

**Returns:** None

**Example:**
```asm
mov  eax, -1234
call WriteInt        ; Displays: -1234
```

---

### WriteHex
**Description:** Writes an unsigned 32-bit integer in hexadecimal format.

**Syntax:**
```asm
call WriteHex
```

**Parameters:**
- `EAX` = unsigned integer to display

**Returns:** None

**Example:**
```asm
mov  eax, 255
call WriteHex        ; Displays: 000000FF
```

---

### WriteHexB
**Description:** Writes an unsigned 8-bit integer in hexadecimal format.

**Syntax:**
```asm
call WriteHexB
```

**Parameters:**
- `AL` = unsigned byte to display

**Returns:** None

**Example:**
```asm
mov  al, 255
call WriteHexB       ; Displays: FF
```

---

### WriteBin
**Description:** Writes an unsigned 32-bit integer in binary format.

**Syntax:**
```asm
call WriteBin
```

**Parameters:**
- `EAX` = unsigned integer to display

**Returns:** None

**Example:**
```asm
mov  eax, 42
call WriteBin        ; Displays: 00000000000000000000000000101010
```

---

### WriteChar
**Description:** Writes a single character to the console.

**Syntax:**
```asm
call WriteChar
```

**Parameters:**
- `AL` = ASCII character to display

**Returns:** None

**Example:**
```asm
mov  al, 'A'
call WriteChar       ; Displays: A
```

---

### ReadDec
**Description:** Reads an unsigned 32-bit decimal integer from the keyboard.

**Syntax:**
```asm
call ReadDec
```

**Parameters:** None

**Returns:**
- `EAX` = the integer value entered
- Sets Overflow flag (OF) if invalid input

**Example:**
```asm
call ReadDec         ; User enters: 1234
; EAX now contains 1234
```

---

### ReadInt
**Description:** Reads a signed 32-bit decimal integer from the keyboard.

**Syntax:**
```asm
call ReadInt
```

**Parameters:** None

**Returns:**
- `EAX` = the integer value entered
- Sets Overflow flag (OF) if invalid input

**Example:**
```asm
call ReadInt         ; User enters: -1234
; EAX now contains -1234
```

---

### ReadHex
**Description:** Reads a 32-bit hexadecimal integer from the keyboard.

**Syntax:**
```asm
call ReadHex
```

**Parameters:** None

**Returns:**
- `EAX` = the hexadecimal value entered
- Sets Carry flag (CF) if invalid input

**Example:**
```asm
call ReadHex         ; User enters: 1A2B
; EAX now contains 0x00001A2B
```

---

### ReadChar
**Description:** Reads a single character from the keyboard (waits for Enter).

**Syntax:**
```asm
call ReadChar
```

**Parameters:** None

**Returns:**
- `AL` = ASCII character entered

**Example:**
```asm
call ReadChar
; AL contains the character
```

---

### ReadKey
**Description:** Reads a single keystroke (does not wait for Enter).

**Syntax:**
```asm
call ReadKey
```

**Parameters:** None

**Returns:**
- `AL` = ASCII character (0 if special key)
- `AH` = scan code
- Sets Zero flag (ZF) if no key available

**Example:**
```asm
call ReadKey
cmp  al, 27          ; Check for ESC key
je   exitProgram
```

---

## Time and Date Procedures

### GetMseconds
**Description:** Gets the number of milliseconds elapsed since midnight.

**Syntax:**
```asm
call GetMseconds
```

**Parameters:** None

**Returns:**
- `EAX` = milliseconds elapsed

**Example:**
```asm
call GetMseconds
mov  startTime, eax
; ... do something ...
call GetMseconds
sub  eax, startTime  ; EAX = elapsed time
```

---

### Delay
**Description:** Pauses program execution for a specified number of milliseconds.

**Syntax:**
```asm
call Delay
```

**Parameters:**
- `EAX` = number of milliseconds to delay

**Returns:** None

**Example:**
```asm
mov  eax, 1000       ; 1000 milliseconds = 1 second
call Delay
```

---

### GetDateTime
**Description:** Gets the current date and time from the system.

**Syntax:**
```asm
call GetDateTime
```

**Parameters:**
- `ESI` = offset of SYSTEMTIME structure

**Returns:** SYSTEMTIME structure filled with current date/time

**SYSTEMTIME Structure:**
```asm
SYSTEMTIME STRUCT
    wYear         WORD ?
    wMonth        WORD ?
    wDayOfWeek    WORD ?
    wDay          WORD ?
    wHour         WORD ?
    wMinute       WORD ?
    wSecond       WORD ?
    wMilliseconds WORD ?
SYSTEMTIME ENDS
```

**Example:**
```asm
.data
    sysTime SYSTEMTIME <>

.code
    mov  esi, OFFSET sysTime
    call GetDateTime
    movzx eax, sysTime.wYear
    call WriteDec        ; Display year
```

---

## Memory and Register Procedures

### DumpRegs
**Description:** Displays all 32-bit general-purpose registers and flags in hexadecimal.

**Syntax:**
```asm
call DumpRegs
```

**Parameters:** None

**Returns:** None

**Displays:**
- EAX, EBX, ECX, EDX
- ESI, EDI, EBP, ESP
- EIP, EFL (flags)

**Example:**
```asm
mov  eax, 12345678h
mov  ebx, 87654321h
call DumpRegs        ; Display all registers
```

---

### DumpMem
**Description:** Displays a range of memory in hexadecimal.

**Syntax:**
```asm
call DumpMem
```

**Parameters:**
- `ESI` = starting offset of memory
- `ECX` = number of bytes to display
- `EBX` = size of display units (1, 2, or 4 bytes)

**Returns:** None

**Example:**
```asm
.data
    array DWORD 10h, 20h, 30h, 40h

.code
    mov  esi, OFFSET array
    mov  ecx, LENGTHOF array
    mov  ebx, TYPE array     ; 4 bytes
    call DumpMem
```

---

### ShowFPUStack
**Description:** Displays the FPU (Floating Point Unit) register stack.

**Syntax:**
```asm
call ShowFPUStack
```

**Parameters:** None

**Returns:** None

**Example:**
```asm
fld  realValue
call ShowFPUStack    ; Display FPU registers
```

---

## Graphics Procedures

**Note:** Graphics procedures require linking with GraphWin.inc

### DrawLine
**Description:** Draws a line in a graphics window.

**Syntax:**
```asm
call DrawLine
```

**Parameters:**
- Stack: X1, Y1, X2, Y2 (coordinates), Color

**Example:**
```asm
INVOKE DrawLine, 0, 0, 100, 100, Red
```

---

### SetPixel
**Description:** Sets a single pixel to a specified color.

**Syntax:**
```asm
call SetPixel
```

**Parameters:**
- Stack: X, Y (coordinates), Color

**Example:**
```asm
INVOKE SetPixel, 50, 50, Blue
```

---

## Utility Procedures

### WaitMsg
**Description:** Displays "Press any key to continue..." and waits for a keystroke.

**Syntax:**
```asm
call WaitMsg
```

**Parameters:** None

**Returns:** None

**Example:**
```asm
call WaitMsg         ; Pause before exiting
```

---

### Random32
**Description:** Generates a 32-bit pseudo-random integer.

**Syntax:**
```asm
call Random32
```

**Parameters:** None

**Returns:**
- `EAX` = random integer (0 to 4,294,967,295)

**Example:**
```asm
call Random32
; EAX contains a random value
```

---

### RandomRange
**Description:** Generates a random integer within a specified range.

**Syntax:**
```asm
call RandomRange
```

**Parameters:**
- `EAX` = upper bound (n)

**Returns:**
- `EAX` = random integer from 0 to n-1

**Example:**
```asm
mov  eax, 100
call RandomRange     ; EAX = 0 to 99
```

---

### Randomize
**Description:** Seeds the random number generator with current time.

**Syntax:**
```asm
call Randomize
```

**Parameters:** None

**Returns:** None

**Example:**
```asm
call Randomize       ; Initialize RNG
call Random32        ; Get random number
```

---

### IsDigit
**Description:** Checks if a character is a decimal digit (0-9).

**Syntax:**
```asm
call IsDigit
```

**Parameters:**
- `AL` = ASCII character to test

**Returns:**
- Sets Zero flag (ZF) if character is a digit

**Example:**
```asm
mov  al, '5'
call IsDigit
jz   isADigit        ; Jump if digit
```

---

### ParseInteger32
**Description:** Converts a string to a 32-bit signed integer.

**Syntax:**
```asm
call ParseInteger32
```

**Parameters:**
- `EDX` = offset of string
- `ECX` = length of string

**Returns:**
- `EAX` = converted integer value
- Sets Overflow flag (OF) if conversion failed

**Example:**
```asm
.data
    numStr BYTE "1234",0

.code
    mov  edx, OFFSET numStr
    mov  ecx, LENGTHOF numStr - 1
    call ParseInteger32
    ; EAX = 1234
```

---

### ParseDecimal32
**Description:** Converts a string to a 32-bit unsigned integer.

**Syntax:**
```asm
call ParseDecimal32
```

**Parameters:**
- `EDX` = offset of string
- `ECX` = length of string

**Returns:**
- `EAX` = converted integer value
- Sets Carry flag (CF) if conversion failed

**Example:**
```asm
.data
    numStr BYTE "5678",0

.code
    mov  edx, OFFSET numStr
    mov  ecx, LENGTHOF numStr - 1
    call ParseDecimal32
    ; EAX = 5678
```

---

## Macros

### exit
**Description:** Terminates the program and returns to the operating system.

**Syntax:**
```asm
exit
```

**Parameters:** None

**Expands to:**
```asm
INVOKE ExitProcess, 0
```

**Example:**
```asm
main PROC
    ; Your code here
    exit
main ENDP
```

---

### mWrite
**Description:** Writes a string literal directly to the console.

**Syntax:**
```asm
mWrite "string literal"
```

**Parameters:**
- String literal in quotes

**Example:**
```asm
mWrite "Hello, World!"
call Crlf
```

---

### mWriteString
**Description:** Writes a string variable to the console (macro wrapper for WriteString).

**Syntax:**
```asm
mWriteString stringVar
```

**Parameters:**
- String variable name

**Example:**
```asm
.data
    msg BYTE "Hello!",0

.code
    mWriteString msg
```

---

### mDump
**Description:** Displays memory contents (macro wrapper for DumpMem).

**Syntax:**
```asm
mDump offset, count, unitSize
```

**Parameters:**
- offset = starting memory address
- count = number of units
- unitSize = size of each unit (1, 2, or 4)

**Example:**
```asm
.data
    array DWORD 10h, 20h, 30h

.code
    mDump OFFSET array, LENGTHOF array, TYPE array
```

---

## Usage Examples

### Example 1: Simple Input/Output
```asm
INCLUDE Irvine32.inc

.data
    prompt BYTE "Enter a number: ",0
    result BYTE "You entered: ",0

.code
main PROC
    mov  edx, OFFSET prompt
    call WriteString
    call ReadInt             ; Read integer
    mov  ebx, eax            ; Save in EBX
    
    mov  edx, OFFSET result
    call WriteString
    mov  eax, ebx
    call WriteInt            ; Display integer
    call Crlf
    
    exit
main ENDP
END main
```

---

### Example 2: String Manipulation
```asm
INCLUDE Irvine32.inc

.data
    str1 BYTE "Assembly",0
    str2 BYTE "Language",0
    buffer BYTE 50 DUP(0)

.code
main PROC
    ; Copy first string
    mov  esi, OFFSET str1
    mov  edi, OFFSET buffer
    call Str_copy
    
    ; Display result
    mov  edx, OFFSET buffer
    call WriteString
    call Crlf
    
    exit
main ENDP
END main
```

---

### Example 3: Random Numbers
```asm
INCLUDE Irvine32.inc

.data
    prompt BYTE "Random number (1-100): ",0

.code
main PROC
    call Randomize           ; Seed RNG
    
    mov  ecx, 10             ; Generate 10 numbers
L1:
    mov  edx, OFFSET prompt
    call WriteString
    
    mov  eax, 100
    call RandomRange         ; 0-99
    inc  eax                 ; 1-100
    call WriteDec
    call Crlf
    
    loop L1
    
    exit
main ENDP
END main
```

---

### Example 4: Array Display with DumpMem
```asm
INCLUDE Irvine32.inc

.data
    array DWORD 12345678h, 9ABCDEFh, 11111111h, 22222222h

.code
main PROC
    mWrite "Array contents:"
    call Crlf
    
    mov  esi, OFFSET array
    mov  ecx, LENGTHOF array
    mov  ebx, TYPE array
    call DumpMem
    
    exit
main ENDP
END main
```

---

### Example 5: Colored Output
```asm
INCLUDE Irvine32.inc

.data
    msg1 BYTE "This is red!",0
    msg2 BYTE "This is blue!",0

.code
main PROC
    ; Red text
    mov  eax, red
    call SetTextColor
    mov  edx, OFFSET msg1
    call WriteString
    call Crlf
    
    ; Blue text
    mov  eax, blue
    call SetTextColor
    mov  edx, OFFSET msg2
    call WriteString
    call Crlf
    
    ; Reset to default
    mov  eax, lightGray
    call SetTextColor
    
    exit
main ENDP
END main
```

---

### Example 6: Timing Code Execution
```asm
INCLUDE Irvine32.inc

.data
    msg BYTE "Elapsed time (ms): ",0

.code
main PROC
    call GetMseconds
    mov  ebx, eax            ; Save start time
    
    ; Code to time
    mov  ecx, 1000000
L1:
    loop L1
    
    call GetMseconds         ; Get end time
    sub  eax, ebx            ; Calculate elapsed
    
    mov  edx, OFFSET msg
    call WriteString
    call WriteDec
    call Crlf
    
    exit
main ENDP
END main
```

---

## Quick Reference Table

| Category | Procedures |
|----------|-----------|
| **Screen** | Clrscr, Crlf, Gotoxy, GetMaxXY, SetTextColor |
| **String I/O** | WriteString, ReadString, Str_length, Str_copy, Str_compare |
| **Numeric Output** | WriteDec, WriteInt, WriteHex, WriteHexB, WriteBin, WriteChar |
| **Numeric Input** | ReadDec, ReadInt, ReadHex, ReadChar, ReadKey |
| **Debug** | DumpRegs, DumpMem, ShowFPUStack |
| **Time** | GetMseconds, Delay, GetDateTime |
| **Random** | Random32, RandomRange, Randomize |
| **Utility** | WaitMsg, IsDigit, ParseInteger32, ParseDecimal32 |

---

## Additional Notes

1. **Case Sensitivity:** Procedure names are case-insensitive in MASM
2. **Register Preservation:** Most Irvine32 procedures preserve all registers except those used for return values
3. **Include Statement:** Always include `Irvine32.inc` at the top of your program
4. **Library Linking:** Must link with `Irvine32.lib` during build process
5. **Error Handling:** Check flags (ZF, CF, OF) after procedures that can fail

---

## Resources

- **Official Website:** http://asmirvine.com/
- **Textbook:** "Assembly Language for x86 Processors" by Kip R. Irvine
- **Example Programs:** Available on Irvine's website

---

**Last Updated:** December 2025
