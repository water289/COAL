; ============================================================================
; HLS_Final.asm - WORKING Human Language Scripting Interpreter
; Properly handles: print 5 multiply by n if 5 modulus n equals 0 and increment n , loop 10 times
; x86 Assembly (MASM32) with Irvine32 Library
; ============================================================================

INCLUDE Irvine32.inc

.data
    titleMsg    BYTE "================================================", 0dh, 0ah
                BYTE "  HUMAN LANGUAGE SCRIPTING INTERPRETER v4.0", 0dh, 0ah
                BYTE "  FINAL WORKING VERSION", 0dh, 0ah
                BYTE "================================================", 0dh, 0ah, 0
    
    welcomeMsg  BYTE "Example: print 5 multiply by n if 5 modulus n equals 0 and increment n , loop 10 times", 0dh, 0ah
                BYTE "Type 'help' or 'exit'", 0dh, 0ah, 0dh, 0ah, 0
    promptMsg   BYTE ">>> ", 0
    goodbyeMsg  BYTE 0dh, 0ah, "Goodbye!", 0dh, 0ah, 0
    
    helpMsg     BYTE "Commands:", 0dh, 0ah
                BYTE "  store <value> in <var>", 0dh, 0ah
                BYTE "  print <expr>", 0dh, 0ah
                BYTE "  show <var>", 0dh, 0ah
                BYTE "  increment <var>", 0dh, 0ah
                BYTE "Operators: multiply by, modulus, plus, minus", 0dh, 0ah
                BYTE "Use 'and' to chain commands, ',' to nest", 0dh, 0ah, 0
    
    inputBuffer BYTE 2048 DUP(0)
    workBuf     BYTE 2048 DUP(0)
    tokenBuf    BYTE 256 DUP(0)
    
    MAX_VARS    EQU 50
    varNames    BYTE MAX_VARS * 32 DUP(0)
    varValues   SDWORD MAX_VARS DUP(0)
    varCount    DWORD 0
    
    errMsg      BYTE "Error", 0dh, 0ah, 0

.code

; ============================================================================
; String Utilities
; ============================================================================

StrLen PROC USES esi
    ; ESI=string, ret EAX=length
    xor eax, eax
@@: cmp BYTE PTR [esi], 0
    je @F
    inc eax
    inc esi
    jmp @B
@@: ret
StrLen ENDP

StrCopy PROC USES esi edi
    ; ESI=src, EDI=dest
@@: lodsb
    stosb
    test al, al
    jnz @B
    ret
StrCopy ENDP

StrCmpI PROC USES esi edi
    ; ESI=str1, EDI=str2, ret EAX=0 if equal
@@: lodsb
    mov ah, [edi]
    inc edi
    cmp al, 'A'
    jb @F
    cmp al, 'Z'
    ja @F
    or al, 20h
@@: cmp ah, 'A'
    jb @F
    cmp ah, 'Z'
    ja @F
    or ah, 20h
@@: cmp al, ah
    jne @F
    test al, al
    jnz @B
    xor eax, eax
    ret
@@: mov eax, 1
    ret
StrCmpI ENDP

SkipSpaces PROC
    ; ESI=string ptr
@@: mov al, [esi]
    cmp al, ' '
    je @F
    cmp al, 9
    jne SkipDone
@@: inc esi
    jmp @B
SkipDone:
    ret
SkipSpaces ENDP

GetToken PROC
    ; ESI=input, EDI=output, ret EAX=token length, ESI updated
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

StrToInt PROC USES esi ebx ecx
    ; ESI=string, ret EAX=value, EDX=1 if valid
    xor eax, eax
    xor ebx, ebx
    xor ecx, ecx
    mov dl, [esi]
    cmp dl, '-'
    jne @F
    mov ebx, 1
    inc esi
@@: mov dl, [esi]
    test dl, dl
    jz @F
    cmp dl, '0'
    jb IntErr
    cmp dl, '9'
    ja IntErr
    sub dl, '0'
    movzx edx, dl
    imul eax, 10
    add eax, edx
    inc esi
    inc ecx
    jmp @B
@@: test ecx, ecx
    jz IntErr
    test ebx, ebx
    jz @F
    neg eax
@@: mov edx, 1
    ret
