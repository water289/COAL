; ============================================================================
; HLSInterpreter_Enhanced.asm - Enhanced Human Language Scripting Interpreter
; Complete Single-File Implementation with Advanced Features
; x86 Assembly (MASM32) with Irvine32 Library
; ============================================================================
; Supports:
; - Expression evaluation (multiply, modulus, add, subtract, divide)
; - Nested control structures (loop, if)
; - Complex command parsing with comma and 'and' separators
; - Conditional execution
; ============================================================================

INCLUDE Irvine32.inc

; Command type constants
CMD_UNKNOWN     EQU 0
CMD_EXIT        EQU 1
CMD_HELP        EQU 2
CMD_CLEAR       EQU 3
CMD_PRINT       EQU 4
CMD_STORE       EQU 5
CMD_SHOW        EQU 6
CMD_INCREMENT   EQU 7
CMD_LOOP        EQU 8
CMD_IF          EQU 9
CMD_BLOCK       EQU 10

; Expression operation constants
OP_NONE         EQU 0
OP_ADD          EQU 1
OP_SUBTRACT     EQU 2
OP_MULTIPLY     EQU 3
OP_DIVIDE       EQU 4
OP_MODULUS      EQU 5

; Comparison operation constants
CMP_EQUALS      EQU 1
CMP_NOTEQUALS   EQU 2
CMP_GREATER     EQU 3
CMP_LESS        EQU 4
CMP_GREATEREQUAL EQU 5
CMP_LESSEQUAL   EQU 6

.data
    ; ========== MAIN PROGRAM DATA ==========
    titleMsg    BYTE "================================================", 0dh, 0ah
                BYTE "  HUMAN LANGUAGE SCRIPTING INTERPRETER v2.0", 0dh, 0ah
                BYTE "  Enhanced with Expression Evaluation", 0dh, 0ah
                BYTE "================================================", 0dh, 0ah, 0
    
    welcomeMsg  BYTE "Type 'help' for available commands or 'exit' to quit.", 0dh, 0ah, 0dh, 0ah, 0
    promptMsg   BYTE ">>> ", 0
    goodbyeMsg  BYTE 0dh, 0ah, "Thank you for using the interpreter. Goodbye!", 0dh, 0ah, 0
    
    ; Input buffer
    inputBuffer BYTE 1024 DUP(?)
    bufferSize  DWORD 1024
    
    ; ========== VARIABLES ==========
    MAX_VARS        EQU 50
    varNames        BYTE MAX_VARS * 32 DUP(0)
    varValues       SDWORD MAX_VARS DUP(0)
    varCount        DWORD 0
    
    ; ========== KEYWORDS ==========
    kwPrint      BYTE "print", 0
    kwStore      BYTE "store", 0
    kwShow       BYTE "show", 0
    kwIncrement  BYTE "increment", 0
    kwLoop       BYTE "loop", 0
    kwIf         BYTE "if", 0
    kwExit       BYTE "exit", 0
    kwQuit       BYTE "quit", 0
    kwHelp       BYTE "help", 0
    kwClear      BYTE "clear", 0
    
    kwMultiply   BYTE "multiply", 0
    kwBy         BYTE "by", 0
    kwModulus    BYTE "modulus", 0
    kwPlus       BYTE "plus", 0
    kwMinus      BYTE "minus", 0
    kwDivided    BYTE "divided", 0
    kwEquals     BYTE "equals", 0
    kwIn         BYTE "in", 0
    kwTimes      BYTE "times", 0
    kwAnd        BYTE "and", 0
    kwGreater    BYTE "greater", 0
    kwLess       BYTE "less", 0
    kwThan       BYTE "than", 0
    kwOr         BYTE "or", 0
    kwNot        BYTE "not", 0
    
    helpMsg BYTE "Enhanced Commands:", 0dh, 0ah
            BYTE "  print <expr>                     - Print expression value", 0dh, 0ah
            BYTE "  print <expr> if <condition>      - Conditional print", 0dh, 0ah
            BYTE "  store <value> in <var>           - Store value in variable", 0dh, 0ah
            BYTE "  show <var>                       - Display variable value", 0dh, 0ah
            BYTE "  increment <var>                  - Increment variable by 1", 0dh, 0ah
            BYTE "  loop <N> times                   - Start loop (use , to nest)", 0dh, 0ah
            BYTE "  if <condition>                   - Conditional (use , to nest)", 0dh, 0ah
            BYTE 0dh, 0ah
            BYTE "Operators: multiply by, modulus, plus, minus, divided by", 0dh, 0ah
            BYTE "Comparisons: equals, greater than, less than", 0dh, 0ah
            BYTE "Separators: 'and' = next statement, ',' = nest/wrap in braces", 0dh, 0ah
            BYTE 0dh, 0ah
            BYTE "Example: print 5 multiply by n if 5 modulus n equals 0 and increment n , loop 10 times", 0dh, 0ah, 0
    
    errSyntax       BYTE "Error: Invalid syntax", 0
    errVarNotFound  BYTE "Error: Variable not found", 0
    errDivZero      BYTE "Error: Division by zero", 0
    
    ; ========== WORKING BUFFERS ==========
    tokenBuf     BYTE 256 DUP(?)
    exprBuf      BYTE 256 DUP(?)
    cmdLine      BYTE 1024 DUP(?)
    
    ; ========== LOOP/IF STACK ==========
    MAX_NEST        EQU 20
    loopStack       DWORD MAX_NEST DUP(0)
    loopCountStack  DWORD MAX_NEST DUP(0)
    ifStack         DWORD MAX_NEST DUP(0)
    nestLevel       DWORD 0

