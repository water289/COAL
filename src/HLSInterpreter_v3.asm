; ============================================================================
; HLSInterpreter_v3.asm - Advanced Human Language Scripting Interpreter
; Supports: expressions, nested control structures, comma/and separators
; x86 Assembly (MASM32) with Irvine32 Library
; ============================================================================

INCLUDE Irvine32.inc
INCLUDE Macros.inc

.data
    ; ========== DISPLAY MESSAGES ==========
    titleMsg    BYTE "================================================", 0dh, 0ah
                BYTE "  HUMAN LANGUAGE SCRIPTING INTERPRETER v3.0", 0dh, 0ah
                BYTE "  Advanced Expression & Control Flow Engine", 0dh, 0ah
                BYTE "================================================", 0dh, 0ah, 0
    
    welcomeMsg  BYTE "Syntax: 'print 5 multiply by n if 5 modulus n equals 0 ,and increment n , loop 10 times'", 0dh, 0ah
                BYTE "Type 'help' for commands or 'exit' to quit.", 0dh, 0ah, 0dh, 0ah, 0
    promptMsg   BYTE ">>> ", 0
    goodbyeMsg  BYTE 0dh, 0ah, "Goodbye!", 0dh, 0ah, 0
    
    helpMsg     BYTE "Commands:", 0dh, 0ah
                BYTE "  store <value> in <var>           - Store value", 0dh, 0ah
                BYTE "  print <expr>                     - Print expression", 0dh, 0ah
                BYTE "  print <expr> if <condition>      - Conditional print", 0dh, 0ah
                BYTE "  increment <var>                  - Increment variable", 0dh, 0ah
                BYTE "  show <var>                       - Display variable", 0dh, 0ah
                BYTE "  loop <N> times                   - Loop structure", 0dh, 0ah
                BYTE "  if <condition>                   - Conditional", 0dh, 0ah
                BYTE 0dh, 0ah
                BYTE "Operators: multiply by, modulus, plus, minus, divided by", 0dh, 0ah
                BYTE "Comparisons: equals, greater than, less than, not equals", 0dh, 0ah
                BYTE "Separators: 'and' = next statement, ',' = wrap left in block", 0dh, 0ah, 0
    
    ; ========== BUFFERS ==========
    inputBuffer BYTE 2048 DUP(?)
    bufferSize  DWORD 2048
    workBuf     BYTE 2048 DUP(?)
    tokenBuf    BYTE 256 DUP(?)
    exprBuf     BYTE 512 DUP(?)
    
    ; ========== VARIABLES (50 max) ==========
    MAX_VARS    EQU 50
    varNames    BYTE MAX_VARS * 32 DUP(0)
    varValues   SDWORD MAX_VARS DUP(0)
    varCount    DWORD 0
    
    ; ========== ERROR MESSAGES ==========
    errSyntax   BYTE "Error: Invalid syntax", 0
    errDivZero  BYTE "Error: Division by zero", 0
    errNotFound BYTE "Error: Variable not found: ", 0
    
    newline     BYTE 0dh, 0ah, 0

.code

; ============================================================================
; STRING UTILITIES
; ============================================================================

StrLen PROC
    push esi
    xor eax, eax
@@:
    cmp BYTE PTR [esi], 0
    je @F
    inc eax
    inc esi
    jmp @B
@@:
    pop esi
    ret
StrLen ENDP

StrCopy PROC USES esi edi
    ; ESI = source, EDI = dest
@@:
    lodsb
    stosb
    test al, al
    jnz @B
    ret
StrCopy ENDP

StrCmpNoCase PROC USES esi edi
    ; ESI = str1, EDI = str2, returns EAX = 0 if equal
@@:
    lodsb
    mov ah, [edi]
    inc edi
    
    cmp al, 'A'
    jb @F
    cmp al, 'Z'
    ja @F
    add al, 32
@@:
    cmp ah, 'A'
    jb @F
    cmp ah, 'Z'
    ja @F
    add ah, 32
@@:
    cmp al, ah
    jne @F
    test al, al
    jnz @B
    xor eax, eax
    ret
@@:
    mov eax, 1
    ret
StrCmpNoCase ENDP

SkipSpaces PROC
    ; ESI = string pointer
@@:
    mov al, [esi]
    cmp al, ' '
    je @F
    cmp al, 9
    jne SkipDone
@@:
    inc esi
    jmp @B
SkipDone:
    ret
SkipSpaces ENDP

