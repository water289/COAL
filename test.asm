; ============================================
; test.asm - Hello World Test Program
; ============================================
; This program tests the MASM32 and Irvine32
; library installation by displaying a message,
; showing register values, and demonstrating
; basic I/O operations.
; ============================================

; Include the Irvine32 library which provides
; simplified I/O procedures for assembly programming
INCLUDE Irvine32.inc

; ============================================
; DATA SEGMENT
; ============================================
.data
    ; String declarations (null-terminated)
    ; Each string ends with 0 (null terminator)
    
    welcomeMsg  BYTE "============================================",0dh,0ah
                BYTE "  MASM32 + Irvine32 Environment Test",0dh,0ah
                BYTE "============================================",0dh,0ah,0
    
    testMsg1    BYTE 0dh,0ah,"Test 1: String Output",0dh,0ah
                BYTE "Hello, Assembly World!",0dh,0ah,0
    
    testMsg2    BYTE 0dh,0ah,"Test 2: Integer Output",0dh,0ah,0
    
    decMsg      BYTE "Decimal value: ",0
    hexMsg      BYTE "Hexadecimal value: ",0
    binMsg      BYTE "Binary value: ",0
    
    testMsg3    BYTE 0dh,0ah,"Test 3: Register Dump",0dh,0ah,0
    
    testMsg4    BYTE 0dh,0ah,"Test 4: User Input",0dh,0ah,0
    promptMsg   BYTE "Enter your name: ",0
    greetMsg    BYTE "Hello, ",0
    exclaim     BYTE "!",0dh,0ah,0
    
    successMsg  BYTE 0dh,0ah,"============================================",0dh,0ah
                BYTE "  All Tests PASSED!",0dh,0ah
                BYTE "  Environment is configured correctly!",0dh,0ah
                BYTE "============================================",0dh,0ah,0
    
    ; Variable for user input
    userName    BYTE 50 DUP(0)      ; Buffer for user name (50 bytes)
    
    ; Test values
    testValue   DWORD 42            ; Test integer value (42 in decimal)

; ============================================
; CODE SEGMENT
; ============================================
.code
main PROC
    ; --------------------------------------------
    ; Display welcome message
    ; --------------------------------------------
    mov  edx, OFFSET welcomeMsg     ; Load address of welcomeMsg into EDX
    call WriteString                ; Display string pointed to by EDX
    
    ; --------------------------------------------
    ; TEST 1: String Output
    ; --------------------------------------------
    mov  edx, OFFSET testMsg1       ; Load address of test message
    call WriteString                ; Display the message
    
    ; --------------------------------------------
    ; TEST 2: Numeric Output (Various formats)
    ; --------------------------------------------
    mov  edx, OFFSET testMsg2       ; Display test 2 header
    call WriteString
    
    ; Display decimal value
    mov  edx, OFFSET decMsg         ; Display "Decimal value: "
    call WriteString
    mov  eax, testValue             ; Load test value (42) into EAX
    call WriteDec                   ; Write EAX as unsigned decimal
    call Crlf                       ; Print newline (Carriage Return + Line Feed)
    
    ; Display hexadecimal value
    mov  edx, OFFSET hexMsg         ; Display "Hexadecimal value: "
    call WriteString
    mov  eax, testValue             ; Load test value (42 = 0x2A) into EAX
    call WriteHex                   ; Write EAX as hexadecimal
    call Crlf                       ; Print newline
    
    ; Display binary value
    mov  edx, OFFSET binMsg         ; Display "Binary value: "
    call WriteString
    mov  eax, testValue             ; Load test value (42 = 00101010b) into EAX
    call WriteBin                   ; Write EAX as binary
    call Crlf                       ; Print newline
    
    ; --------------------------------------------
    ; TEST 3: Register Dump
    ; --------------------------------------------
    mov  edx, OFFSET testMsg3       ; Display test 3 header
    call WriteString
    
    ; Set up some register values for demonstration
    mov  eax, 12345678h             ; Set EAX to a test value
    mov  ebx, 0ABCDh                ; Set EBX to a test value
    mov  ecx, 100                   ; Set ECX to 100
    mov  edx, 200                   ; Set EDX to 200
    
    call DumpRegs                   ; Display all register values
                                    ; This is very useful for debugging!
    
    ; --------------------------------------------
    ; TEST 4: User Input
    ; --------------------------------------------
    mov  edx, OFFSET testMsg4       ; Display test 4 header
    call WriteString
    
    mov  edx, OFFSET promptMsg      ; Display "Enter your name: "
    call WriteString
    
    mov  edx, OFFSET userName       ; EDX = address of input buffer
    mov  ecx, LENGTHOF userName     ; ECX = maximum characters to read
    call ReadString                 ; Read string from user
                                    ; Returns: EAX = number of chars read
    
    ; Display greeting with user's name
    mov  edx, OFFSET greetMsg       ; Display "Hello, "
    call WriteString
    mov  edx, OFFSET userName       ; Display user's name
    call WriteString
    mov  edx, OFFSET exclaim        ; Display "!"
    call WriteString
    
    ; --------------------------------------------
    ; Display success message
    ; --------------------------------------------
    mov  edx, OFFSET successMsg     ; Display success message
    call WriteString
    
    ; --------------------------------------------
    ; Wait for user before exiting
    ; --------------------------------------------
    call WaitMsg                    ; Display "Press any key to continue..."
                                    ; and wait for keypress
    
    ; --------------------------------------------
    ; Exit program
    ; --------------------------------------------
    exit                            ; Macro that calls ExitProcess
                                    ; Terminates the program properly
main ENDP

; ============================================
; END OF PROGRAM
; ============================================
; The END directive marks the end of the
; source file and specifies the entry point
END main