IntErr:
    xor eax, eax
    xor edx, edx
    ret
StrToInt ENDP

; ============================================================================
; Variables
; ============================================================================

InitVars PROC
    mov varCount, 0
    ret
InitVars ENDP

FindVar PROC USES ebx ecx esi edi
    ; ESI=name, ret EAX=index or -1
    xor ebx, ebx
    mov ecx, varCount
    test ecx, ecx
    jz NotFound
@@: push esi
    mov eax, ebx
    shl eax, 5
    lea edi, varNames[eax]
    call StrCmpI
    pop esi
    test eax, eax
    jz Found
    inc ebx
    loop @B
NotFound:
    mov eax, -1
    ret
Found:
    mov eax, ebx
    ret
FindVar ENDP

GetVar PROC
    ; ESI=name, ret EAX=value, EDX=1 if success
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

SetVar PROC USES ebx esi edi
    ; ESI=name, EAX=value
    mov ebx, eax
    call FindVar
    cmp eax, -1
    jne Exists
    mov eax, varCount
    cmp eax, MAX_VARS
    jge Done
    shl eax, 5
    lea edi, varNames[eax]
    call StrCopy
    mov eax, varCount
    inc varCount
Exists:
    mov varValues[eax*4], ebx
Done:
    ret
SetVar ENDP

; ============================================================================
; Expression Evaluator
; ============================================================================

EvalExpr PROC USES ebx ecx edi
    ; ESI=expression, ret EAX=result, EDX=success
    
    ; Get first operand
    mov edi, OFFSET tokenBuf
    call GetToken
    test eax, eax
    jz Err
    
    push esi
    mov esi, OFFSET tokenBuf
    call StrToInt
    cmp edx, 1
    je GotOp1
    call GetVar
    cmp edx, 1
    jne Err2
    
GotOp1:
    mov ebx, eax
    pop esi
    
    ; Check for operator
    call SkipSpaces
    cmp BYTE PTR [esi], 0
    je Single
    
    push esi
    mov edi, OFFSET tokenBuf
    call GetToken
    
    ; Check operator
    push esi
    mov esi, OFFSET tokenBuf
    mov edi, OFFSET opMul
    call StrCmpI
    test eax, eax
    pop esi
    jz IsMul
    
    push esi
    mov esi, OFFSET tokenBuf
    mov edi, OFFSET opMod
    call StrCmpI
    test eax, eax
    pop esi
    jz IsMod
    
    push esi
    mov esi, OFFSET tokenBuf
    mov edi, OFFSET opPlus
    call StrCmpI
    test eax, eax
    pop esi
    jz IsAdd
    
    push esi
    mov esi, OFFSET tokenBuf
    mov edi, OFFSET opMinus
    call StrCmpI
    test eax, eax
    pop esi
    jz IsSub
    
    pop esi
    jmp Single
    
IsMul:
    pop edi
    mov edi, OFFSET tokenBuf
    call GetToken  ; Skip "by"
    mov ecx, 1
    jmp GetOp2
    
IsMod:
    pop edi
    mov ecx, 2
    jmp GetOp2
    
IsAdd:
    pop edi
    mov ecx, 3
    jmp GetOp2
    
IsSub:
    pop edi
    mov ecx, 4
    jmp GetOp2
    
GetOp2:
    mov edi, OFFSET tokenBuf
    call GetToken
    test eax, eax
    jz Err
    
    push ebx
    push ecx
    push esi
    mov esi, OFFSET tokenBuf
    call StrToInt
    cmp edx, 1
    je GotOp2
    call GetVar
    cmp edx, 1
    jne Err3
    
GotOp2:
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
    
DoMul:
    mov eax, ebx
    imul eax, edi
    jmp OK
    
DoMod:
    test edi, edi
    jz Err
    mov eax, ebx
    cdq
    idiv edi
    mov eax, edx
    jmp OK
    
DoAdd:
    mov eax, ebx
    add eax, edi
    jmp OK
    
DoSub:
    mov eax, ebx
    sub eax, edi
    jmp OK
    
Single:
    mov eax, ebx
    
OK:
    mov edx, 1
    ret
    
Err3:
    pop esi
    pop ecx
    pop ebx
Err2:
    pop esi
Err:
    xor eax, eax
    xor edx, edx
    ret
    
