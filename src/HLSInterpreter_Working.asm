; ============================================================================
; HLSInterpreter_Working.asm - Functional Human Language Scripting Interpreter
; Handles: print 5 multiply by n if 5 modulus n equals 0 and increment n , loop 10 times
; x86 Assembly (MASM32) with Irvine32 Library
; ============================================================================

INCLUDE Irvine32.inc

.data
    titleMsg    BYTE "================================================", 0dh, 0ah
                BYTE "  HUMAN LANGUAGE SCRIPTING INTERPRETER v3.1", 0dh, 0ah
                BYTE "  Working Version - Nested Control Flow", 0dh, 0ah
                BYTE "================================================", 0dh, 0ah, 0
    
    welcomeMsg  BYTE "Example: print 5 multiply by n if 5 modulus n equals 0 and increment n , loop 10 times", 0dh, 0ah
                BYTE "Type 'help' or 'exit'", 0dh, 0ah, 0dh, 0ah, 0
    promptMsg   BYTE ">>> ", 0
    goodbyeMsg  BYTE 0dh, 0ah, "Goodbye!", 0dh, 0ah, 0
    
    helpMsg     BYTE "Commands:", 0dh, 0ah
                BYTE "  store <value> in <var>", 0dh, 0ah
                BYTE "  print <expr>", 0dh, 0ah
                BYTE "  print <expr> if <condition>", 0dh, 0ah
                BYTE "  increment <var>", 0dh, 0ah
                BYTE "  show <var>", 0dh, 0ah
                BYTE "  loop <N> times", 0dh, 0ah
                BYTE "Operators: multiply by, modulus, plus, minus, divided by", 0dh, 0ah
                BYTE "Separators: 'and' = next line, ',' = nest left in right", 0dh, 0ah, 0
    
    inputBuffer BYTE 2048 DUP(?)
    workBuf     BYTE 2048 DUP(?)
    tokenBuf    BYTE 256 DUP(?)
    
    ; Variables
    MAX_VARS    EQU 50
    varNames    BYTE MAX_VARS * 32 DUP(0)
    varValues   SDWORD MAX_VARS DUP(0)
    varCount    DWORD 0
    
    errMsg      BYTE "Error", 0dh, 0ah, 0
    debugMsg    BYTE "DEBUG: ", 0
    newline     BYTE 0dh, 0ah, 0

.code

; ============================================================================
; Utilities
; ============================================================================

SkipSpaces PROC
@@: mov al, [esi]
    cmp al, ' '
    jne @F
    inc esi
    jmp @B
@@: ret
SkipSpaces ENDP

StrCmpI PROC
    ; ESI=str1, EDI=str2, ret EAX=0 if equal
@@: lodsb
    mov ah, [edi]
    inc edi
    
    ; Convert AL to lowercase
    cmp al, 'A'
    jb @F
    cmp al, 'Z'
    ja @F
    or al, 20h
@@:
    ; Convert AH to lowercase
    cmp ah, 'A'
    jb @F
    cmp ah, 'Z'
    ja @F
    or ah, 20h
@@:
    cmp al, ah
    jne @F
    test al, al
    jnz @B
    xor eax, eax
    ret
@@: mov eax, 1
    ret
StrCmpI ENDP

StrCopy PROC
    ; ESI=src, EDI=dest
@@: lodsb
    stosb
    test al, al
    jnz @B
    ret
StrCopy ENDP

GetToken PROC
    ; ESI=input, EDI=output, ret EAX=1 if success, ESI moves
    call SkipSpaces
    xor ecx, ecx
@@: mov al, [esi]
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
@@: mov BYTE PTR [edi], 0
    mov eax, ecx
    ret
GetToken ENDP

StrToInt PROC
    ; ESI=string, ret EAX=value, EDX=success
    push esi
    push ebx
    xor eax, eax
    xor ebx, ebx
    mov cl, [esi]
    cmp cl, '-'
    jne @F
    inc ebx
    inc esi
@@: mov cl, [esi]
    test cl, cl
    jz @F
    cmp cl, '0'
    jb IntErr
    cmp cl, '9'
    ja IntErr
    sub cl, '0'
    imul eax, 10
    movzx edx, cl
    add eax, edx
    inc esi
    jmp @B
@@: test ebx, ebx
    jz @F
    neg eax
@@: mov edx, 1
    pop ebx
    pop esi
    ret
IntErr:
    xor eax, eax
    xor edx, edx
    pop ebx
    pop esi
    ret
StrToInt ENDP

TrimString PROC
    ; ESI=string, trims leading and trailing whitespace in place
    push eax
    push edi
    push esi
    
    ; Trim leading spaces
    mov edi, esi
