; ============================================================================
; HLSInterpreter.asm - Human Language Scripting Interpreter
; Complete Single-File Implementation
; x86 Assembly (MASM32) with Irvine32 Library
; ============================================================================
; BUILD INSTRUCTIONS:
;   ml /c /coff /Zi /Cp HLSInterpreter.asm
;   link /SUBSYSTEM:CONSOLE /DEBUG /OUT:HLSInterpreter.exe HLSInterpreter.obj Irvine32.lib kernel32.lib user32.lib
; 
; Or simply:
;   ml /Zi HLSInterpreter.asm /link /SUBSYSTEM:CONSOLE Irvine32.lib kernel32.lib user32.lib
; ============================================================================

INCLUDE Irvine32.inc

; Command type constants
CMD_UNKNOWN     EQU 0
CMD_EXIT        EQU 1
CMD_HELP        EQU 2
CMD_CLEAR       EQU 3
CMD_ADD         EQU 4
CMD_SUBTRACT    EQU 5
CMD_MULTIPLY    EQU 6
CMD_DIVIDE      EQU 7
CMD_STORE       EQU 8
CMD_SHOW        EQU 9
CMD_PRINT       EQU 10
CMD_INCREMENT   EQU 11
CMD_LOOP        EQU 12
CMD_ENDLOOP     EQU 13
CMD_IF          EQU 14
CMD_ENDIF       EQU 15
CMD_OUTPUT      EQU 16

.data
    ; ========== MAIN PROGRAM DATA ==========
    titleMsg    BYTE "================================================", 0dh, 0ah
                BYTE "  HUMAN LANGUAGE SCRIPTING INTERPRETER v1.0", 0dh, 0ah
                BYTE "  x86 Assembly (MASM32) with Irvine32", 0dh, 0ah
                BYTE "================================================", 0dh, 0ah, 0
    
    welcomeMsg  BYTE "Type 'help' for available commands or 'exit' to quit.", 0dh, 0ah, 0dh, 0ah, 0
    promptMsg   BYTE ">>> ", 0
    goodbyeMsg  BYTE 0dh, 0ah, "Thank you for using the interpreter. Goodbye!", 0dh, 0ah, 0
    
    ; Input buffer
    inputBuffer BYTE 256 DUP(?)
    bufferSize  DWORD 256
    
    ; Command structure
    cmdType     DWORD ?
    operand1    SDWORD ?
    operand2    SDWORD ?
    isOp1Var    BYTE ?
    isOp2Var    BYTE ?
    varName     BYTE 32 DUP(?)
    textData    BYTE 256 DUP(?)
    loopCount   DWORD ?
    condType    DWORD ?
    condOp1     SDWORD ?
    condOp2     SDWORD ?
    condIsVar1  BYTE ?
    condIsVar2  BYTE ?
    
    ; ========== PARSER DATA ==========
    cmdExit      BYTE "exit", 0
    cmdQuit      BYTE "quit", 0
    cmdHelp      BYTE "help", 0
    cmdClear     BYTE "clear", 0
    cmdAdd       BYTE "add", 0
    cmdSubtract  BYTE "subtract", 0
    cmdMultiply  BYTE "multiply", 0
    cmdDivide    BYTE "divide", 0
    cmdStore     BYTE "store", 0
    cmdShow      BYTE "show", 0
    cmdPrint     BYTE "print", 0
    cmdIncrement BYTE "increment", 0
    cmdLoop      BYTE "loop", 0
    cmdEndloop   BYTE "endloop", 0
    cmdIf        BYTE "if", 0
    cmdEndif     BYTE "endif", 0
    cmdOutput    BYTE "output", 0
    
    kwAnd        BYTE "and", 0
    kwFrom       BYTE "from", 0
    kwBy         BYTE "by", 0
    kwIn         BYTE "in", 0
    kwTimes      BYTE "times", 0
    kwEquals     BYTE "equals", 0
    
    errUnknown   BYTE "Error: Unknown command", 0
    errSyntax    BYTE "Error: Invalid syntax", 0
    
    tokenBuf     BYTE 64 DUP(?)
    
    ; ========== EXECUTOR DATA ==========
    MAX_VARS        EQU 50
    varNames        BYTE MAX_VARS * 32 DUP(0)
    varValues       SDWORD MAX_VARS DUP(0)
    varCount        DWORD 0
    
    helpMsg BYTE "Available Commands:", 0dh, 0ah
            BYTE "  add <num1> and <num2>        - Add two numbers", 0dh, 0ah
            BYTE "  subtract <num2> from <num1>  - Subtract numbers", 0dh, 0ah
            BYTE "  multiply <num1> and <num2>   - Multiply numbers", 0dh, 0ah
            BYTE "  divide <num1> by <num2>      - Divide numbers", 0dh, 0ah
            BYTE "  store <value> in <var>       - Store value in variable", 0dh, 0ah
            BYTE "  show <var>                   - Display variable value", 0dh, 0ah
            BYTE "  print <text>                 - Print text message", 0dh, 0ah
            BYTE "  increment <var>              - Increment variable by 1", 0dh, 0ah
            BYTE "  output <expr>                - Output expression value", 0dh, 0ah
            BYTE "  loop <N> times ... endloop   - Loop N times", 0dh, 0ah
            BYTE "  clear                        - Clear screen", 0dh, 0ah
            BYTE "  help                         - Show this help", 0dh, 0ah
            BYTE "  exit/quit                    - Exit program", 0dh, 0ah, 0
    
    resultMsg       BYTE "Result: ", 0
    quotientMsg     BYTE "Quotient: ", 0
    remainderMsg    BYTE ", Remainder: ", 0
    equalsMsg       BYTE " = ", 0
    storedMsg       BYTE "Stored: ", 0
    
    errDivZero      BYTE "Error: Division by zero", 0
    errVarNotFound  BYTE "Error: Variable '", 0
    errVarNotFound2 BYTE "' not defined", 0
    errTooManyVars  BYTE "Error: Too many variables (max 50)", 0
    
    ; ========== UTILITY DATA ==========
    tempBuf BYTE 64 DUP(?)