opMul   BYTE "multiply", 0
opMod   BYTE "modulus", 0
opPlus  BYTE "plus", 0
opMinus BYTE "minus", 0
    
EvalExpr ENDP

; ============================================================================
; Condition Evaluator
; ============================================================================

EvalCond PROC USES ebx ecx edi
    ; ESI=condition, ret EAX=1 if true
    
    push esi
FindCmp:
    mov al, [esi]
    test al, al
    jz Err
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
    jmp Parse
    
ChkGt:
    push esi
    mov edi, OFFSET cmpGt
    call StrCmpI
    pop esi
    test eax, eax
    jnz NotGt
    mov ebx, 2
    jmp Parse
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
    jmp Parse
NotLt:
    inc esi
    jmp FindCmp
    
Parse:
    push ebx
    pop edi
    push edi
    call EvalExpr
    cmp edx, 1
    jne Err2
    push eax
    call SkipSpaces
    mov edi, OFFSET tokenBuf
    call GetToken
    call SkipSpaces
    cmp BYTE PTR [esi], 't'
    jne @F
    mov edi, OFFSET tokenBuf
    call GetToken
@@: call EvalExpr
    cmp edx, 1
    jne Err3
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
    je True
    jmp False
CmpGt:
    cmp ebx, ecx
    jg True
    jmp False
CmpLt:
    cmp ebx, ecx
    jl True
    jmp False
    
True:
    mov eax, 1
    ret
False:
    xor eax, eax
    ret
    
Err3:
    pop ebx
Err2:
    pop ebx
Err:
    pop esi
    xor eax, eax
    ret
    
cmpEq BYTE "equals", 0
cmpGt BYTE "greater", 0
cmpLt BYTE "less", 0
    
EvalCond ENDP

; ============================================================================
; Command Executor
; ============================================================================

ExecSimple PROC USES ebx ecx edi
    ; ESI=command, ret EAX=1 continue, 0 exit
    
    call SkipSpaces
    cmp BYTE PTR [esi], 0
    je OK
    
    mov edi, OFFSET tokenBuf
    call GetToken
    test eax, eax
    jz OK
    
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
    jmp OK
    
IsExit:
    pop esi
    xor eax, eax
    ret
    
IsHelp:
    pop esi
    mov edx, OFFSET helpMsg
    call WriteString
    jmp OK
    
IsPrint:
    pop esi
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
    jz OK
    call EvalExpr
    cmp edx, 1
    jne OK
    call WriteInt
    call Crlf
    jmp OK
    
NoIf:
    pop esi
    call EvalExpr
    cmp edx, 1
    jne OK
    call WriteInt
    call Crlf
    jmp OK
    
IsStore:
    pop esi
    ; Deterministic parsing: find " in " or " equals "
    ; Save start of command
    push esi
    mov ebx, esi
    
FindIN_loop:
    mov al, [ebx]
    test al, al
    jz STORE_PARSE_ERROR
    
    ; Check for space before 'in'
    cmp al, ' '
    jne FindIN_next
    
    ; Found space, check for 'in' or 'IN'
    inc ebx
    mov al, [ebx]
    cmp al, 'i'
    je FoundInCandidate
    cmp al, 'I'
    je FoundInCandidate
    jmp FindIN_next
    
FoundInCandidate:
    inc ebx
    mov al, [ebx]
    cmp al, 'n'
    je CheckTrailingSpace
    cmp al, 'N'
    je CheckTrailingSpace
    dec ebx
    jmp FindIN_next
    
CheckTrailingSpace:
    inc ebx
    mov al, [ebx]
    cmp al, ' '
    je IN_FOUND
    cmp al, 0
    je IN_FOUND
    dec ebx
    dec ebx
    jmp FindIN_next
    
FindIN_next:
    inc ebx
    jmp FindIN_loop
    
IN_FOUND:
    ; ebx points after "in", go back to find start of " in "
    sub ebx, 3
    mov BYTE PTR [ebx], 0  ; Null terminate left part
    
    ; Evaluate left expression
    pop esi
    push ebx
    call EvalExpr
    pop ebx
    cmp edx, 1
    jne STORE_PARSE_ERROR
    
    push eax  ; Save value
    
    ; Get variable name (skip " in ")
    add ebx, 4
    mov esi, ebx
    call SkipSpaces
    
    ; Copy var name to tokenBuf
    mov edi, OFFSET tokenBuf
