.386
.model flat, stdcall
.stack 4096
ExitProcess PROTO, dwExitCode:DWORD

INCLUDE Irvine32.inc

.data
    banner      BYTE "========================================",0Dh,0Ah
                BYTE " Human Language Scripting Interpreter v2.0",0Dh,0Ah
                BYTE " Type 'help' for commands",0Dh,0Ah
                BYTE " Type 'exit' to quit",0Dh,0Ah
                BYTE "========================================",0Dh,0Ah,0
    prompt      BYTE ">>> ",0
    inputBuffer BYTE 256 DUP(0)
    exprBuffer  BYTE 256 DUP(0)  ; Dedicated buffer for expression building
    
    ; Tokenization
    MAX_TOKENS      EQU 20
    MAX_TOKEN_LEN   EQU 32
    tokens          BYTE MAX_TOKENS * MAX_TOKEN_LEN DUP(0)
    tokenCount      DWORD 0
    
    ; Variables (simple array of name-value pairs)
    MAX_VARS        EQU 10
    varNames        BYTE MAX_VARS * MAX_TOKEN_LEN DUP(0)
    varValues       DWORD MAX_VARS DUP(0)
    varCount        DWORD 0
    
    ; Help text
    helpText    BYTE "Commands:",0Dh,0Ah
                BYTE "  help                     - Show this help",0Dh,0Ah
                BYTE "  print <text>             - Print text",0Dh,0Ah
                BYTE "  calculate <expr>         - Calculate expression (supports vars)",0Dh,0Ah
                BYTE "  store <expr> in <var>    - Save expression to variable",0Dh,0Ah
                BYTE "  show <var>               - Display variable",0Dh,0Ah
                BYTE "  clear                    - Clear screen",0Dh,0Ah
                BYTE "  exit                     - Exit interpreter",0Dh,0Ah,0
    
    ; Temporary buffer for variable name lookups (used by EvaluateExpression)
    tempVarName BYTE MAX_TOKEN_LEN DUP(0)
    addOp      BYTE ?    ; '+' or '-'
    mulOp      BYTE ?    ; '*', '/', or 0
    unarySign  BYTE ?    ; '+' or '-'
    expectFactor BYTE ?  ; 1 when next token must be a factor
    
    ; Command strings for matching
    cmdHelp     BYTE "help",0
    cmdPrint    BYTE "print",0
    cmdCalculate BYTE "calculate",0
    cmdStore    BYTE "store",0
    cmdShow     BYTE "show",0
    cmdClear    BYTE "clear",0
    cmdExit     BYTE "exit",0
    cmdQuit     BYTE "quit",0
    cmdIn       BYTE "in",0
    
    errorMsg    BYTE "Error: invalid command or syntax",0Dh,0Ah,0
    storeErrMsg BYTE "Error: syntax is 'store <expr> in <var>'",0Dh,0Ah,0
    showErrMsg  BYTE "Error: syntax is 'show <var>'",0Dh,0Ah,0
    varNotFoundMsg BYTE "Error: variable not found",0Dh,0Ah,0

.code

; StrEq - Compare two null-terminated strings (case-insensitive)
; Input: ESI = pointer to string 1, EDI = pointer to string 2
; Output: ZF=1 if equal, ZF=0 if not equal
StrEq PROC
    push eax
    push esi
    push edi
compareLoop:
    mov al, BYTE PTR [esi]
    mov ah, BYTE PTR [edi]
    
    ; Convert both to uppercase
    cmp al, 'a'
    jb skipLower1
    cmp al, 'z'
    ja skipLower1
    sub al, 32
skipLower1:
    cmp cl, '-'
    jne factorDone
    neg eax

factorDone:
skipLower2:
    
    ; Compare
    cmp al, ah
    jne notEqual
    
    ; Check if end of string
    cmp al, 0
    je stringsEqual
    
    inc esi
    inc edi
    jmp compareLoop
    
notEqual:
    pop edi
    pop esi
    pop eax
    xor eax, eax
    inc eax  ; Clear ZF
    ret
    
stringsEqual:
    pop edi
    pop esi
    pop eax
    xor eax, eax  ; Set ZF
    ret
StrEq ENDP

; Tokenize - Split input into tokens by spaces
; Input: none (uses inputBuffer)
; Output: tokenCount, tokens array filled
Tokenize PROC
    push eax
    push ebx
    push ecx
    push edx
    push esi
    push edi
    
    ; Clear token count
    mov tokenCount, 0
    
    ; Clear tokens array
    mov edi, OFFSET tokens
    mov ecx, MAX_TOKENS * MAX_TOKEN_LEN
    xor al, al
    rep stosb
    
    ; Start from beginning of input
    mov esi, OFFSET inputBuffer
    mov ebx, 0  ; Current token index
    