.code
; ============================================================================
; UTILITY PROCEDURES
; ============================================================================

; ----------------------------------------------------------------------------
; StrCompareNoCase - Case-insensitive string comparison
; Input: [ESP+8] = string1, [ESP+4] = string2
; Output: EAX = 0 if equal, non-zero if different
; ----------------------------------------------------------------------------
StrCompareNoCase PROC
    push ebp
    mov ebp, esp
    push esi
    push edi
    
    mov esi, [ebp+12]
    mov edi, [ebp+8]
    
CompareLoop:
    mov al, [esi]
    mov bl, [edi]
    
    cmp al, 'A'
    jb NoConvertA
    cmp al, 'Z'
    ja NoConvertA
    add al, 32
NoConvertA:
    
    cmp bl, 'A'
    jb NoConvertB
    cmp bl, 'Z'
    ja NoConvertB
    add bl, 32
NoConvertB:
    
    cmp al, bl
    jne NotEqual
    
    cmp al, 0
    je Equal
    
    inc esi
    inc edi
    jmp CompareLoop

Equal:
    xor eax, eax
    jmp CompareDone

NotEqual:
    mov eax, 1

CompareDone:
    pop edi
    pop esi
    pop ebp
    ret 8
StrCompareNoCase ENDP

; ----------------------------------------------------------------------------
; StrTrim - Remove leading and trailing whitespace
; Input: ESI = string address
; Output: ESI = trimmed string (modified in place)
; ----------------------------------------------------------------------------
StrTrim PROC
    push eax
    push edi
    push ecx
    
TrimLeadingLoop:
    mov al, [esi]
    cmp al, ' '
    jne TrimLeadingDone
    inc esi
    jmp TrimLeadingLoop

TrimLeadingDone:
    mov edi, esi
    xor ecx, ecx
FindEndLoop:
    mov al, [edi]
    cmp al, 0
    je FoundEnd
    inc edi
    inc ecx
    jmp FindEndLoop

FoundEnd:
    cmp ecx, 0
    je TrimDone
    dec edi

TrimTrailingLoop:
    mov al, [edi]
    cmp al, ' '
    jne TrimTrailingDone
    mov BYTE PTR [edi], 0
    dec edi
    dec ecx
    cmp ecx, 0
    je TrimDone
    jmp TrimTrailingLoop