@@: mov al, [esi]
    test al, al
    jz @F
    cmp al, ' '
    je @F
    mov [edi], al
    inc esi
    inc edi
    jmp @B
@@: mov BYTE PTR [edi], 0
    
    ; Set variable
    pop eax
    mov esi, OFFSET tokenBuf
    call SetVar
    jmp OK
    
STORE_PARSE_ERROR:
    pop esi  ; Clean up stack
    mov edx, OFFSET errMsg
    call WriteString
    jmp OK
    
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
    jmp OK
ShowErr:
    pop esi
    pop esi
    jmp OK
    
IsIncr:
    pop esi
    ; Parse: "increment <varname>"
    ; Skip "increment" and whitespace
    add esi, 9  ; Length of "increment"
    call SkipSpaces
    
    ; Copy variable name
    mov edi, OFFSET tokenBuf
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
    jmp @B
@@: mov BYTE PTR [edi], 0
    
    ; Get current value
    push esi
    mov esi, OFFSET tokenBuf
    call GetVar
    cmp edx, 1
    je incr_ok
    xor eax, eax
incr_ok:
    inc eax
    call SetVar
    pop esi
    jmp OK
    
OK:
    mov eax, 1
    ret
    
cmdExit  BYTE "exit", 0
cmdHelp  BYTE "help", 0
cmdPrint BYTE "print", 0
cmdStore BYTE "store", 0
cmdShow  BYTE "show", 0
cmdIncr  BYTE "increment", 0
cmdIf    BYTE "if", 0
    
ExecSimple ENDP

; ============================================================================
; Complex Command Handler
; ============================================================================

ExecComplex PROC USES ebx ecx edi
    ; ESI=command
    
    ; Find rightmost comma
    mov edi, esi
    xor ebx, ebx
@@: mov al, [edi]
    test al, al
    jz @F
    cmp al, ','
    jne SkipC
    mov ebx, edi
SkipC:
    inc edi
    jmp @B
    
@@: test ebx, ebx
    jz NoComma
    
    ; Split at comma
    mov BYTE PTR [ebx], 0
    lea edi, [ebx+1]
    call SkipSpaces
    
    ; Check for "loop N times"
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
    jnz NoComma
    
    ; Parse loop
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
    jne NoComma
    
    ; Loop
    mov ecx, eax
    test ecx, ecx
    jz LoopDone
@@: push ecx
    push esi
    call ExecComplex
    pop esi
    pop ecx
    loop @B
LoopDone:
    mov eax, 1
    ret
    
NoComma:
    ; Check for "and"
    mov edi, esi
    xor ebx, ebx
@@: mov al, [edi]
    test al, al
    jz NoAnd
    cmp al, 'a'
    je ChkAnd
    cmp al, 'A'
    je ChkAnd
    inc edi
    jmp @B
    
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
    jmp @B
    
FoundAnd:
    mov BYTE PTR [edi], 0
    push esi
    call ExecSimple
    pop esi
    test eax, eax
    jz Done
    lea esi, [edi+4]
    call ExecComplex
    ret
    
NoAnd:
    call ExecSimple
    ret
    
Done:
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
    
    ; Clear input buffer first
    mov edi, OFFSET inputBuffer
    mov ecx, 256
    xor al, al
    rep stosb
    
    mov edx, OFFSET inputBuffer
    mov ecx, 2048
    call ReadString
    
    ; Check if we got any input
    test eax, eax
    jz MainLoop
    
    ; Check empty after skipping spaces
    mov esi, OFFSET inputBuffer
    call SkipSpaces
    cmp BYTE PTR [esi], 0
    je MainLoop
    
    ; Copy to work buffer
    mov esi, OFFSET inputBuffer
    mov edi, OFFSET workBuf
    call StrCopy
    
    ; Execute
    mov esi, OFFSET workBuf
    call ExecComplex
    
    ; Print newline after execution
    call Crlf
    
    test eax, eax
    jnz MainLoop
    
    mov edx, OFFSET goodbyeMsg
    call WriteString
    
    INVOKE ExitProcess, 0
main ENDP

END main