tokenLoop:
    ; Skip leading spaces
skipSpaces:
    mov al, BYTE PTR [esi]
    cmp al, 0
    je doneTok
    cmp al, ' '
    jne startToken
    inc esi
    jmp skipSpaces
    
startToken:
    ; Calculate address of current token
    mov eax, ebx
    mov ecx, MAX_TOKEN_LEN
    mul ecx
    lea edi, tokens[eax]
    
    ; Copy characters until space or null
    xor ecx, ecx
copyToken:
    mov al, BYTE PTR [esi]
    cmp al, 0
    je endToken
    cmp al, ' '
    je endToken
    cmp ecx, MAX_TOKEN_LEN - 1
    jge endToken
    
    mov BYTE PTR [edi], al
    inc esi
    inc edi
    inc ecx
    jmp copyToken
    
endToken:
    ; Null-terminate token
    mov BYTE PTR [edi], 0
    inc ebx
    cmp ebx, MAX_TOKENS
    jge doneTok
    jmp tokenLoop
    
doneTok:
    mov tokenCount, ebx
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret
Tokenize ENDP

; GetToken - Get pointer to specific token
; Input: EAX = token index (0-based)
; Output: EAX = pointer to token
GetToken PROC
    push ecx
    mov ecx, MAX_TOKEN_LEN
    mul ecx
    lea eax, tokens[eax]
    pop ecx
    ret
GetToken ENDP

; EvaluateExpression - Simple expression evaluator for "calculate" command
; Input: ESI = pointer to expression string (e.g., "5+3", "x-3", "10*2")
; Output: EAX = result (signed 32-bit)
; Handles: +, -, *, / with standard precedence
; Supports variables by name
EvaluateExpression PROC
    push ebx
    push ecx
    push edx
    push edi

    ; Evaluate first term
    call SkipWhitespace
    call ParseTerm       ; result in EAX

evalExprLoop:
    call SkipWhitespace
    mov dl, BYTE PTR [esi]
    cmp dl, '+'
    je doAddExpr
    cmp dl, '-'
    je doSubExpr
    jmp evalDone

doAddExpr:
    inc esi
    call ParseTerm       ; rhs in EAX
    add ebx, eax         ; use EBX as accumulator
    jmp evalExprLoop

doSubExpr:
    inc esi
    call ParseTerm
    sub ebx, eax
    jmp evalExprLoop

evalDone:
    mov eax, ebx         ; move final result to EAX
    pop edi
    pop edx
    pop ecx
    pop ebx
    ret
EvaluateExpression ENDP

; SkipWhitespace - Skip spaces, CR, LF
; Input: ESI = string pointer
; Output: ESI advanced past whitespace
SkipWhitespace PROC
skipLoop:
    mov al, BYTE PTR [esi]
    cmp al, ' '
    je skipAdvance
    cmp al, 0Dh
    je skipAdvance
    cmp al, 0Ah
    je skipAdvance
    ret
skipAdvance:
    inc esi
    jmp skipLoop
SkipWhitespace ENDP

; ParseTerm - term ::= factor { ('*'|'/') factor }
; Returns term value in EAX
ParseTerm PROC
    push ebx
    call ParseFactor     ; EAX = first factor
termLoop:
    call SkipWhitespace
    mov bl, BYTE PTR [esi]
    cmp bl, '*'
    je doMul
    cmp bl, '/'
    je doDiv
    pop ebx
    ret

doMul:
    inc esi
    call ParseFactor     ; rhs in EAX
    imul ebx, eax
    mov eax, ebx
    jmp termLoop

doDiv:
    inc esi
    call ParseFactor     ; rhs in EAX
    cmp eax, 0
    je zeroDivTerm
    mov ecx, eax         ; divisor
    mov eax, ebx         ; dividend
    cdq
    idiv ecx
    mov ebx, eax
    mov eax, ebx
    jmp termLoop
zeroDivTerm:
    xor ebx, ebx
    mov eax, ebx
    jmp termLoop
ParseTerm ENDP

; ParseFactor - factor ::= ['+'|'-'] (number | variable)
; Returns factor value in EAX
ParseFactor PROC
    push ecx
    push edi

    call SkipWhitespace
    mov cl, '+'          ; unary sign

    mov al, BYTE PTR [esi]
    cmp al, '+'
    jne chkUnaryMinus
    mov cl, '+'
    inc esi
    call SkipWhitespace
    jmp parseCore

chkUnaryMinus:
    cmp al, '-'
    jne parseCore
    mov cl, '-'
    inc esi
    call SkipWhitespace