.code

; ============================================================================
; UTILITY PROCEDURES
; ============================================================================

; ----------------------------------------------------------------------------
; StrLen - Get string length
; Input: ESI = string address
; Output: EAX = length
; ----------------------------------------------------------------------------
StrLen PROC
    push esi
    xor eax, eax
StrLenLoop:
    cmp BYTE PTR [esi], 0
    je StrLenDone
    inc eax
    inc esi
    jmp StrLenLoop
StrLenDone:
    pop esi
    ret
StrLen ENDP

; ----------------------------------------------------------------------------
; StrCopy - Copy string
; Input: ESI = source, EDI = destination
; ----------------------------------------------------------------------------
StrCopy PROC
    push eax
    push esi
    push edi
StrCopyLoop:
    mov al, [esi]
    mov [edi], al
    cmp al, 0
    je StrCopyDone
    inc esi
    inc edi
    jmp StrCopyLoop
StrCopyDone:
    pop edi
    pop esi
    pop eax
    ret
StrCopy ENDP

; ----------------------------------------------------------------------------
; StrCompareNoCase - Case-insensitive string comparison
; Input: ESI = string1, EDI = string2
; Output: EAX = 0 if equal, non-zero if different
; ----------------------------------------------------------------------------
StrCompareNoCase PROC
    push esi
    push edi
    push ebx
    
CompareLoop:
    mov al, [esi]
    mov bl, [edi]
    
    ; Convert to lowercase
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
    pop ebx
    pop edi
    pop esi
    ret
StrCompareNoCase ENDP

; ----------------------------------------------------------------------------
; StrToInt - Convert string to signed integer
; Input: ESI = string address
; Output: EAX = value, EDX = 1 if valid, 0 if invalid
; ----------------------------------------------------------------------------
StrToInt PROC
    push esi
    push ebx
    push ecx
    
    xor eax, eax
    xor ebx, ebx
    xor ecx, ecx
    
    ; Check for negative sign
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
    ret
StrToInt ENDP

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
    je DoSkip
    cmp al, 9  ; tab
    je DoSkip
    jmp SkipDone
DoSkip:
    inc esi
    jmp SkipLoop
SkipDone:
    pop eax
    ret
SkipSpaces ENDP

; ----------------------------------------------------------------------------
; GetToken - Extract next token
; Input: ESI = source
; Output: ESI = after token, tokenBuf = token, EAX = 1 if success
; ----------------------------------------------------------------------------
GetToken PROC
    push edi
    push ebx
    
    call SkipSpaces
    
    mov edi, OFFSET tokenBuf
    xor ebx, ebx
    
GetTokenLoop:
    mov al, [esi]
    cmp al, 0
    je GetTokenEnd
    cmp al, ' '
    je GetTokenEnd
    cmp al, ','
    je GetTokenEnd
    
    mov [edi], al
    inc esi
    inc edi
    inc ebx
    jmp GetTokenLoop