TrimTrailingDone:
TrimDone:
    pop ecx
    pop edi
    pop eax
    ret
StrTrim ENDP

; ----------------------------------------------------------------------------
; StrToInt - Convert string to signed integer
; Input: [ESP+4] = string address
; Output: EAX = value, EDX = 1 if valid, 0 if invalid
; ----------------------------------------------------------------------------
StrToInt PROC
    push ebp
    mov ebp, esp
    push esi
    push ebx
    push ecx
    
    mov esi, [ebp+8]
    xor eax, eax
    xor ebx, ebx
    xor ecx, ecx
    
    mov dl, [esi]
    cmp dl, '-'
    jne CheckDigit
    mov ebx, 1
    inc esi

CheckDigit:
    mov dl, [esi]
    cmp dl, 0
    je ConversionDone
    
    cmp dl, '0'
    jb InvalidNumber
    cmp dl, '9'
    ja InvalidNumber
    
    sub dl, '0'
    movzx edx, dl
    
    imul eax, 10
    add eax, edx
    inc ecx
    inc esi
    jmp CheckDigit

ConversionDone:
    cmp ecx, 0
    je InvalidNumber
    
    cmp ebx, 1
    jne ValidNumber
    neg eax

ValidNumber:
    mov edx, 1
    jmp ConversionEnd

InvalidNumber:
    xor eax, eax
    xor edx, edx

ConversionEnd:
    pop ecx
    pop ebx
    pop esi
    pop ebp
    ret 4
StrToInt ENDP

; ----------------------------------------------------------------------------
; ExtractToken - Extract next token from string
; Input: [ESP+8] = source, [ESP+4] = destination
; Output: EAX = address after token (or 0 if no token)
; ----------------------------------------------------------------------------
ExtractToken PROC
    push ebp
    mov ebp, esp
    push esi
    push edi
    push ebx
    
    mov esi, [ebp+12]
    mov edi, [ebp+8]
    
SkipSpaces:
    mov al, [esi]
    cmp al, ' '
    jne StartCopy
    cmp al, 0
    je NoToken
    inc esi
    jmp SkipSpaces

StartCopy:
    cmp al, 0
    je NoToken
    
CopyLoop:
    mov al, [esi]
    cmp al, 0
    je EndToken
    cmp al, ' '
    je EndToken
    
    mov [edi], al
    inc esi
    inc edi
    jmp CopyLoop

EndToken:
    mov BYTE PTR [edi], 0
    mov eax, esi
    jmp ExtractDone

NoToken:
    xor eax, eax

ExtractDone:
    pop ebx
    pop edi
    pop esi
    pop ebp
    ret 8
ExtractToken ENDP

; ----------------------------------------------------------------------------
; SkipSpaces - Skip whitespace
; Input: ESI = string address
; Output: ESI = address after spaces
; ----------------------------------------------------------------------------
SkipSpaces PROC
    push eax

SkipLoop:
    mov al, [esi]
    cmp al, ' '
    jne SkipDone
    cmp al, 0
    je SkipDone
    inc esi
    jmp SkipLoop

SkipDone:
    pop eax
    ret
SkipSpaces ENDP

; ----------------------------------------------------------------------------
; lstrcpy - Copy string
; Input: [ESP+8] = destination, [ESP+4] = source
; ----------------------------------------------------------------------------
lstrcpy PROC
    push ebp
    mov ebp, esp
    push esi
    push edi
    
    mov edi, [ebp+12]
    mov esi, [ebp+8]

CopyStringLoop:
    mov al, [esi]
    mov [edi], al
    cmp al, 0
    je CopyStringDone
    inc esi
    inc edi
    jmp CopyStringLoop

CopyStringDone:
    pop edi
    pop esi
    pop ebp
    ret 8
lstrcpy ENDP

; ============================================================================
; EXECUTOR PROCEDURES
; ============================================================================

; ----------------------------------------------------------------------------
; InitializeVariables
; ----------------------------------------------------------------------------
InitializeVariables PROC
    push eax
    push ecx
    push edi
    
    mov varCount, 0
    
    mov edi, OFFSET varNames
    mov ecx, MAX_VARS * 32
    xor al, al
    rep stosb
    
    mov edi, OFFSET varValues
    mov ecx, MAX_VARS
    xor eax, eax
    rep stosd
    
    pop edi
    pop ecx
    pop eax
    ret