StrToInt PROC
    ; ESI = string, returns EAX = value, EDX = 1 if valid
    push esi
    push ebx
    push ecx
    
    xor eax, eax
    xor ebx, ebx
    xor ecx, ecx
    
    mov dl, [esi]
    cmp dl, '-'
    jne @F
    mov ebx, 1
    inc esi
@@:
    mov dl, [esi]
    test dl, dl
    jz @F
    
    cmp dl, '0'
    jb InvalidNum
    cmp dl, '9'
    ja InvalidNum
    
    sub dl, '0'
    movzx edx, dl
    imul eax, 10
    add eax, edx
    inc ecx
    inc esi
    jmp @B
@@:
    test ecx, ecx
    jz InvalidNum
    
    test ebx, ebx
    jz @F
    neg eax
@@:
    mov edx, 1
    jmp @F
InvalidNum:
    xor eax, eax
    xor edx, edx
@@:
    pop ecx
    pop ebx
    pop esi
    ret
StrToInt ENDP

GetToken PROC
    ; ESI = source, EDI = dest (tokenBuf), returns EAX = 1 if success
    call SkipSpaces
    
    xor ecx, ecx
@@:
    mov al, [esi]
    test al, al
    jz @F
    cmp al, ' '
    je @F
    cmp al, ','
    je @F
    
    mov [edi], al
    inc esi
    inc edi
    inc ecx
    jmp @B
@@:
    mov BYTE PTR [edi], 0
    
    test ecx, ecx
    jz @F
    mov eax, 1
    ret
@@:
    xor eax, eax
    ret
GetToken ENDP

; ============================================================================
; VARIABLE MANAGEMENT
; ============================================================================

InitVars PROC
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
InitVars ENDP

FindVar PROC
    ; ESI = var name, returns EAX = index or -1
    push ebx
    push ecx
    push esi
    push edi
    
    xor ebx, ebx
    mov ecx, varCount
    test ecx, ecx
    jz NotFound
    
CheckLoop:
    push esi
    mov eax, ebx
    shl eax, 5
    lea edi, [varNames + eax]
    call StrCmpNoCase
    pop esi
    
    test eax, eax
    jz Found
    
    inc ebx
    loop CheckLoop
    
NotFound:
    mov eax, -1
    jmp Done
Found:
    mov eax, ebx
Done:
    pop edi
    pop esi
    pop ecx
    pop ebx
    ret
FindVar ENDP

GetVar PROC
    ; ESI = var name, returns EAX = value, EDX = 1 if exists
    call FindVar
    cmp eax, -1
    je @F
    mov eax, [varValues + eax*4]
    mov edx, 1
    ret
@@:
    xor eax, eax
    xor edx, edx
    ret
GetVar ENDP

SetVar PROC
    ; ESI = var name, EAX = value
    push eax
    push ebx
    push esi
    push edi
    
    mov ebx, eax
    call FindVar
    cmp eax, -1
    jne Exists
    
    ; Create new
    mov eax, varCount
    cmp eax, MAX_VARS
    jge Done
    
    shl eax, 5
    lea edi, [varNames + eax]
    call StrCopy
    
    mov eax, varCount
    inc varCount
    
Exists:
    mov [varValues + eax*4], ebx
    
Done:
    pop edi
    pop esi
    pop ebx
    pop eax
    ret
SetVar ENDP

; ============================================================================
; EXPRESSION EVALUATOR
; ============================================================================

EvalExpr PROC
    ; ESI = expression, returns EAX = result, EDX = 1 if success
    push ebx
    push ecx
    push esi
    push edi
    
    ; Get first operand
    mov edi, OFFSET tokenBuf
    call GetToken
    test eax, eax
    jz EvalError
    
    ; Check if number or variable
    mov esi, OFFSET tokenBuf
    call StrToInt
    cmp edx, 1
    je GotOp1
    
    mov esi, OFFSET tokenBuf
    call GetVar
    cmp edx, 1
    jne EvalError
    