parseCore:
    mov al, BYTE PTR [esi]
    cmp al, 'a'
    jb parseNumber
    cmp al, 'z'
    ja parseNumber

    ; variable name
    xor edi, edi
varCollect:
    mov al, BYTE PTR [esi]
    cmp al, 'a'
    jb endVar
    cmp al, 'z'
    ja endVar
    mov BYTE PTR tempVarName[edi], al
    inc edi
    inc esi
    jmp varCollect
endVar:
    mov BYTE PTR tempVarName[edi], 0
    push esi
    lea esi, tempVarName
    call FindVariable
    mov eax, eax         ; value already in EAX
    pop esi
    jnc gotFactor
    xor eax, eax         ; missing var -> 0
    jmp gotFactor

parseNumber:
    xor eax, eax
numCollect:
    mov al, BYTE PTR [esi]
    cmp al, '0'
    jb gotFactor
    cmp al, '9'
    ja gotFactor
    imul eax, 10
    movzx edx, al
    sub edx, '0'
    add eax, edx
    inc esi
    jmp numCollect

gotFactor:
    cmp cl, '-'
    jne factorDone2
    neg eax


    pop edi
    pop ecx
    ret
ParseFactor ENDP
; FindVariable - Find variable by name and get its value
; Input: ESI = pointer to variable name
; Output: EAX = value if found, CF=0
;         CF=1 if not found
FindVariable PROC
    push ecx
    push edx
    push edi
    
    xor ecx, ecx  ; index counter
    
findVarLp:
    cmp ecx, varCount
    jge varNotFoundFn
    
    ; Calculate address of variable name
    mov eax, ecx
    mov edx, MAX_TOKEN_LEN
    mul edx
    lea edi, varNames[eax]
    
    ; Compare names (StrEq expects ESI and EDI)
    call StrEq
    je varFoundFn
    
    inc ecx
    jmp findVarLp
    
varFoundFn:
    ; Found at index ECX - get value
    mov eax, ecx
    mov edx, 4
    mul edx
    mov eax, varValues[eax]
    clc  ; Clear carry flag
    jmp findVarEnd
    
varNotFoundFn:
    xor eax, eax
    stc  ; Set carry flag
    
findVarEnd:
    pop edi
    pop edx
    pop ecx
    ret
FindVariable ENDP

; StoreVariable - Store value in variable (creates or updates)
; Input: ESI = variable name, EAX = value to store
StoreVariable PROC
    push ebx
    push ecx
    push edx
    push edi
    
    mov ebx, eax    ; Save value in EBX
    xor ecx, ecx    ; index counter
    
storeSearchLp:
    cmp ecx, varCount
    jge storeCreateVr
    
    ; Calculate address of variable name
    mov eax, ecx
    mov edx, MAX_TOKEN_LEN
    mul edx
    lea edi, varNames[eax]
    
    ; Compare names
    call StrEq
    je storeUpdateVr
    
    inc ecx
    jmp storeSearchLp
    
storeUpdateVr:
    ; Update existing variable at index ECX
    mov eax, ecx
    mov edx, 4
    mul edx
    mov varValues[eax], ebx
    jmp storeEnd
    
storeCreateVr:
    ; Create new variable if space available
    cmp varCount, MAX_VARS
    jge storeEnd
    
    mov ecx, varCount
    mov eax, MAX_TOKEN_LEN
    mul ecx
    lea edi, varNames[eax]
    
    ; Copy name to variable array
    mov eax, esi
copyNmStLp:
    mov dl, BYTE PTR [eax]
    mov BYTE PTR [edi], dl
    cmp dl, 0
    je storeNmEnd
    inc eax
    inc edi
    jmp copyNmStLp
    
storeNmEnd:
    ; Store value at this new variable
    mov eax, varCount
    mov edx, 4
    mul edx
    mov varValues[eax], ebx
    
    inc varCount
    
storeEnd:
    pop edi
    pop edx
    pop ecx
    pop ebx
    ret
StoreVariable ENDP

main PROC
    ; Display banner
    mov edx, OFFSET banner
    call WriteString
    