InitializeVariables ENDP

; ----------------------------------------------------------------------------
; CleanupVariables
; ----------------------------------------------------------------------------
CleanupVariables PROC
    ret
CleanupVariables ENDP

; ----------------------------------------------------------------------------
; FindVariable - Find variable by name
; Input: ESI = variable name
; Output: EAX = index (-1 if not found)
; ----------------------------------------------------------------------------
FindVariable PROC
    push ebx
    push ecx
    push edx
    push edi
    
    xor ebx, ebx
    mov ecx, varCount
    cmp ecx, 0
    je VarNotFound
    
FindLoop:
    mov eax, ebx
    mov edx, 32
    mul edx
    add eax, OFFSET varNames
    mov edi, eax
    
    push esi
    push edi
    call StrCompareNoCase
    cmp eax, 0
    je VarFound
    
    inc ebx
    loop FindLoop

VarNotFound:
    mov eax, -1
    jmp FindDone

VarFound:
    mov eax, ebx

FindDone:
    pop edi
    pop edx
    pop ecx
    pop ebx
    ret
FindVariable ENDP

; ----------------------------------------------------------------------------
; CreateVariable - Create new variable
; Input: ESI = variable name
; Output: EAX = index (-1 if error)
; ----------------------------------------------------------------------------
CreateVariable PROC
    push ebx
    push ecx
    push edi
    push esi
    
    mov eax, varCount
    cmp eax, MAX_VARS
    jge CreateError
    
    mov edx, 32
    mul edx
    add eax, OFFSET varNames
    mov edi, eax
    
CopyNameLoop:
    mov al, [esi]
    mov [edi], al
    cmp al, 0
    je CopyDone
    inc esi
    inc edi
    jmp CopyNameLoop

CopyDone:
    mov eax, varCount
    inc varCount
    jmp CreateSuccess

CreateError:
    mov edx, OFFSET errTooManyVars
    call WriteString
    call Crlf
    mov eax, -1

CreateSuccess:
    pop esi
    pop edi
    pop ecx
    pop ebx
    ret
CreateVariable ENDP

; ----------------------------------------------------------------------------
; GetVariableValue - Get variable value
; Input: ESI = variable name
; Output: EAX = value, EDX = 1 if success
; ----------------------------------------------------------------------------
GetVariableValue PROC
    push ebx
    push esi
    
    call FindVariable
    cmp eax, -1
    je GetVarError
    
    mov ebx, eax
    mov eax, [varValues + ebx*4]
    mov edx, 1
    jmp GetVarDone

GetVarError:
    mov edx, OFFSET errVarNotFound
    call WriteString
    mov edx, esi
    call WriteString
    mov edx, OFFSET errVarNotFound2
    call WriteString
    call Crlf
    xor eax, eax
    xor edx, edx

GetVarDone:
    pop esi
    pop ebx
    ret
GetVariableValue ENDP

; ----------------------------------------------------------------------------
; SetVariableValue - Set variable value
; Input: ESI = variable name, EAX = value
; ----------------------------------------------------------------------------
SetVariableValue PROC
    push eax
    push ebx
    push esi
    
    mov ebx, eax
    
    call FindVariable
    cmp eax, -1
    jne SetExisting
    
    call CreateVariable
    cmp eax, -1
    je SetDone

SetExisting:
    mov [varValues + eax*4], ebx

SetDone:
    pop esi
    pop ebx
    pop eax
    ret
SetVariableValue ENDP

; ----------------------------------------------------------------------------
; ExecuteCommand - Execute parsed command
; Parameters: command structure on stack
; ----------------------------------------------------------------------------
ExecuteCommand PROC
    push ebp
    mov ebp, esp
    push eax
    push ebx
    push ecx
    push edx
    push esi
    push edi
    
    mov esi, [ebp+8]
    mov eax, [esi]
    
    cmp eax, CMD_HELP
    je ExecHelp
    cmp eax, CMD_CLEAR
    je ExecClear
    cmp eax, CMD_PRINT
    je ExecPrint
    cmp eax, CMD_ADD
    je ExecAdd
    cmp eax, CMD_SUBTRACT
    je ExecSubtract
    cmp eax, CMD_MULTIPLY
    je ExecMultiply
    cmp eax, CMD_DIVIDE
    je ExecDivide
    cmp eax, CMD_STORE
    je ExecStore
    cmp eax, CMD_SHOW
    je ExecShow
    cmp eax, CMD_INCREMENT
    je ExecIncrement
    cmp eax, CMD_OUTPUT
    je ExecOutput
    jmp ExecDone