GotOp1:
    mov ebx, eax
    
    ; Check for operator
    call SkipSpaces
    cmp BYTE PTR [esi], 0
    je SingleVal
    
    mov edi, OFFSET tokenBuf
    call GetToken
    test eax, eax
    jz SingleVal
    
    ; Determine operator
    push esi
    mov esi, OFFSET tokenBuf
    
    ; Check "multiply"
    mov edi, OFFSET kwMultiply
    call StrCmpNoCase
    test eax, eax
    jz OpMul
    
    ; Check "modulus"
    mov esi, OFFSET tokenBuf
    mov edi, OFFSET kwModulus
    call StrCmpNoCase
    test eax, eax
    jz OpMod
    
    ; Check "plus"
    mov esi, OFFSET tokenBuf
    mov edi, OFFSET kwPlus
    call StrCmpNoCase
    test eax, eax
    jz OpAdd
    
    ; Check "minus"
    mov esi, OFFSET tokenBuf
    mov edi, OFFSET kwMinus
    call StrCmpNoCase
    test eax, eax
    jz OpSub
    
    ; Check "divided"
    mov esi, OFFSET tokenBuf
    mov edi, OFFSET kwDivided
    call StrCmpNoCase
    test eax, eax
    jz OpDiv
    
    pop esi
    jmp SingleVal
    
OpMul:
    pop esi
    mov edi, OFFSET tokenBuf
    call GetToken  ; Skip "by"
    mov ecx, 3
    jmp GetOp2
    
OpMod:
    pop esi
    mov ecx, 5
    jmp GetOp2
    
OpAdd:
    pop esi
    mov ecx, 1
    jmp GetOp2
    
OpSub:
    pop esi
    mov ecx, 2
    jmp GetOp2
    
OpDiv:
    pop esi
    mov edi, OFFSET tokenBuf
    call GetToken  ; Skip "by"
    mov ecx, 4
    jmp GetOp2
    
GetOp2:
    mov edi, OFFSET tokenBuf
    call GetToken
    test eax, eax
    jz EvalError
    
    push ebx
    push ecx
    
    mov esi, OFFSET tokenBuf
    call StrToInt
    cmp edx, 1
    je GotOp2
    
    mov esi, OFFSET tokenBuf
    call GetVar
    cmp edx, 1
    jne EvalErr2
    
GotOp2:
    mov edi, eax
    pop ecx
    pop ebx
    
    ; Perform operation
    cmp ecx, 1
    je DoAdd
    cmp ecx, 2
    je DoSub
    cmp ecx, 3
    je DoMul
    cmp ecx, 4
    je DoDiv
    cmp ecx, 5
    je DoMod
    
DoAdd:
    mov eax, ebx
    add eax, edi
    jmp EvalOK
    
DoSub:
    mov eax, ebx
    sub eax, edi
    jmp EvalOK
    
DoMul:
    mov eax, ebx
    imul eax, edi
    jmp EvalOK
    
DoDiv:
    test edi, edi
    jz EvalError
    mov eax, ebx
    cdq
    idiv edi
    jmp EvalOK
    
DoMod:
    test edi, edi
    jz EvalError
    mov eax, ebx
    cdq
    idiv edi
    mov eax, edx
    jmp EvalOK
    
SingleVal:
    mov eax, ebx
    
EvalOK:
    mov edx, 1
    jmp EvalDone
    
EvalErr2:
    pop ecx
    pop ebx
    
EvalError:
    xor eax, eax
    xor edx, edx
    
EvalDone:
    pop edi
    pop esi
    pop ecx
    pop ebx
    ret
    
kwMultiply BYTE "multiply", 0
kwModulus  BYTE "modulus", 0
kwPlus     BYTE "plus", 0
kwMinus    BYTE "minus", 0
kwDivided  BYTE "divided", 0
    
EvalExpr ENDP

; ============================================================================
; CONDITION EVALUATOR
; ============================================================================

EvalCond PROC
    ; ESI = condition string, returns EAX = 1 if true, 0 if false
    push ebx
    push ecx
    push esi
    push edi
    
    ; Save start
    push esi
    
    ; Find comparison operator
    xor ecx, ecx
ScanLoop:
    mov al, [esi]
    test al, al
    jz CondErr
    
    ; Look for "equals", "greater", "less", "not"
    cmp al, 'e'
    je ChkEq
    cmp al, 'E'
    je ChkEq
    cmp al, 'g'
    je ChkGt
    cmp al, 'G'
    je ChkGt
    cmp al, 'l'
    je ChkLt
    cmp al, 'L'
    je ChkLt
    cmp al, 'n'
    je ChkNe
    cmp al, 'N'
    je ChkNe
    
    inc esi
    inc ecx
    jmp ScanLoop
    
ChkEq:
    push esi
    mov edi, OFFSET kwEquals
    call StrCmpNoCase
    pop esi
    test eax, eax
    jz FoundEq
    inc esi
    inc ecx
    jmp ScanLoop
    