TrimLeadLoop:
    mov al, [esi]
    test al, al
    jz TrimDone
    cmp al, ' '
    je @F
    cmp al, 9
    jne TrimLeadDone
@@: inc esi
    jmp TrimLeadLoop
    
TrimLeadDone:
    ; Copy to start if needed
    cmp esi, edi
    je TrimTrail
    
CopyLoop:
    mov al, [esi]
    mov [edi], al
    test al, al
    jz TrimTrail
    inc esi
    inc edi
    jmp CopyLoop
    
TrimTrail:
    ; Trim trailing spaces
    mov esi, [esp]
    xor ecx, ecx
FindEnd:
    mov al, [esi]
    test al, al
    jz FoundEnd
    inc esi
    inc ecx
    jmp FindEnd
    
FoundEnd:
    test ecx, ecx
    jz TrimDone
    dec esi
    
TrimTrailLoop:
    mov al, [esi]
    cmp al, ' '
    je @F
    cmp al, 9
    jne TrimDone
@@: mov BYTE PTR [esi], 0
    dec esi
    dec ecx
    test ecx, ecx
    jnz TrimTrailLoop
    
TrimDone:
    pop esi
    pop edi
    pop eax
    ret
TrimString ENDP

IsEmptyString PROC
    ; ESI=string, returns EAX=1 if empty/whitespace only, 0 otherwise
    push esi
@@: mov al, [esi]
    test al, al
    jz IsEmpty
    cmp al, ' '
    je @F
    cmp al, 9
    jne NotEmpty
@@: inc esi
    jmp @B
    
IsEmpty:
    mov eax, 1
    jmp EmptyDone
    
NotEmpty:
    xor eax, eax
    
EmptyDone:
    pop esi
    ret
IsEmptyString ENDP

; ============================================================================
; Variables
; ============================================================================

InitVars PROC
    mov varCount, 0
    ret
InitVars ENDP

FindVar PROC
    ; ESI=name, ret EAX=index or -1
    push ebx
    push ecx
    push esi
    push edi
    
    xor ebx, ebx
    mov ecx, varCount
    test ecx, ecx
    jz @F
VarLoop:
    push esi
    mov eax, ebx
    shl eax, 5
    lea edi, varNames[eax]
    call StrCmpI
    pop esi
    test eax, eax
    jz VarFound
    inc ebx
    loop VarLoop
@@: mov eax, -1
    jmp VarDone
VarFound:
    mov eax, ebx
VarDone:
    pop edi
    pop esi
    pop ecx
    pop ebx
    ret
FindVar ENDP

GetVar PROC
    ; ESI=name, ret EAX=value, EDX=success
    call FindVar
    cmp eax, -1
    je @F
    mov eax, varValues[eax*4]
    mov edx, 1
    ret
@@: xor eax, eax
    xor edx, edx
    ret
GetVar ENDP

SetVar PROC
    ; ESI=name, EAX=value
    push eax
    push ebx
    push esi
    push edi
    
    mov ebx, eax
    call FindVar
    cmp eax, -1
    jne VarExists
    
    mov eax, varCount
    cmp eax, MAX_VARS
    jge VarDone2
    
    shl eax, 5
    lea edi, varNames[eax]
    call StrCopy
    
    mov eax, varCount
    inc varCount
    
VarExists:
    mov varValues[eax*4], ebx
    
VarDone2:
    pop edi
    pop esi
    pop ebx
    pop eax
    ret
SetVar ENDP

; ============================================================================
; Expression Evaluator
; ============================================================================

EvalExpr PROC
    ; ESI=expression, ret EAX=result, EDX=success
    push ebx
    push ecx
    push edi
    
    ; Get first operand
    mov edi, OFFSET tokenBuf
    call GetToken
    test eax, eax
    jz ExprErr
    
    push esi
    mov esi, OFFSET tokenBuf
    call StrToInt
    cmp edx, 1
    je GotFirst
    
    call GetVar
    cmp edx, 1
    jne ExprErr2
    