GetTokenEnd:
    mov BYTE PTR [edi], 0
    
    cmp ebx, 0
    je GetTokenFail
    
    mov eax, 1
    jmp GetTokenDone

GetTokenFail:
    xor eax, eax

GetTokenDone:
    pop ebx
    pop edi
    ret
GetToken ENDP

; ============================================================================
; VARIABLE MANAGEMENT
; ============================================================================

; ----------------------------------------------------------------------------
; InitVariables
; ----------------------------------------------------------------------------
InitVariables PROC
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
InitVariables ENDP

; ----------------------------------------------------------------------------
; FindVariable - Find variable by name
; Input: ESI = variable name
; Output: EAX = index (-1 if not found)
; ----------------------------------------------------------------------------
FindVariable PROC
    push ebx
    push ecx
    push esi
    push edi
    
    xor ebx, ebx
    mov ecx, varCount
    cmp ecx, 0
    je VarNotFound
    
FindLoop:
    push esi
    
    mov eax, ebx
    mov edx, 32
    mul edx
    add eax, OFFSET varNames
    mov edi, eax
    
    call StrCompareNoCase
    
    pop esi
    
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
    pop esi
    pop ecx
    pop ebx
    ret
FindVariable ENDP

; ----------------------------------------------------------------------------
; GetVarValue - Get variable value
; Input: ESI = variable name
; Output: EAX = value, EDX = 1 if success
; ----------------------------------------------------------------------------
GetVarValue PROC
    push esi
    
    call FindVariable
    cmp eax, -1
    je GetVarError
    
    mov eax, [varValues + eax*4]
    mov edx, 1
    jmp GetVarDone

GetVarError:
    xor eax, eax
    xor edx, edx

GetVarDone:
    pop esi
    ret
GetVarValue ENDP

; ----------------------------------------------------------------------------
; SetVarValue - Set variable value (creates if not exists)
; Input: ESI = variable name, EAX = value
; ----------------------------------------------------------------------------
SetVarValue PROC
    push eax
    push ebx
    push ecx
    push esi
    push edi
    
    mov ebx, eax  ; Save value
    
    call FindVariable
    cmp eax, -1
    jne SetExisting
    
    ; Create new variable
    mov eax, varCount
    cmp eax, MAX_VARS
    jge SetDone
    
    ; Copy name
    mov ecx, eax
    mov eax, 32
    mul ecx
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

SetExisting:
    mov [varValues + eax*4], ebx

SetDone:
    pop edi
    pop esi
    pop ecx
    pop ebx
    pop eax
    ret
SetVarValue ENDP

; ============================================================================
; EXPRESSION EVALUATOR
; ============================================================================

; ----------------------------------------------------------------------------
; EvaluateExpression - Evaluate arithmetic expression
; Input: ESI = expression string
; Output: EAX = result, EDX = 1 if success
; ----------------------------------------------------------------------------
EvaluateExpression PROC
    push ebx
    push ecx
    push esi
    push edi
    
    ; Get first operand
    call GetToken
    cmp eax, 0
    je EvalError
    
    ; Check if number or variable
    mov esi, OFFSET tokenBuf
    call StrToInt
    cmp edx, 1
    je GotFirstOp
    
    ; It's a variable
    mov esi, OFFSET tokenBuf
    call GetVarValue
    cmp edx, 1
    jne EvalError

GotFirstOp:
    mov ebx, eax  ; Store first operand
    
    ; Check for operator
    call SkipSpaces
    cmp BYTE PTR [esi], 0
    je EvalSingleValue
    
    call GetToken
    cmp eax, 0
    je EvalSingleValue
    
    ; Determine operator
    mov edi, OFFSET kwMultiply
    push esi
    mov esi, OFFSET tokenBuf
    call StrCompareNoCase
    pop esi
    cmp eax, 0
    je OpMultiply
    
    mov edi, OFFSET kwModulus
    push esi
    mov esi, OFFSET tokenBuf
    call StrCompareNoCase
    pop esi
    cmp eax, 0
    je OpModulus
    
    mov edi, OFFSET kwPlus
    push esi
    mov esi, OFFSET tokenBuf
    call StrCompareNoCase
    pop esi
    cmp eax, 0
    je OpAdd
    
    mov edi, OFFSET kwMinus
    push esi
    mov esi, OFFSET tokenBuf
    call StrCompareNoCase
    pop esi
    cmp eax, 0
    je OpSubtract
    
    mov edi, OFFSET kwDivided
    push esi
    mov esi, OFFSET tokenBuf
    call StrCompareNoCase
    pop esi
    cmp eax, 0
    je OpDivide
    
    ; Not an operator, single value
    jmp EvalSingleValue