FoundEq:
    mov ebx, 1
    jmp ParseCond
    
ChkGt:
    push esi
    mov edi, OFFSET kwGreater
    call StrCmpNoCase
    pop esi
    test eax, eax
    jnz NotGt
    mov ebx, 3
    jmp ParseCond
NotGt:
    inc esi
    inc ecx
    jmp ScanLoop
    
ChkLt:
    push esi
    mov edi, OFFSET kwLess
    call StrCmpNoCase
    pop esi
    test eax, eax
    jnz NotLt
    mov ebx, 4
    jmp ParseCond
NotLt:
    inc esi
    inc ecx
    jmp ScanLoop
    
ChkNe:
    push esi
    mov edi, OFFSET kwNot
    call StrCmpNoCase
    pop esi
    test eax, eax
    jnz NotNe
    mov ebx, 2
    jmp ParseCond
NotNe:
    inc esi
    inc ecx
    jmp ScanLoop
    
ParseCond:
    ; ESI = comparison operator position
    ; EBX = comparison type
    push ebx
    
    ; Get left expression
    pop edi
    push edi
    push esi
    
    mov esi, edi
    call EvalExpr
    pop esi
    cmp edx, 1
    jne CondErr2
    
    push eax  ; Save left value
    
    ; Skip comparison operator
    call SkipSpaces
    mov edi, OFFSET tokenBuf
    call GetToken
    
    ; Check if need to skip second word
    mov edi, OFFSET kwThan
    push esi
    mov esi, OFFSET tokenBuf
    call StrCmpNoCase
    pop esi
    test eax, eax
    jz @F
    
    ; Skip "than" if present
    call SkipSpaces
    cmp BYTE PTR [esi], 't'
    jne @F
    mov edi, OFFSET tokenBuf
    call GetToken
@@:
    
    ; Get right expression
    call EvalExpr
    cmp edx, 1
    jne CondErr3
    
    mov ecx, eax
    pop ebx  ; Left value
    pop eax  ; Comparison type
    
    ; Do comparison
    cmp eax, 1
    je CmpEq
    cmp eax, 2
    je CmpNe
    cmp eax, 3
    je CmpGt
    cmp eax, 4
    je CmpLt
    
CmpEq:
    cmp ebx, ecx
    je CondTrue
    jmp CondFalse
    
CmpNe:
    cmp ebx, ecx
    jne CondTrue
    jmp CondFalse
    
CmpGt:
    cmp ebx, ecx
    jg CondTrue
    jmp CondFalse
    
CmpLt:
    cmp ebx, ecx
    jl CondTrue
    jmp CondFalse
    
CondTrue:
    mov eax, 1
    jmp CondDone
    
CondFalse:
    xor eax, eax
    jmp CondDone
    
CondErr3:
    pop ebx
CondErr2:
    pop ebx
CondErr:
    pop esi
    xor eax, eax
    jmp CondDone
    
CondDone:
    pop edi
    pop esi
    pop ecx
    pop ebx
    ret
    
kwEquals  BYTE "equals", 0
kwGreater BYTE "greater", 0
kwLess    BYTE "less", 0
kwNot     BYTE "not", 0
kwThan    BYTE "than", 0
    
EvalCond ENDP

; ============================================================================
; COMMAND EXECUTION
; ============================================================================

ExecCmd PROC
    ; ESI = command line
    push ebx
    push ecx
    push esi
    push edi
    
    call SkipSpaces
    cmp BYTE PTR [esi], 0
    je ExecOK
    
    ; Get command keyword
    mov edi, OFFSET tokenBuf
    call GetToken
    test eax, eax
    jz ExecOK
    
    ; Check command type
    push esi
    mov esi, OFFSET tokenBuf
    
    mov edi, OFFSET kwExit
    call StrCmpNoCase
    test eax, eax
    jz CmdExit
    
    mov esi, OFFSET tokenBuf
    mov edi, OFFSET kwQuit
    call StrCmpNoCase
    test eax, eax
    jz CmdExit
    
    mov esi, OFFSET tokenBuf
    mov edi, OFFSET kwHelp
    call StrCmpNoCase
    test eax, eax
    jz CmdHelp
    
    mov esi, OFFSET tokenBuf
    mov edi, OFFSET kwClear
    call StrCmpNoCase
    test eax, eax
    jz CmdClear
    
    mov esi, OFFSET tokenBuf
    mov edi, OFFSET kwPrint
    call StrCmpNoCase
    test eax, eax
    jz CmdPrint
    
    mov esi, OFFSET tokenBuf
    mov edi, OFFSET kwStore
    call StrCmpNoCase
    test eax, eax
    jz CmdStore
    
    mov esi, OFFSET tokenBuf
    mov edi, OFFSET kwShow
    call StrCmpNoCase
    test eax, eax
    jz CmdShow
    
    mov esi, OFFSET tokenBuf
    mov edi, OFFSET kwIncr
    call StrCmpNoCase
    test eax, eax
    jz CmdIncr
    
    mov esi, OFFSET tokenBuf
    mov edi, OFFSET kwLoop
    call StrCmpNoCase
    test eax, eax
    jz CmdLoop
    
    pop esi
    mov edx, OFFSET errSyntax
    call WriteString
    call Crlf
    jmp ExecOK
    