GotFirst:
    mov ebx, eax
    pop esi
    
    ; Check for operator
    call SkipSpaces
    cmp BYTE PTR [esi], 0
    je ExprSingle
    
    ; Save position
    push esi
    mov edi, OFFSET tokenBuf
    call GetToken
    
    ; Check operator type
    push esi
    mov esi, OFFSET tokenBuf
    mov edi, OFFSET opMul
    call StrCmpI
    test eax, eax
    jz IsOpMul
    
    mov esi, OFFSET tokenBuf
    mov edi, OFFSET opMod
    call StrCmpI
    test eax, eax
    jz IsOpMod
    
    mov esi, OFFSET tokenBuf
    mov edi, OFFSET opPlus
    call StrCmpI
    test eax, eax
    jz IsOpAdd
    
    mov esi, OFFSET tokenBuf
    mov edi, OFFSET opMinus
    call StrCmpI
    test eax, eax
    jz IsOpSub
    
    mov esi, OFFSET tokenBuf
    mov edi, OFFSET opDiv
    call StrCmpI
    test eax, eax
    jz IsOpDiv
    
    pop esi
    pop esi
    jmp ExprSingle
    
IsOpMul:
    pop esi
    pop edi
    mov edi, OFFSET tokenBuf
    call GetToken
    mov ecx, 1
    jmp GetSecond
    
IsOpMod:
    pop esi
    pop edi
    mov ecx, 2
    jmp GetSecond
    
IsOpAdd:
    pop esi
    pop edi
    mov ecx, 3
    jmp GetSecond
    
IsOpSub:
    pop esi
    pop edi
    mov ecx, 4
    jmp GetSecond
    
IsOpDiv:
    pop esi
    pop edi
    mov edi, OFFSET tokenBuf
    call GetToken
    mov ecx, 5
    jmp GetSecond
    
GetSecond:
    mov edi, OFFSET tokenBuf
    call GetToken
    test eax, eax
    jz ExprErr
    
    push ebx
    push ecx
    
    push esi
    mov esi, OFFSET tokenBuf
    call StrToInt
    cmp edx, 1
    je GotSecond
    
    call GetVar
    cmp edx, 1
    jne ExprErr3
    
GotSecond:
    mov edi, eax
    pop esi
    pop ecx
    pop ebx
    
    cmp ecx, 1
    je DoMul
    cmp ecx, 2
    je DoMod
    cmp ecx, 3
    je DoAdd
    cmp ecx, 4
    je DoSub
    cmp ecx, 5
    je DoDiv
    
DoMul:
    mov eax, ebx
    imul eax, edi
    jmp ExprOK
    
DoMod:
    test edi, edi
    jz ExprErr
    mov eax, ebx
    cdq
    idiv edi
    mov eax, edx
    jmp ExprOK
    
DoAdd:
    mov eax, ebx
    add eax, edi
    jmp ExprOK
    
DoSub:
    mov eax, ebx
    sub eax, edi
    jmp ExprOK
    
DoDiv:
    test edi, edi
    jz ExprErr
    mov eax, ebx
    cdq
    idiv edi
    jmp ExprOK
    
ExprSingle:
    mov eax, ebx
    
ExprOK:
    mov edx, 1
    jmp ExprDone
    
ExprErr3:
    pop esi
    pop ecx
    pop ebx
    jmp ExprErr
    
ExprErr2:
    pop esi
    
ExprErr:
    xor eax, eax
    xor edx, edx
    
ExprDone:
    pop edi
    pop ecx
    pop ebx
    ret
    
opMul   BYTE "multiply", 0
opMod   BYTE "modulus", 0
opPlus  BYTE "plus", 0
opMinus BYTE "minus", 0
opDiv   BYTE "divided", 0
    
EvalExpr ENDP

; ============================================================================
; Condition Evaluator
; ============================================================================

EvalCond PROC
    ; ESI=condition, ret EAX=1 if true, 0 if false
    push ebx
    push ecx
    push edi
    
    ; Find comparison operator
    push esi
    
FindCmp:
    mov al, [esi]
    test al, al
    jz CondErr
    
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
    
    inc esi
    jmp FindCmp
    
ChkEq:
    push esi
    mov edi, OFFSET cmpEq
    call StrCmpI
    pop esi
    test eax, eax
    jz FoundEq
    inc esi
    jmp FindCmp
    
FoundEq:
    mov ebx, 1
    jmp ParseCond
    
ChkGt:
    push esi
    mov edi, OFFSET cmpGt
    call StrCmpI
    pop esi
    test eax, eax
    jnz NotGt
    mov ebx, 2
    jmp ParseCond
NotGt:
    inc esi
    jmp FindCmp
    
ChkLt:
    push esi
    mov edi, OFFSET cmpLt
    call StrCmpI
    pop esi
    test eax, eax
    jnz NotLt
    mov ebx, 3
    jmp ParseCond
NotLt:
    inc esi
    jmp FindCmp
    