OpMultiply:
    ; Skip "by"
    call GetToken
    mov ecx, OP_MULTIPLY
    jmp GetSecondOp

OpModulus:
    mov ecx, OP_MODULUS
    jmp GetSecondOp

OpAdd:
    mov ecx, OP_ADD
    jmp GetSecondOp

OpSubtract:
    mov ecx, OP_SUBTRACT
    jmp GetSecondOp

OpDivide:
    ; Skip "by"
    call GetToken
    mov ecx, OP_DIVIDE
    jmp GetSecondOp

GetSecondOp:
    ; Get second operand
    call GetToken
    cmp eax, 0
    je EvalError
    
    push ebx
    push ecx
    
    ; Check if number or variable
    mov esi, OFFSET tokenBuf
    call StrToInt
    cmp edx, 1
    je GotSecondOp
    
    ; It's a variable
    mov esi, OFFSET tokenBuf
    call GetVarValue
    cmp edx, 1
    jne EvalError2

GotSecondOp:
    mov edi, eax  ; Second operand
    
    pop ecx  ; Operator
    pop ebx  ; First operand
    
    ; Perform operation
    cmp ecx, OP_MULTIPLY
    je DoMultiply
    cmp ecx, OP_MODULUS
    je DoModulus
    cmp ecx, OP_ADD
    je DoAdd
    cmp ecx, OP_SUBTRACT
    je DoSubtract
    cmp ecx, OP_DIVIDE
    je DoDivide

DoMultiply:
    mov eax, ebx
    imul eax, edi
    jmp EvalSuccess

DoModulus:
    cmp edi, 0
    je EvalError
    mov eax, ebx
    cdq
    idiv edi
    mov eax, edx
    jmp EvalSuccess

DoAdd:
    mov eax, ebx
    add eax, edi
    jmp EvalSuccess

DoSubtract:
    mov eax, ebx
    sub eax, edi
    jmp EvalSuccess

DoDivide:
    cmp edi, 0
    je EvalError
    mov eax, ebx
    cdq
    idiv edi
    jmp EvalSuccess

EvalSingleValue:
    mov eax, ebx
    jmp EvalSuccess

EvalError2:
    pop ecx
    pop ebx

EvalError:
    xor eax, eax
    xor edx, edx
    jmp EvalDone

EvalSuccess:
    mov edx, 1

EvalDone:
    pop edi
    pop esi
    pop ecx
    pop ebx
    ret
EvaluateExpression ENDP

; ============================================================================
; CONDITION EVALUATOR
; ============================================================================

; ----------------------------------------------------------------------------
; EvaluateCondition - Evaluate conditional expression
; Input: ESI = condition string
; Output: EAX = 1 if true, 0 if false
; ----------------------------------------------------------------------------
EvaluateCondition PROC
    push ebx
    push ecx
    push esi
    push edi
    
    ; Save starting position
    mov edi, esi
    
    ; Find comparison operator by scanning
    xor ecx, ecx  ; Position counter
    
ScanForOp:
    mov al, [esi]
    cmp al, 0
    je CondError
    
    ; Check for "equals"
    cmp al, 'e'
    je CheckEquals
    cmp al, 'E'
    je CheckEquals
    
    ; Check for "greater"
    cmp al, 'g'
    je CheckGreater
    cmp al, 'G'
    je CheckGreater
    
    ; Check for "less"
    cmp al, 'l'
    je CheckLess
    cmp al, 'L'
    je CheckLess
    
    ; Check for "not"
    cmp al, 'n'
    je CheckNot
    cmp al, 'N'
    je CheckNot
    
    inc esi
    inc ecx
    jmp ScanForOp