mainLoop:
    ; Display prompt
    mov edx, OFFSET prompt
    call WriteString
    
    ; Read input
    mov edx, OFFSET inputBuffer
    mov ecx, SIZEOF inputBuffer
    call ReadString
    
    ; ReadString returns length in EAX and null-terminates
    ; But we need to ensure trailing CR/LF are removed
    cmp eax, 0
    je mainLoop
    
    ; Manually null-terminate at the returned length position
    mov BYTE PTR [inputBuffer + eax], 0
    
    ; Tokenize input
    call Tokenize
    
    ; Check if no tokens
    cmp tokenCount, 0
    je mainLoop
    
    ; Get first token (command)
    mov eax, 0
    call GetToken
    mov esi, eax
    
    ; Check for help command
    mov edi, OFFSET cmdHelp
    call StrEq
    je showHelp
    
    ; Check for print command
    mov edi, OFFSET cmdPrint
    call StrEq
    je printCmd
    
    ; Check for calculate command
    mov edi, OFFSET cmdCalculate
    call StrEq
    je calculateCmd
    
    ; Check for store command
    mov edi, OFFSET cmdStore
    call StrEq
    je storeCmd
    
    ; Check for show command
    mov edi, OFFSET cmdShow
    call StrEq
    je showCmd
    
    ; Check for clear command
    mov esi, eax
    mov edi, OFFSET cmdClear
    call StrEq
    je clearScreen
    
    ; Check for exit command
    mov esi, eax
    mov edi, OFFSET cmdExit
    call StrEq
    je exitProgram
    
    ; Check for quit command
    mov esi, eax
    mov edi, OFFSET cmdQuit
    call StrEq
    je exitProgram
    
    ; Unknown command - just loop back
    jmp mainLoop

showHelp:
    mov edx, OFFSET helpText
    call WriteString
    jmp mainLoop

printCmd:
    ; Print all tokens after "print" separated by spaces
    mov ebx, 1  ; Start from token 1 (skip "print")
printLoop:
    cmp ebx, tokenCount
    jge printDone
    
    mov eax, ebx
    call GetToken
    mov edx, eax
    call WriteString
    
    inc ebx
    cmp ebx, tokenCount
    jge printDone
    
    ; Print space between tokens
    mov al, ' '
    call WriteChar
    jmp printLoop
    
printDone:
    call Crlf
    jmp mainLoop

calculateCmd:
    ; Check if there's a second token (expression)
    cmp tokenCount, 1
    je calculateErr
    
    ; Build expression by concatenating tokens 1..N
    ; Use dedicated expression buffer
    lea edi, exprBuffer
    xor ebx, ebx
    mov ebx, 1          ; Start from token 1
    
buildExpr:
    cmp ebx, tokenCount
    jge doneBuilding
    
    ; Get token
    mov eax, ebx
    call GetToken
    mov esi, eax
    
    ; Add space if not first token
    cmp ebx, 1
    je noSpaceBefore
    mov BYTE PTR [edi], ' '
    inc edi
    
noSpaceBefore:
    ; Copy token
copyExprToken:
    mov al, BYTE PTR [esi]
    mov BYTE PTR [edi], al
    cmp al, 0
    je exprTokenDone
    inc esi
    inc edi
    jmp copyExprToken
    
exprTokenDone:
    inc ebx
    jmp buildExpr
    
doneBuilding:
    ; Null-terminate
    mov BYTE PTR [edi], 0
    
    ; Evaluate expression
    lea esi, exprBuffer
    call EvaluateExpression
    
    ; Print result
    call WriteInt
    call Crlf
    jmp mainLoop
    
calculateErr:
    mov edx, OFFSET errorMsg
    call WriteString
    jmp mainLoop

storeCmd:
    ; Check syntax: store <expr> in <var>
    ; Need at least 4 tokens: store, expr, in, varname
    cmp tokenCount, 4
    jl storeErr
    
    ; Get token 2 (should be "in")
    mov eax, 2
    call GetToken
    mov esi, eax
    mov edi, OFFSET cmdIn
    call StrEq
    jne storeErr
    
    ; Get token 1 (expression to evaluate)
    mov eax, 1
    call GetToken
    mov esi, eax
    call EvaluateExpression
    
    ; EAX now has the value
    ; Get token 3 (variable name)
    mov ebx, eax  ; Save result
    mov eax, 3
    call GetToken
    mov esi, eax
    mov eax, ebx  ; Restore result
    
    ; Store variable
    call StoreVariable
    jmp mainLoop
    
storeErr:
    mov edx, OFFSET storeErrMsg
    call WriteString
    jmp mainLoop

showCmd:
    ; Check syntax: show <var>
    cmp tokenCount, 2
    jl showErr
    
    ; Get variable name
    mov eax, 1
    call GetToken
    mov esi, eax
    
    ; Find and display variable
    call FindVariable
    jc varNotFoundShow
    
    ; Display value (in EAX)
    call WriteInt
    call Crlf
    jmp mainLoop
    
varNotFoundShow:
    mov edx, OFFSET varNotFoundMsg
    call WriteString
    jmp mainLoop
    
showErr:
    mov edx, OFFSET showErrMsg
    call WriteString
    jmp mainLoop

clearScreen:
    call Clrscr
    jmp mainLoop

exitProgram:
    INVOKE ExitProcess, 0

main ENDP
END main