ExecHelp:
    mov edx, OFFSET helpMsg
    call WriteString
    jmp ExecDone

ExecClear:
    call Clrscr
    jmp ExecDone

ExecPrint:
    mov esi, [ebp+20]
    mov edx, esi
    call WriteString
    jmp ExecDone

ExecAdd:
    call GetOperandValues
    add eax, ebx
    
    mov edx, OFFSET resultMsg
    call WriteString
    call WriteInt
    jmp ExecDone

ExecSubtract:
    call GetOperandValues
    sub eax, ebx
    
    mov edx, OFFSET resultMsg
    call WriteString
    call WriteInt
    jmp ExecDone

ExecMultiply:
    call GetOperandValues
    imul eax, ebx
    
    mov edx, OFFSET resultMsg
    call WriteString
    call WriteInt
    jmp ExecDone

ExecDivide:
    call GetOperandValues
    
    cmp ebx, 0
    je DivByZero
    
    cdq
    idiv ebx
    
    push edx
    mov edx, OFFSET quotientMsg
    call WriteString
    call WriteInt
    
    mov edx, OFFSET remainderMsg
    call WriteString
    pop eax
    call WriteInt
    jmp ExecDone

DivByZero:
    mov edx, OFFSET errDivZero
    call WriteString
    jmp ExecDone

ExecStore:
    mov esi, [ebp+16]
    mov al, [esi]
    cmp al, 0
    je StoreImmediate
    
    mov esi, [ebp+24]
    call GetVariableValue
    cmp edx, 1
    jne ExecDone
    jmp StoreValue

StoreImmediate:
    mov esi, [ebp+12]
    mov eax, [esi]

StoreValue:
    push eax
    mov esi, [ebp+24]
    pop eax
    call SetVariableValue
    
    mov edx, OFFSET storedMsg
    call WriteString
    mov edx, esi
    call WriteString
    mov edx, OFFSET equalsMsg
    call WriteString
    call WriteInt
    jmp ExecDone

ExecShow:
    mov esi, [ebp+24]
    push esi
    call GetVariableValue
    pop esi
    cmp edx, 1
    jne ExecDone
    
    push eax
    mov edx, esi
    call WriteString
    mov edx, OFFSET equalsMsg
    call WriteString
    pop eax
    call WriteInt
    jmp ExecDone

ExecIncrement:
    mov esi, [ebp+24]
    call GetVariableValue
    cmp edx, 1
    jne ExecDone
    
    inc eax
    call SetVariableValue
    jmp ExecDone

ExecOutput:
    mov esi, [ebp+16]
    mov al, [esi]
    cmp al, 0
    je OutputImmediate
    
    mov esi, [ebp+24]
    call GetVariableValue
    cmp edx, 1
    jne ExecDone
    jmp OutputValue

OutputImmediate:
    mov esi, [ebp+12]
    mov eax, [esi]

OutputValue:
    call WriteInt
    jmp ExecDone

ExecDone:
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    pop eax
    pop ebp
    ret 52

GetOperandValues:
    push esi
    push edx
    
    mov esi, [ebp+16]
    mov al, [esi]
    cmp al, 0
    je GetOp1Immediate
    
    mov esi, [ebp+24]
    call GetVariableValue
    jmp GetOp2

GetOp1Immediate:
    mov esi, [ebp+12]
    mov eax, [esi]

GetOp2:
    push eax
    
    mov esi, [ebp+18]
    mov al, [esi]
    cmp al, 0
    je GetOp2Immediate
    
    mov esi, [ebp+24]
    call GetVariableValue
    mov ebx, eax
    jmp GetOpDone

GetOp2Immediate:
    mov esi, [ebp+14]
    mov ebx, [esi]

GetOpDone:
    pop eax
    pop edx
    pop esi
    ret