CmdExit:
    pop esi
    xor eax, eax
    jmp ExecRet
    
CmdHelp:
    pop esi
    mov edx, OFFSET helpMsg
    call WriteString
    jmp ExecOK
    
CmdClear:
    pop esi
    call Clrscr
    jmp ExecOK
    
CmdPrint:
    pop esi
    
    ; Find "if" keyword
    push esi
    mov edi, esi
FindIfLp:
    mov al, [edi]
    test al, al
    je NoIf
    cmp al, 'i'
    je ChkIf
    cmp al, 'I'
    je ChkIf
    inc edi
    jmp FindIfLp
    
ChkIf:
    push edi
    push esi
    mov esi, edi
    mov edi, OFFSET kwIf
    call StrCmpNoCase
    pop esi
    pop edi
    test eax, eax
    jz HasIf
    inc edi
    jmp FindIfLp
    
HasIf:
    ; Split at "if"
    mov BYTE PTR [edi], 0
    pop esi
    
    ; Evaluate condition
    push esi
    lea esi, [edi+3]
    call EvalCond
    pop esi
    
    test eax, eax
    jz ExecOK
    
    ; Evaluate and print
    call EvalExpr
    cmp edx, 1
    jne ExecOK
    
    call WriteInt
    call Crlf
    jmp ExecOK
    
NoIf:
    pop esi
    call EvalExpr
    cmp edx, 1
    jne ExecOK
    
    call WriteInt
    call Crlf
    jmp ExecOK
    
CmdStore:
    pop esi
    call EvalExpr
    cmp edx, 1
    jne ExecOK
    
    push eax
    call SkipSpaces
    mov edi, OFFSET tokenBuf
    call GetToken  ; Skip "in" or "equals"
    
    mov edi, OFFSET tokenBuf
    call GetToken  ; Get var name
    
    pop eax
    mov esi, OFFSET tokenBuf
    call SetVar
    jmp ExecOK
    
CmdShow:
    pop esi
    mov edi, OFFSET tokenBuf
    call GetToken
    
    mov esi, OFFSET tokenBuf
    push esi
    call GetVar
    cmp edx, 1
    jne ShowErr
    
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
    jmp ExecOK
    
ShowErr:
    pop esi
    mov edx, OFFSET errNotFound
    call WriteString
    mov edx, esi
    call WriteString
    call Crlf
    jmp ExecOK
    
CmdIncr:
    pop esi
    mov edi, OFFSET tokenBuf
    call GetToken
    
    mov esi, OFFSET tokenBuf
    push esi
    call GetVar
    cmp edx, 1
    je @F
    xor eax, eax
@@:
    inc eax
    pop esi
    call SetVar
    jmp ExecOK
    
CmdLoop:
    pop esi
    ; Just parse for now - real implementation needs recursion
    jmp ExecOK
    
ExecOK:
    mov eax, 1
ExecRet:
    pop edi
    pop esi
    pop ecx
    pop ebx
    ret
    
kwExit  BYTE "exit", 0
kwQuit  BYTE "quit", 0
kwHelp  BYTE "help", 0
kwClear BYTE "clear", 0
kwPrint BYTE "print", 0
kwStore BYTE "store", 0
kwShow  BYTE "show", 0
kwIncr  BYTE "increment", 0
kwLoop  BYTE "loop", 0
kwIf    BYTE "if", 0
    
ExecCmd ENDP

; ============================================================================
; NESTED STRUCTURE EXECUTOR
; ============================================================================