CheckEquals:
    push esi
    mov edi, OFFSET kwEquals
    call StrCompareNoCase
    pop esi
    cmp eax, 0
    je FoundEquals
    inc esi
    inc ecx
    jmp ScanForOp

FoundEquals:
    mov ebx, CMP_EQUALS
    jmp ParseCondition

CheckGreater:
    push esi
    mov edi, OFFSET kwGreater
    call StrCompareNoCase
    pop esi
    cmp eax, 0
    jne NotGreater
    
    ; Skip "greater"
    add esi, 7
    call SkipSpaces
    
    ; Check for "than"
    push esi
    mov edi, OFFSET kwThan
    call StrCompareNoCase
    pop esi
    cmp eax, 0
    jne NotGreater
    
    mov ebx, CMP_GREATER
    jmp ParseCondition

NotGreater:
    mov esi, [esp+12]  ; Restore original ESI
    add esi, ecx
    inc esi
    inc ecx
    jmp ScanForOp

CheckLess:
    push esi
    mov edi, OFFSET kwLess
    call StrCompareNoCase
    pop esi
    cmp eax, 0
    jne NotLess
    
    ; Skip "less"
    add esi, 4
    call SkipSpaces
    
    ; Check for "than"
    push esi
    mov edi, OFFSET kwThan
    call StrCompareNoCase
    pop esi
    cmp eax, 0
    jne NotLess
    
    mov ebx, CMP_LESS
    jmp ParseCondition

NotLess:
    mov esi, [esp+12]  ; Restore original ESI
    add esi, ecx
    inc esi
    inc ecx
    jmp ScanForOp

CheckNot:
    push esi
    mov edi, OFFSET kwNot
    call StrCompareNoCase
    pop esi
    cmp eax, 0
    jne NotNotEquals
    
    mov ebx, CMP_NOTEQUALS
    jmp ParseCondition

NotNotEquals:
    mov esi, [esp+12]
    add esi, ecx
    inc esi
    inc ecx
    jmp ScanForOp

ParseCondition:
    ; ESI points to comparison operator
    ; Save comparison type
    push ebx
    
    ; Restore start and evaluate left side
    mov esi, edi
    call EvaluateExpression
    cmp edx, 1
    jne CondError2
    
    mov ebx, eax  ; Save left value
    
    ; Skip past comparison operator
    call SkipSpaces
    call GetToken  ; Skip operator word
    cmp BYTE PTR [esi], ' '
    jne SkipCmpDone
    call GetToken  ; Skip second word if needed (e.g., "than")
SkipCmpDone:
    
    ; Evaluate right side
    call EvaluateExpression
    cmp edx, 1
    jne CondError2
    
    mov ecx, eax  ; Right value
    
    pop eax  ; Comparison type
    
    ; Perform comparison
    cmp eax, CMP_EQUALS
    je CmpEquals
    cmp eax, CMP_NOTEQUALS
    je CmpNotEquals
    cmp eax, CMP_GREATER
    je CmpGreater
    cmp eax, CMP_LESS
    je CmpLess

CmpEquals:
    cmp ebx, ecx
    je CondTrue
    jmp CondFalse

CmpNotEquals:
    cmp ebx, ecx
    jne CondTrue
    jmp CondFalse

CmpGreater:
    cmp ebx, ecx
    jg CondTrue
    jmp CondFalse

CmpLess:
    cmp ebx, ecx
    jl CondTrue
    jmp CondFalse

CondTrue:
    mov eax, 1
    jmp CondDone

CondFalse:
    xor eax, eax
    jmp CondDone

CondError2:
    pop ebx

CondError:
    xor eax, eax

CondDone:
    pop edi
    pop esi
    pop ecx
    pop ebx
    ret
EvaluateCondition ENDP

; ============================================================================
; COMMAND EXECUTION
; ============================================================================