ExecuteCommand ENDP

; ============================================================================
; PARSER PROCEDURES
; ============================================================================

; ----------------------------------------------------------------------------
; ParseCommand - Main parsing procedure
; Parameters: command structure on stack
; Returns: EAX = 1 if success, 0 if error
; ----------------------------------------------------------------------------
ParseCommand PROC
    push ebp
    mov ebp, esp
    push esi
    push edi
    push ebx
    
    mov esi, [ebp+8]
    
    push esi
    push OFFSET tokenBuf
    call ExtractToken
    
    cmp eax, 0
    je ParseError
    
    mov esi, eax
    
    mov edi, [ebp+12]
    mov DWORD PTR [edi], CMD_UNKNOWN
    
    mov edi, [ebp+24]
    mov BYTE PTR [edi], 0
    mov edi, [ebp+28]
    mov BYTE PTR [edi], 0
    
    push OFFSET cmdExit
    push OFFSET tokenBuf
    call StrCompareNoCase
    cmp eax, 0
    je ParseExit
    
    push OFFSET cmdQuit
    push OFFSET tokenBuf
    call StrCompareNoCase
    cmp eax, 0
    je ParseExit
    
    push OFFSET cmdHelp
    push OFFSET tokenBuf
    call StrCompareNoCase
    cmp eax, 0
    je ParseHelp
    
    push OFFSET cmdClear
    push OFFSET tokenBuf
    call StrCompareNoCase
    cmp eax, 0
    je ParseClear
    
    push OFFSET cmdPrint
    push OFFSET tokenBuf
    call StrCompareNoCase
    cmp eax, 0
    je ParsePrint
    
    push OFFSET cmdShow
    push OFFSET tokenBuf
    call StrCompareNoCase
    cmp eax, 0
    je ParseShow
    
    push OFFSET cmdIncrement
    push OFFSET tokenBuf
    call StrCompareNoCase
    cmp eax, 0
    je ParseIncrement
    
    push OFFSET cmdAdd
    push OFFSET tokenBuf
    call StrCompareNoCase
    cmp eax, 0
    je ParseAdd
    
    push OFFSET cmdSubtract
    push OFFSET tokenBuf
    call StrCompareNoCase
    cmp eax, 0
    je ParseSubtract
    
    push OFFSET cmdMultiply
    push OFFSET tokenBuf
    call StrCompareNoCase
    cmp eax, 0
    je ParseMultiply
    
    push OFFSET cmdDivide
    push OFFSET tokenBuf
    call StrCompareNoCase
    cmp eax, 0
    je ParseDivide
    
    push OFFSET cmdStore
    push OFFSET tokenBuf
    call StrCompareNoCase
    cmp eax, 0
    je ParseStore
    
    push OFFSET cmdLoop
    push OFFSET tokenBuf
    call StrCompareNoCase
    cmp eax, 0
    je ParseLoop
    
    push OFFSET cmdEndloop
    push OFFSET tokenBuf
    call StrCompareNoCase
    cmp eax, 0
    je ParseEndloop
    
    push OFFSET cmdOutput
    push OFFSET tokenBuf
    call StrCompareNoCase
    cmp eax, 0
    je ParseOutput
    
    push OFFSET cmdIf
    push OFFSET tokenBuf
    call StrCompareNoCase
    cmp eax, 0
    je ParseIf
    
    push OFFSET cmdEndif
    push OFFSET tokenBuf
    call StrCompareNoCase
    cmp eax, 0
    je ParseEndif
    
    jmp ParseError

ParseExit:
    mov edi, [ebp+12]
    mov DWORD PTR [edi], CMD_EXIT
    jmp ParseSuccess

ParseHelp:
    mov edi, [ebp+12]
    mov DWORD PTR [edi], CMD_HELP
    jmp ParseSuccess

ParseClear:
    mov edi, [ebp+12]
    mov DWORD PTR [edi], CMD_CLEAR
    jmp ParseSuccess

ParsePrint:
    mov edi, [ebp+12]
    mov DWORD PTR [edi], CMD_PRINT
    
    call SkipSpaces
    mov edi, [ebp+36]
    