ExecNested PROC
    ; ESI = full command with possible nesting
    ; Strategy: find rightmost comma, that's the outermost structure
    
    push ebx
    push ecx
    push esi
    push edi
    sub esp, 12  ; loopCnt, bodyStart, ifCond
    
    ; Find rightmost comma
    mov edi, esi
    call StrLen
    add edi, eax
    mov ecx, eax
    xor ebx, ebx  ; Rightmost comma pos
    
FindComma:
    test ecx, ecx
    jz NoComma
    dec edi
    dec ecx
    
    cmp BYTE PTR [edi], ','
    jne FindComma
    
    ; Found comma at EDI
    mov ebx, edi
    
    ; Split: left part goes into structure defined by right part
    mov BYTE PTR [edi], 0
    inc edi
    call SkipSpaces
    
    ; Check if right part is "loop N times"
    push edi
    push esi
    
    mov esi, edi
    mov edi, OFFSET tokenBuf
    call GetToken
    
    mov esi, OFFSET tokenBuf
    mov edi, OFFSET kwLoop
    call StrCmpNoCase
    
    pop esi
    pop edi
    
    test eax, eax
    jz IsLoop
    
    ; Check if it's "if condition"
    push edi
    push esi
    
    mov esi, edi
    mov edi, OFFSET tokenBuf
    call GetToken
    
    mov esi, OFFSET tokenBuf
    mov edi, OFFSET kwIf
    call StrCmpNoCase
    
    pop esi
    pop edi
    
    test eax, eax
    jz IsIf
    
    ; Unknown structure, just execute left part
    mov esi, [esp+12]
    call ExecNested
    jmp NestDone
    
IsLoop:
    ; Parse "loop N times"
    push esi
    mov esi, edi
    mov edi, OFFSET tokenBuf
    call GetToken  ; Skip "loop"
    
    mov edi, OFFSET tokenBuf
    call GetToken  ; Get N
    
    mov esi, OFFSET tokenBuf
    call StrToInt
    pop esi
    
    cmp edx, 1
    jne NestDone
    
    mov [esp], eax  ; loopCnt
    
LoopBody:
    cmp DWORD PTR [esp], 0
    jle NestDone
    
    ; Execute left part (body)
    push esi
    call ExecNested
    pop esi
    
    dec DWORD PTR [esp]  ; loopCnt
    jmp LoopBody
    
IsIf:
    ; Parse "if condition"
    push esi
    mov esi, edi
    mov edi, OFFSET tokenBuf
    call GetToken  ; Skip "if"
    
    ; Evaluate condition
    call EvalCond
    pop esi
    
    test eax, eax
    jz NestDone
    
    ; Execute left part (body)
    call ExecNested
    jmp NestDone
    
NoComma:
    ; No comma, check for "and" separator
    mov esi, [esp+12]
    push esi
    
FindAnd:
    mov al, [esi]
    test al, al
    jz NoAnd
    
    cmp al, 'a'
    je ChkAnd
    cmp al, 'A'
    je ChkAnd
    
    inc esi
    jmp FindAnd
    
ChkAnd:
    push esi
    mov edi, OFFSET kwAnd
    call StrCmpNoCase
    pop esi
    test eax, eax
    jz FoundAnd
    inc esi
    jmp FindAnd
    
FoundAnd:
    ; Split at "and"
    mov BYTE PTR [esi], 0
    pop edi  ; First part
    
    ; Execute first part
    push esi
    mov esi, edi
    call ExecCmd
    pop esi
    
    ; Execute second part
    add esi, 4  ; Skip "and "
    call ExecNested
    jmp NestDone
    
NoAnd:
    ; Simple command
    pop esi
    call ExecCmd
    
NestDone:
    add esp, 12  ; Clean up local variables
    pop edi
    pop esi
    pop ecx
    pop ebx
    ret
    
kwAnd BYTE "and", 0
    
ExecNested ENDP

; ============================================================================
; MAIN PROGRAM
; ============================================================================

main PROC
    call InitVars
    
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
    
    test eax, eax
    jz MainLoop
    
    mov esi, OFFSET inputBuffer
    call SkipSpaces
    
    cmp BYTE PTR [esi], 0
    je MainLoop
    
    ; Copy to work buffer
    mov edi, OFFSET workBuf
    call StrCopy
    
    ; Execute
    mov esi, OFFSET workBuf
    call ExecNested
    
    test eax, eax
    jz ExitProg
    
    jmp MainLoop
    
ExitProg:
    mov edx, OFFSET goodbyeMsg
    call WriteString
    
    INVOKE ExitProcess, 0
main ENDP

END main