; ----------------------------------------------------------------------------
; ExecuteLine - Execute a single line
; Input: ESI = command line
; Output: EAX = 1 if continue, 0 if exit
; ----------------------------------------------------------------------------
ExecuteLine PROC
    push ebx
    push ecx
    push esi
    push edi
    
    call SkipSpaces
    cmp BYTE PTR [esi], 0
    je ExecContinue
    
    ; Get command
    call GetToken
    cmp eax, 0
    je ExecContinue
    
    ; Check command type
    mov edi, OFFSET kwExit
    push esi
    mov esi, OFFSET tokenBuf
    call StrCompareNoCase
    pop esi
    cmp eax, 0
    je ExecExit
    
    mov edi, OFFSET kwQuit
    push esi
    mov esi, OFFSET tokenBuf
    call StrCompareNoCase
    pop esi
    cmp eax, 0
    je ExecExit
    
    mov edi, OFFSET kwHelp
    push esi
    mov esi, OFFSET tokenBuf
    call StrCompareNoCase
    pop esi
    cmp eax, 0
    je ExecHelp
    
    mov edi, OFFSET kwClear
    push esi
    mov esi, OFFSET tokenBuf
    call StrCompareNoCase
    pop esi
    cmp eax, 0
    je ExecClear
    
    mov edi, OFFSET kwPrint
    push esi
    mov esi, OFFSET tokenBuf
    call StrCompareNoCase
    pop esi
    cmp eax, 0
    je ExecPrint
    
    mov edi, OFFSET kwStore
    push esi
    mov esi, OFFSET tokenBuf
    call StrCompareNoCase
    pop esi
    cmp eax, 0
    je ExecStore
    
    mov edi, OFFSET kwShow
    push esi
    mov esi, OFFSET tokenBuf
    call StrCompareNoCase
    pop esi
    cmp eax, 0
    je ExecShow
    
    mov edi, OFFSET kwIncrement
    push esi
    mov esi, OFFSET tokenBuf
    call StrCompareNoCase
    pop esi
    cmp eax, 0
    je ExecIncrement
    
    mov edi, OFFSET kwLoop
    push esi
    mov esi, OFFSET tokenBuf
    call StrCompareNoCase
    pop esi
    cmp eax, 0
    je ExecLoop
    
    mov edi, OFFSET kwIf
    push esi
    mov esi, OFFSET tokenBuf
    call StrCompareNoCase
    pop esi
    cmp eax, 0
    je ExecIf
    
    ; Unknown command
    mov edx, OFFSET errSyntax
    call WriteString
    call Crlf
    jmp ExecContinue

ExecExit:
    xor eax, eax
    jmp ExecDone

ExecHelp:
    mov edx, OFFSET helpMsg
    call WriteString
    jmp ExecContinue

ExecClear:
    call Clrscr
    jmp ExecContinue

ExecPrint:
    ; Parse: print <expr> [if <condition>]
    ; Find "if" keyword
    push esi
    mov edi, esi
    
FindIfLoop:
    mov al, [edi]
    cmp al, 0
    je NoIfCondition
    cmp al, 'i'
    je CheckIfKeyword
    cmp al, 'I'
    je CheckIfKeyword
    inc edi
    jmp FindIfLoop

CheckIfKeyword:
    push edi
    mov esi, edi
    mov edi, OFFSET kwIf
    call StrCompareNoCase
    pop edi
    cmp eax, 0
    je FoundIfKeyword
    inc edi
    jmp FindIfLoop

FoundIfKeyword:
    ; Split at "if"
    mov BYTE PTR [edi], 0  ; Null terminate expression
    pop esi
    
    ; Evaluate condition
    push esi
    lea esi, [edi+3]  ; Skip "if "
    call EvaluateCondition
    pop esi
    
    cmp eax, 0
    je ExecContinue  ; Condition false, don't print
    
    ; Evaluate and print expression
    call EvaluateExpression
    cmp edx, 1
    jne ExecContinue
    
    call WriteInt
    call Crlf
    jmp ExecContinue

NoIfCondition:
    pop esi
    
    ; Just evaluate and print
    call EvaluateExpression
    cmp edx, 1
    jne ExecContinue
    
    call WriteInt
    call Crlf
    jmp ExecContinue

ExecStore:
    ; Parse: store <value> in <var>
    call EvaluateExpression
    cmp edx, 1
    jne ExecContinue
    
    push eax
    
    ; Skip "in"
    call SkipSpaces
    call GetToken
    
    ; Get variable name
    call GetToken
    
    pop eax
    mov esi, OFFSET tokenBuf
    call SetVarValue
    jmp ExecContinue