CopyPrintText:
    mov al, [esi]
    cmp al, 0
    je ParseSuccess
    mov [edi], al
    inc esi
    inc edi
    jmp CopyPrintText

ParseShow:
    mov edi, [ebp+12]
    mov DWORD PTR [edi], CMD_SHOW
    
    call SkipSpaces
    push esi
    push OFFSET tokenBuf
    call ExtractToken
    cmp eax, 0
    je ParseError
    
    mov esi, OFFSET tokenBuf
    mov edi, [ebp+32]
CopyShowVar:
    mov al, [esi]
    mov [edi], al
    cmp al, 0
    je ParseSuccess
    inc esi
    inc edi
    jmp CopyShowVar

ParseIncrement:
    mov edi, [ebp+12]
    mov DWORD PTR [edi], CMD_INCREMENT
    
    call SkipSpaces
    push esi
    push OFFSET tokenBuf
    call ExtractToken
    cmp eax, 0
    je ParseError
    
    mov esi, OFFSET tokenBuf
    mov edi, [ebp+32]
CopyIncrVar:
    mov al, [esi]
    mov [edi], al
    cmp al, 0
    je ParseSuccess
    inc esi
    inc edi
    jmp CopyIncrVar

ParseAdd:
    mov edi, [ebp+12]
    mov DWORD PTR [edi], CMD_ADD
    jmp ParseBinaryOp

ParseSubtract:
    mov edi, [ebp+12]
    mov DWORD PTR [edi], CMD_SUBTRACT
    jmp ParseBinaryOp

ParseMultiply:
    mov edi, [ebp+12]
    mov DWORD PTR [edi], CMD_MULTIPLY
    jmp ParseBinaryOp

ParseDivide:
    mov edi, [ebp+12]
    mov DWORD PTR [edi], CMD_DIVIDE
    jmp ParseBinaryOp

ParseBinaryOp:
    call SkipSpaces
    push esi
    push OFFSET tokenBuf
    call ExtractToken
    cmp eax, 0
    je ParseError
    mov esi, eax
    
    push OFFSET tokenBuf
    call StrToInt
    cmp edx, 1
    je StoreOp1Number
    
    mov edi, [ebp+24]
    mov BYTE PTR [edi], 1
    
    mov edi, [ebp+32]
    push edi
    push OFFSET tokenBuf
    call lstrcpy
    jmp SkipConnector

StoreOp1Number:
    mov edi, [ebp+16]
    mov [edi], eax
    mov edi, [ebp+24]
    mov BYTE PTR [edi], 0

SkipConnector:
    call SkipSpaces
    push esi
    push OFFSET tokenBuf
    call ExtractToken
    cmp eax, 0
    je ParseError
    mov esi, eax
    
    call SkipSpaces
    push esi
    push OFFSET tokenBuf
    call ExtractToken
    cmp eax, 0
    je ParseError
    mov esi, eax
    
    push OFFSET tokenBuf
    call StrToInt
    cmp edx, 1
    je StoreOp2Number
    
    mov edi, [ebp+28]
    mov BYTE PTR [edi], 1
    jmp ParseSuccess

StoreOp2Number:
    mov edi, [ebp+20]
    mov [edi], eax
    mov edi, [ebp+28]
    mov BYTE PTR [edi], 0
    jmp ParseSuccess

ParseStore:
    mov edi, [ebp+12]
    mov DWORD PTR [edi], CMD_STORE
    
    call SkipSpaces
    push esi
    push OFFSET tokenBuf
    call ExtractToken
    cmp eax, 0
    je ParseError
    mov esi, eax
    
    push OFFSET tokenBuf
    call StrToInt
    cmp edx, 1
    je StoreValue
    
    mov edi, [ebp+24]
    mov BYTE PTR [edi], 1
    jmp SkipStoreIn

StoreValue:
    mov edi, [ebp+16]
    mov [edi], eax

SkipStoreIn:
    call SkipSpaces
    push esi
    push OFFSET tokenBuf
    call ExtractToken
    cmp eax, 0
    je ParseError
    mov esi, eax
    
    call SkipSpaces
    push esi
    push OFFSET tokenBuf
    call ExtractToken
    cmp eax, 0
    je ParseError
    
    mov esi, OFFSET tokenBuf
    mov edi, [ebp+32]