ParseCond:
    push ebx
    pop edi
    push edi
    
    ; Get left value
    call EvalExpr
    cmp edx, 1
    jne CondErr2
    
    push eax
    
    ; Skip comparison word(s)
    call SkipSpaces
    mov edi, OFFSET tokenBuf
    call GetToken
    
    call SkipSpaces
    cmp BYTE PTR [esi], 't'
    jne @F
    mov edi, OFFSET tokenBuf
    call GetToken
@@:
    
    ; Get right value
    call EvalExpr
    cmp edx, 1
    jne CondErr3
    
    mov ecx, eax
    pop ebx
    pop eax
    
    cmp eax, 1
    je CmpEq
    cmp eax, 2
    je CmpGt
    cmp eax, 3
    je CmpLt
    
CmpEq:
    cmp ebx, ecx
    je CondTrue
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
    
CondDone:
    pop edi
    pop ecx
    pop ebx
    ret
    
cmpEq BYTE "equals", 0
cmpGt BYTE "greater", 0
cmpLt BYTE "less", 0
    
EvalCond ENDP

; ============================================================================
; Command Executor
; ============================================================================

ExecSimple PROC
    ; ESI=command
    push ebx
    push ecx
    push edi
    
    call SkipSpaces
    cmp BYTE PTR [esi], 0
    je ExecOK
    
    ; Get command
    mov edi, OFFSET tokenBuf
    call GetToken
    test eax, eax
    jz ExecOK
    
    push esi
    mov esi, OFFSET tokenBuf
    
    mov edi, OFFSET cmdExit
    call StrCmpI
    test eax, eax
    jz IsExit
    
    mov esi, OFFSET tokenBuf
    mov edi, OFFSET cmdHelp
    call StrCmpI
    test eax, eax
    jz IsHelp
    
    mov esi, OFFSET tokenBuf
    mov edi, OFFSET cmdClear
    call StrCmpI
    test eax, eax
    jz IsClear
    
    mov esi, OFFSET tokenBuf
    mov edi, OFFSET cmdPrint
    call StrCmpI
    test eax, eax
    jz IsPrint
    
    mov esi, OFFSET tokenBuf
    mov edi, OFFSET cmdStore
    call StrCmpI
    test eax, eax
    jz IsStore
    
    mov esi, OFFSET tokenBuf
    mov edi, OFFSET cmdShow
    call StrCmpI
    test eax, eax
    jz IsShow
    
    mov esi, OFFSET tokenBuf
    mov edi, OFFSET cmdIncr
    call StrCmpI
    test eax, eax
    jz IsIncr
    
    pop esi
    mov edx, OFFSET errMsg
    call WriteString
    jmp ExecOK
    
IsExit:
    pop esi
    xor eax, eax
    jmp ExecRet
    
IsHelp:
    pop esi
    mov edx, OFFSET helpMsg
    call WriteString
    jmp ExecOK
    
IsClear:
    pop esi
    call Clrscr
    jmp ExecOK
    
IsPrint:
    pop esi
    
    ; Check for "if"
    push esi
    mov edi, esi
FindIf:
    mov al, [edi]
    test al, al
    je NoIf
    cmp al, 'i'
    je ChkIf
    cmp al, 'I'
    je ChkIf
    inc edi
    jmp FindIf
    
ChkIf:
    push edi
    push esi
    mov esi, edi
    push edi
    mov edi, OFFSET cmdIf
    call StrCmpI
    pop edi
    pop esi
    pop edi
    test eax, eax
    jz HasIf
    inc edi
    jmp FindIf
    
HasIf:
    mov BYTE PTR [edi], 0
    pop esi
    
    push esi
    lea esi, [edi+3]
    call EvalCond
    pop esi
    
    test eax, eax
    jz ExecOK
    
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
    
IsStore:
    pop esi
    call EvalExpr
    cmp edx, 1
    jne ExecOK
    
    push eax
    call SkipSpaces
    mov edi, OFFSET tokenBuf
    call GetToken
    
    mov edi, OFFSET tokenBuf
    call GetToken
    
    pop eax
    push eax
    push esi
    mov esi, OFFSET tokenBuf
    call SetVar
    pop esi
    pop eax
    jmp ExecOK
    
IsShow:
    pop esi
    mov edi, OFFSET tokenBuf
    call GetToken
    
    push esi
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
    pop esi
    jmp ExecOK
    
ShowErr:
    pop esi
    pop esi
    jmp ExecOK
    
IsIncr:
    pop esi
    mov edi, OFFSET tokenBuf
    call GetToken
    
    push esi
    push esi
    mov esi, OFFSET tokenBuf
    push esi
    call GetVar
    cmp edx, 1
    je @F
    xor eax, eax
@@: inc eax
    pop esi
    call SetVar
    pop esi
    pop esi
    jmp ExecOK
    
