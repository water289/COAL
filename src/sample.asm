; ============================================
; sample.asm - Sample Assembly Program
; ============================================
; This program demonstrates various Irvine32
; procedures and basic x86 assembly concepts
; including variables, arithmetic, loops, and
; conditional statements.
; ============================================

INCLUDE Irvine32.inc

; ============================================
; DATA SECTION
; ============================================
.data
    ; Program title
    title       BYTE "===========================================",0dh,0ah
                BYTE "  Sample Assembly Program",0dh,0ah
                BYTE "  Demonstrating Basic Operations",0dh,0ah
                BYTE "===========================================",0dh,0ah,0
    
    ; Menu
    menu        BYTE 0dh,0ah,"Choose an operation:",0dh,0ah
                BYTE "1. Addition",0dh,0ah
                BYTE "2. Subtraction",0dh,0ah
                BYTE "3. Multiplication",0dh,0ah
                BYTE "4. Array Sum",0dh,0ah
                BYTE "5. Fibonacci Sequence",0dh,0ah
                BYTE "6. Exit",0dh,0ah
                BYTE "Enter choice (1-6): ",0
    
    ; Prompts
    prompt1     BYTE "Enter first number: ",0
    prompt2     BYTE "Enter second number: ",0
    resultMsg   BYTE "Result: ",0
    arrayMsg    BYTE 0dh,0ah,"Array Sum Example",0dh,0ah,0
    fibMsg      BYTE 0dh,0ah,"Fibonacci Sequence (first 10 terms):",0dh,0ah,0
    invalidMsg  BYTE "Invalid choice! Please try again.",0dh,0ah,0
    
    ; Variables
    choice      DWORD ?
    num1        DWORD ?
    num2        DWORD ?
    result      DWORD ?
    
    ; Array for demonstration
    array       DWORD 10, 20, 30, 40, 50
    arraySize   DWORD LENGTHOF array

; ============================================
; CODE SECTION
; ============================================
.code
main PROC
    ; Display title
    mov  edx, OFFSET title
    call WriteString
    
mainLoop:
    ; Display menu
    mov  edx, OFFSET menu
    call WriteString
    
    ; Get user choice
    call ReadInt
    mov  choice, eax
    
    ; Process choice
    cmp  eax, 1
    je   doAddition
    cmp  eax, 2
    je   doSubtraction
    cmp  eax, 3
    je   doMultiplication
    cmp  eax, 4
    je   doArraySum
    cmp  eax, 5
    je   doFibonacci
    cmp  eax, 6
    je   exitProgram
    
    ; Invalid choice
    mov  edx, OFFSET invalidMsg
    call WriteString
    jmp  mainLoop

doAddition:
    call GetTwoNumbers
    mov  eax, num1
    add  eax, num2
    mov  result, eax
    call DisplayResult
    jmp  mainLoop

doSubtraction:
    call GetTwoNumbers
    mov  eax, num1
    sub  eax, num2
    mov  result, eax
    call DisplayResult
    jmp  mainLoop

doMultiplication:
    call GetTwoNumbers
    mov  eax, num1
    imul eax, num2          ; Signed multiplication
    mov  result, eax
    call DisplayResult
    jmp  mainLoop

doArraySum:
    call ArraySum
    jmp  mainLoop

doFibonacci:
    call Fibonacci
    jmp  mainLoop

exitProgram:
    call Crlf
    call WaitMsg
    exit
main ENDP

; ============================================
; GetTwoNumbers Procedure
; Gets two integers from user
; Receives: nothing
; Returns: num1 and num2 variables populated
; ============================================
GetTwoNumbers PROC
    call Crlf
    mov  edx, OFFSET prompt1
    call WriteString
    call ReadInt
    mov  num1, eax
    
    mov  edx, OFFSET prompt2
    call WriteString
    call ReadInt
    mov  num2, eax
    
    ret
GetTwoNumbers ENDP

; ============================================
; DisplayResult Procedure
; Displays the result
; Receives: result variable
; Returns: nothing
; ============================================
DisplayResult PROC
    call Crlf
    mov  edx, OFFSET resultMsg
    call WriteString
    mov  eax, result
    call WriteInt
    call Crlf
    ret
DisplayResult ENDP

; ============================================
; ArraySum Procedure
; Calculates and displays sum of array elements
; Receives: array, arraySize
; Returns: nothing
; ============================================
ArraySum PROC
    pushad                  ; Save all registers
    
    ; Display message
    mov  edx, OFFSET arrayMsg
    call WriteString
    
    ; Display array elements
    mov  esi, OFFSET array
    mov  ecx, arraySize
    
displayLoop:
    mov  eax, [esi]
    call WriteDec
    mov  al, ' '
    call WriteChar
    add  esi, TYPE array
    loop displayLoop
    
    call Crlf
    
    ; Calculate sum
    mov  esi, OFFSET array
    mov  ecx, arraySize
    mov  eax, 0             ; Sum accumulator
    
sumLoop:
    add  eax, [esi]
    add  esi, TYPE array
    loop sumLoop
    
    ; Display sum
    mov  edx, OFFSET resultMsg
    call WriteString
    call WriteDec
    call Crlf
    
    popad                   ; Restore all registers
    ret
ArraySum ENDP

; ============================================
; Fibonacci Procedure
; Generates and displays first 10 Fibonacci numbers
; Uses: F(n) = F(n-1) + F(n-2), F(0)=0, F(1)=1
; Receives: nothing
; Returns: nothing
; ============================================
Fibonacci PROC
    pushad
    
    ; Display message
    mov  edx, OFFSET fibMsg
    call WriteString
    
    ; Initialize
    mov  ecx, 10            ; Generate 10 numbers
    mov  eax, 0             ; F(n-2)
    mov  ebx, 1             ; F(n-1)
    
    ; Display first number (0)
    call WriteDec
    mov  al, ' '
    call WriteChar
    
    ; Display second number (1)
    mov  eax, ebx
    call WriteDec
    mov  al, ' '
    call WriteChar
    
    ; Generate remaining numbers
    mov  eax, 0             ; Reset F(n-2)
    sub  ecx, 2             ; Already displayed 2 numbers
    
fibLoop:
    push eax                ; Save F(n-2)
    add  eax, ebx           ; F(n) = F(n-2) + F(n-1)
    push eax                ; Save F(n)
    
    ; Display F(n)
    call WriteDec
    mov  al, ' '
    call WriteChar
    
    ; Update for next iteration
    pop  eax                ; EAX = F(n)
    mov  ebx, eax           ; EBX = F(n) becomes F(n-1)
    pop  eax                ; EAX = F(n-2) from stack
    mov  eax, ebx           ; Update: old F(n-1) becomes new F(n-2)
    push ebx                ; Save current F(n-1)
    
    loop fibLoop
    
    add  esp, 4             ; Clean up stack
    call Crlf
    call Crlf
    
    popad
    ret
Fibonacci ENDP

END main