CopyStoreVar:
    mov al, [esi]
    mov [edi], al
    cmp al, 0
    je ParseSuccess
    inc esi
    inc edi
    jmp CopyStoreVar

ParseLoop:
    mov edi, [ebp+12]
    mov DWORD PTR [edi], CMD_LOOP
    
    call SkipSpaces
    push esi
    push OFFSET tokenBuf
    call ExtractToken
    cmp eax, 0
    je ParseError
    mov esi, eax
    
    push OFFSET tokenBuf
    call StrToInt
    cmp edx, 1
    jne ParseError
    
    mov edi, [ebp+40]
    mov [edi], eax
    jmp ParseSuccess

ParseEndloop:
    mov edi, [ebp+12]
    mov DWORD PTR [edi], CMD_ENDLOOP
    jmp ParseSuccess

ParseOutput:
    mov edi, [ebp+12]
    mov DWORD PTR [edi], CMD_OUTPUT
    
    call SkipSpaces
    push esi
    push OFFSET tokenBuf
    call ExtractToken
    cmp eax, 0
    je ParseError
    
    push OFFSET tokenBuf
    call StrToInt
    cmp edx, 1
    je StoreOutputNum
    
    mov edi, [ebp+24]
    mov BYTE PTR [edi], 1
    
    mov esi, OFFSET tokenBuf
    mov edi, [ebp+32]
CopyOutputVar:
    mov al, [esi]
    mov [edi], al
    cmp al, 0
    je ParseSuccess
    inc esi
    inc edi
    jmp CopyOutputVar

StoreOutputNum:
    mov edi, [ebp+16]
    mov [edi], eax
    mov edi, [ebp+24]
    mov BYTE PTR [edi], 0
    jmp ParseSuccess

ParseIf:
    mov edi, [ebp+12]
    mov DWORD PTR [edi], CMD_IF
    jmp ParseSuccess

ParseEndif:
    mov edi, [ebp+12]
    mov DWORD PTR [edi], CMD_ENDIF
    jmp ParseSuccess

ParseError:
    mov edx, OFFSET errSyntax
    call WriteString
    call Crlf
    xor eax, eax
    jmp ParseDone

ParseSuccess:
    mov eax, 1

ParseDone:
    pop ebx
    pop edi
    pop esi
    pop ebp
    ret 56

ParseCommand ENDP

; ============================================================================
; MAIN PROGRAM
; ============================================================================

main PROC
    call InitializeVariables
    
    call Clrscr
    mov edx, OFFSET titleMsg
    call WriteString
    mov edx, OFFSET welcomeMsg
    call WriteString
    
MainLoop:
    mov edx, OFFSET promptMsg
    call WriteString
    
    mov edx, OFFSET inputBuffer
    mov ecx, bufferSize
    call ReadString
    
    cmp eax, 0
    je MainLoop
    
    mov esi, OFFSET inputBuffer
    call StrTrim
    
    cmp BYTE PTR [esi], 0
    je MainLoop
    
    push OFFSET condIsVar2
    push OFFSET condIsVar1
    push OFFSET condOp2
    push OFFSET condOp1
    push OFFSET condType
    push OFFSET loopCount
    push OFFSET textData
    push OFFSET varName
    push OFFSET isOp2Var
    push OFFSET isOp1Var
    push OFFSET operand2
    push OFFSET operand1
    push OFFSET cmdType
    push OFFSET inputBuffer
    call ParseCommand
    
    cmp eax, 0
    je MainLoop
    
    mov eax, cmdType
    cmp eax, CMD_EXIT
    je ExitProgram
    
    push OFFSET condIsVar2
    push OFFSET condIsVar1
    push OFFSET condOp2
    push OFFSET condOp1
    push OFFSET condType
    push OFFSET loopCount
    push OFFSET textData
    push OFFSET varName
    push OFFSET isOp2Var
    push OFFSET isOp1Var
    push OFFSET operand2
    push OFFSET operand1
    push OFFSET cmdType
    call ExecuteCommand
    
    call Crlf
    jmp MainLoop
    
ExitProgram:
    mov edx, OFFSET goodbyeMsg
    call WriteString
    call CleanupVariables
    
    INVOKE ExitProcess, 0
main ENDP

END main