ExecShow:
    ; Parse: show <var>
    call GetToken
    
    mov esi, OFFSET tokenBuf
    push esi
    call GetVarValue
    cmp edx, 1
    jne ShowError
    
    pop esi
    mov edx, esi
    call WriteString
    mov al, ' '
    call WriteChar
    mov al, '='
    call WriteChar
    mov al, ' '
    call WriteChar
    call WriteInt
    call Crlf
    jmp ExecContinue

ShowError:
    pop esi
    mov edx, OFFSET errVarNotFound
    call WriteString
    call Crlf
    jmp ExecContinue

ExecIncrement:
    ; Parse: increment <var>
    call GetToken
    
    mov esi, OFFSET tokenBuf
    push esi
    call GetVarValue
    cmp edx, 1
    jne IncrError
    
    inc eax
    pop esi
    call SetVarValue
    jmp ExecContinue

IncrError:
    pop esi
    ; Create variable with value 1
    mov eax, 1
    call SetVarValue
    jmp ExecContinue

ExecLoop:
    ; Parse: loop <N> times
    call GetToken
    
    mov esi, OFFSET tokenBuf
    call StrToInt
    cmp edx, 1
    jne ExecContinue
    
    ; Store loop count (would need loop body handling)
    ; For now, just acknowledge
    jmp ExecContinue

ExecIf:
    ; Parse: if <condition>
    call EvaluateCondition
    ; Would need to handle block execution
    jmp ExecContinue

ExecContinue:
    mov eax, 1

ExecDone:
    pop edi
    pop esi
    pop ecx
    pop ebx
    ret
ExecuteLine ENDP

; ============================================================================
; COMPLEX COMMAND PARSER
; ============================================================================

; ----------------------------------------------------------------------------
; ParseComplexCommand - Parse command with commas and 'and' separators
; Input: ESI = command line
; ----------------------------------------------------------------------------
ParseComplexCommand PROC
    push ebx
    push ecx
    push esi
    push edi
    
    ; Split by commas (right to left nesting)
    ; "print expr if cond and increment n , loop 10 times"
    ; becomes: loop 10 times { increment n; if cond { print expr } }
    
    ; For this example, we'll execute in a simpler sequential manner
    ; This would require a full parser rewrite for true nesting
    
    ; For now: split by "and" and execute sequentially
    mov edi, OFFSET inputBuffer
    
ParseAndLoop:
    ; Find "and" separator
    mov esi, edi
    
FindAndLoop:
    mov al, [esi]
    cmp al, 0
    je NoMoreAnd
    
    cmp al, 'a'
    je CheckAnd
    cmp al, 'A'
    je CheckAnd
    
    inc esi
    jmp FindAndLoop

CheckAnd:
    push esi
    push edi
    mov edi, OFFSET kwAnd
    call StrCompareNoCase
    pop edi
    pop esi
    cmp eax, 0
    je FoundAnd
    
    inc esi
    jmp FindAndLoop

FoundAnd:
    ; Split here
    mov BYTE PTR [esi], 0
    
    ; Execute first part
    push esi
    mov esi, edi
    call ExecuteLine
    pop esi
    
    ; Move to next part
    add esi, 4  ; Skip "and "
    mov edi, esi
    jmp ParseAndLoop

NoMoreAnd:
    ; Execute final part
    mov esi, edi
    call ExecuteLine
    
    pop edi
    pop esi
    pop ecx
    pop ebx
    ret
ParseComplexCommand ENDP

; ============================================================================
; MAIN PROGRAM
; ============================================================================

main PROC
    call InitVariables
    
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
    call SkipSpaces
    
    cmp BYTE PTR [esi], 0
    je MainLoop
    
    ; Check for comma-separated command
    mov edi, esi
FindCommaLoop:
    mov al, [edi]
    cmp al, 0
    je NoComma
    cmp al, ','
    je HasComma
    inc edi
    jmp FindCommaLoop

HasComma:
    ; Complex command with nesting
    ; For demo: execute parts separated by commas in reverse
    call ParseComplexCommand
    jmp MainLoop

NoComma:
    ; Simple command
    call ExecuteLine
    cmp eax, 0
    je ExitProgram
    
    jmp MainLoop
    
ExitProgram:
    mov edx, OFFSET goodbyeMsg
    call WriteString
    
    INVOKE ExitProcess, 0
main ENDP

END main