ExecOK:
    mov eax, 1
ExecRet:
    pop edi
    pop ecx
    pop ebx
    ret
    
cmdExit  BYTE "exit", 0
cmdHelp  BYTE "help", 0
cmdClear BYTE "clear", 0
cmdPrint BYTE "print", 0
cmdStore BYTE "store", 0
cmdShow  BYTE "show", 0
cmdIncr  BYTE "increment", 0
cmdIf    BYTE "if", 0
    
ExecSimple ENDP

; ============================================================================
; Nested Command Handler
; ============================================================================

ExecComplex PROC
    ; ESI=command line with potential comma/and
    push ebx
    push ecx
    push edi
    
    ; First, split by rightmost comma
    mov edi, esi
    xor ebx, ebx
    
FindLastComma:
    mov al, [edi]
    test al, al
    jz CheckComma
    cmp al, ','
    jne @F
    mov ebx, edi
@@: inc edi
    jmp FindLastComma
    
CheckComma:
    test ebx, ebx
    jz NoCommaFound
    
    ; Split at comma
    mov BYTE PTR [ebx], 0
    lea edi, [ebx+1]
    call SkipSpaces
    
    ; Check if right side is "loop N times"
    push esi
    push edi
    
    mov esi, edi
    push esi
    mov edi, OFFSET tokenBuf
    call GetToken
    
    mov esi, OFFSET tokenBuf
    mov edi, OFFSET cmdLoop
    call StrCmpI
    
    pop esi
    pop edi
    pop esi
    
    test eax, eax
    jnz NoCommaFound
    
    ; It's a loop!
    push esi
    mov esi, edi
    mov edi, OFFSET tokenBuf
    call GetToken
    
    mov edi, OFFSET tokenBuf
    call GetToken
    
    push esi
    mov esi, OFFSET tokenBuf
    call StrToInt
    pop esi
    pop esi
    
    cmp edx, 1
    jne NoCommaFound
    
    ; Loop EAX times
    mov ecx, eax
    test ecx, ecx  ; FIX: Check for zero loop count
    jz LoopDone
    
LoopIt:
    push ecx
    push esi
    call ExecComplex
    pop esi
    pop ecx
    loop LoopIt
    
LoopDone:
    mov eax, 1  ; Success after loop
    jmp ComplexDone
    
NoCommaFound:
    ; Check for "and" separator
    mov edi, esi
    xor ebx, ebx
    
FindAnd:
    mov al, [edi]
    test al, al
    jz NoAndFound
    
    cmp al, 'a'
    je ChkAnd
    cmp al, 'A'
    je ChkAnd
    inc edi
    jmp FindAnd
    
ChkAnd:
    push edi
    push esi
    mov esi, edi
    push edi
    mov edi, OFFSET cmdAnd
    call StrCmpI
    pop edi
    pop esi
    pop edi
    test eax, eax
    jz FoundAnd
    inc edi
    jmp FindAnd
    
FoundAnd:
    mov BYTE PTR [edi], 0
    
    push esi
    call ExecSimple
    pop esi
    
    test eax, eax
    jz ComplexDone  ; If exit command, preserve EAX=0
    
    lea esi, [edi+4]
    call ExecComplex
    jmp ComplexDone
    
NoAndFound:
    call ExecSimple
    
ComplexDone:
    ; EAX already contains return value from ExecSimple
    pop edi
    pop ecx
    pop ebx
    ret
    
cmdLoop BYTE "loop", 0
cmdAnd  BYTE "and", 0
    
ExecComplex ENDP

; ============================================================================
; Main
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
    mov ecx, 2048
    call ReadString
    
    ; FIX 1: Check if ReadString returned 0 (no input)
    test eax, eax
    jz MainLoop
    
    ; FIX 2: Ensure null terminator
    mov esi, OFFSET inputBuffer
    add esi, eax
    mov BYTE PTR [esi], 0
    
    ; FIX 3: Trim whitespace
    mov esi, OFFSET inputBuffer
    call TrimString
    
    ; FIX 4: Check if string is empty after trimming
    mov esi, OFFSET inputBuffer
    call IsEmptyString
    cmp eax, 1
    je MainLoop
    
    ; Copy to work buffer
    mov esi, OFFSET inputBuffer
    mov edi, OFFSET workBuf
    call StrCopy
    
    ; Execute
    mov esi, OFFSET workBuf
    call ExecComplex
    
    test eax, eax
    jnz MainLoop
    
    mov edx, OFFSET goodbyeMsg
    call WriteString
    
    INVOKE ExitProcess, 0
main ENDP

END main
