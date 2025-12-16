; Human Language Scripting Interpreter (HL) - Fixed calling conventions
; Fixes:
; - Standardized CompareStringsCase call order (push tokenPtr then push OFFSET keyword)
; - Removed unnecessary push/pop around FindVariable; pass parameter via ESI and call directly
; - Minor cleanup to avoid stack corruption that caused the REPL to exit unexpectedly
;
; Uses natural language commands: store, print, increment, etc.
; Operators as words: equals, greater than, multiply, etc.
; Requires Irvine32.inc and Irvine32.lib in INCLUDE/LIB paths.

INCLUDE ..\include\Irvine32.inc

.data
    MAX_VARS = 64
    MAX_VAR_NAME = 20
    MAX_STR_LEN = 256
    MAX_TOKENS = 32
    TOKEN_SIZE = 64

    varNames BYTE MAX_VARS * MAX_VAR_NAME DUP(0)
    varValues DWORD MAX_VARS DUP(0)
    varCount DWORD 0
    exitFlag DWORD 0

    inputBuffer BYTE 512 DUP(0)
    tokenBuffer BYTE MAX_TOKENS * TOKEN_SIZE DUP(0)
    tokenCount DWORD 0
    currentToken DWORD 0

    prompt BYTE ">>> ", 0
    newLine BYTE 0Dh, 0Ah, 0
    
    ; Command keywords
    storeCmd BYTE "store", 0
    printCmd BYTE "print", 0
    incrementCmd BYTE "increment", 0
    decrementCmd BYTE "decrement", 0
    repeatCmd BYTE "repeat", 0
    ifCmd BYTE "if", 0
    showCmd BYTE "show", 0
    clearCmd BYTE "clear", 0
    helpCmd BYTE "help", 0
    exitCmd BYTE "exit", 0
    quitCmd BYTE "quit", 0
    inCmd BYTE "in", 0
    timesCmd BYTE "times", 0
    byCmd BYTE "by", 0
    
    ; Error messages
    invalidSyntax BYTE "ERROR: Invalid syntax!", 0Dh, 0Ah
                  BYTE "Example: store 0 in n", 0Dh, 0Ah, 0
    
    unrecognizedCmd BYTE "ERROR: Unrecognised command!", 0Dh, 0Ah
                    BYTE "Type 'help' for available commands.", 0Dh, 0Ah, 0
    
    undefinedVar BYTE "ERROR: Variable not defined: ", 0
    
    divideByZero BYTE "ERROR: Division by zero!", 0Dh, 0Ah, 0
    
    successMsg BYTE "OK", 0Dh, 0Ah, 0
    
    helpMsg BYTE "=== Human Language Interpreter ===", 0Dh, 0Ah
             BYTE "Available Commands:", 0Dh, 0Ah, 0Dh, 0Ah
             BYTE "  store <value> in <var>  - Create/update variable", 0Dh, 0Ah
             BYTE "    Example: store 0 in n", 0Dh, 0Ah, 0Dh, 0Ah
             BYTE "  print <value>           - Display value", 0Dh, 0Ah
             BYTE "    Example: print 42", 0Dh, 0Ah, 0Dh, 0Ah
             BYTE "  print <value> N times   - Repeat output", 0Dh, 0Ah
             BYTE "    Example: print 5 3 times", 0Dh, 0Ah, 0Dh, 0Ah
             BYTE "  increment <var>         - Add 1 to variable", 0Dh, 0Ah
             BYTE "    Example: increment count", 0Dh, 0Ah, 0Dh, 0Ah
             BYTE "  increment <var> by N    - Add N to variable", 0Dh, 0Ah
             BYTE "    Example: increment count by 5", 0Dh, 0Ah, 0Dh, 0Ah
             BYTE "  decrement <var>         - Subtract 1", 0Dh, 0Ah
             BYTE "    Example: decrement count", 0Dh, 0Ah, 0Dh, 0Ah
             BYTE "  decrement <var> by N    - Subtract N", 0Dh, 0Ah
             BYTE "    Example: decrement count by 10", 0Dh, 0Ah, 0Dh, 0Ah
             BYTE "  show <var>              - Display variable", 0Dh, 0Ah
             BYTE "    Example: show count", 0Dh, 0Ah, 0Dh, 0Ah
             BYTE "  clear                   - Clear all variables", 0Dh, 0Ah
             BYTE "  help                    - Show this help", 0Dh, 0Ah
             BYTE "  exit                    - Exit program", 0Dh, 0Ah, 0

.code

main PROC
    mov eax, white
    call SetTextColor
    mov exitFlag, 0

REPL_LOOP:
    mov edx, OFFSET prompt
    call WriteString
    
    mov edx, OFFSET inputBuffer
    mov ecx, 512
    call ReadString
    
    cmp eax, 0
    je REPL_LOOP
    
    mov edx, OFFSET inputBuffer
    call Tokenize
    
    cmp eax, 0
    je REPL_LOOP
    
    call ExecuteCommand
    
    cmp exitFlag, 1
    je EXIT_PROGRAM
    
    jmp REPL_LOOP
    
EXIT_PROGRAM:
    INVOKE ExitProcess, 0
main ENDP

;==============================================================================
; Tokenize: Parse input into tokens
; Input: EDX = input string
;==============================================================================
Tokenize PROC
    push ebp
    mov ebp, esp
    push ebx
    push ecx
    push esi
    push edi
    
    mov esi, edx
    mov edi, OFFSET tokenBuffer
    xor ecx, ecx
    xor ebx, ebx
    
TOKENIZE_LOOP:
    movzx eax, BYTE PTR [esi]
    
    cmp al, 0
    je TOKENIZE_DONE
    
    cmp al, ' '
    je TOKENIZE_SPACE
    
    cmp al, 9
    je TOKENIZE_SPACE
    
    cmp al, '{'
    je TOKENIZE_BRACE_OPEN
    
    cmp al, '}'
    je TOKENIZE_BRACE_CLOSE
    
    mov BYTE PTR [edi], al
    inc edi
    inc ebx
    inc esi
    jmp TOKENIZE_LOOP
    
TOKENIZE_SPACE:
    cmp ebx, 0
    je TOKENIZE_SKIP_SPACE
    
    mov BYTE PTR [edi], 0
    inc edi
    inc ecx
    xor ebx, ebx
    
TOKENIZE_SKIP_SPACE:
    inc esi
    jmp TOKENIZE_LOOP
    
TOKENIZE_BRACE_OPEN:
    cmp ebx, 0
    jne TOKENIZE_SAVE_CURRENT
    
    mov BYTE PTR [edi], '{'
    inc edi
    mov BYTE PTR [edi], 0
    inc edi
    inc ecx
    inc esi
    jmp TOKENIZE_LOOP
    
TOKENIZE_SAVE_CURRENT:
    mov BYTE PTR [edi], 0
    inc edi
    inc ecx
    xor ebx, ebx
    
    mov BYTE PTR [edi], '{'
    inc edi
    mov BYTE PTR [edi], 0
    inc edi
    inc ecx
    inc esi
    jmp TOKENIZE_LOOP
    
TOKENIZE_BRACE_CLOSE:
    cmp ebx, 0
    jne TOKENIZE_SAVE_CURRENT2
    
    mov BYTE PTR [edi], '}'
    inc edi
    mov BYTE PTR [edi], 0
    inc edi
    inc ecx
    inc esi
    jmp TOKENIZE_LOOP
    
TOKENIZE_SAVE_CURRENT2:
    mov BYTE PTR [edi], 0
    inc edi
    inc ecx
    xor ebx, ebx
    
    mov BYTE PTR [edi], '}'
    inc edi
    mov BYTE PTR [edi], 0
    inc edi
    inc ecx
    inc esi
    jmp TOKENIZE_LOOP
    
TOKENIZE_DONE:
    cmp ebx, 0
    je TOKENIZE_FINAL
    
    mov BYTE PTR [edi], 0
    inc ecx
    
TOKENIZE_FINAL:
    mov tokenCount, ecx
    mov eax, ecx
    
    pop edi
    pop esi
    pop ecx
    pop ebx
    pop ebp
    ret
Tokenize ENDP

;==============================================================================
; GetToken: Get token at index
; Input: EAX = token index
; Output: EAX = pointer to token
;==============================================================================
GetToken PROC
    push ebx
    push ecx
    push edx
    
    mov ebx, OFFSET tokenBuffer
    mov ecx, 0
    
GET_TOKEN_LOOP:
    cmp ecx, eax
    je GET_TOKEN_FOUND
    
GT_SKIP_LOOP:
    mov dl, BYTE PTR [ebx]
    cmp dl, 0
    je GT_SKIP_DONE
    inc ebx
    jmp GT_SKIP_LOOP
    
GT_SKIP_DONE:
    inc ebx
    inc ecx
    jmp GET_TOKEN_LOOP
    
GET_TOKEN_FOUND:
    mov eax, ebx
    jmp GET_TOKEN_EXIT
    
GET_TOKEN_NOT_FOUND:
    xor eax, eax
    
GET_TOKEN_EXIT:
    pop edx
    pop ecx
    pop ebx
    ret
GetToken ENDP

;==============================================================================
; ExecuteCommand: Main command dispatcher
;==============================================================================
ExecuteCommand PROC
    push ebp
    mov ebp, esp
    
    cmp tokenCount, 0
    je EXEC_RETURN
    
    xor eax, eax
    call GetToken
    mov esi, eax
    
    ; Command: store
    push esi
    push OFFSET storeCmd
    call CompareStringsCase
    add esp, 8
    cmp eax, 1
    je EXEC_STORE
    
    ; Command: print
    push esi
    push OFFSET printCmd
    call CompareStringsCase
    add esp, 8
    cmp eax, 1
    je EXEC_PRINT
    
    ; Command: increment
    push esi
    push OFFSET incrementCmd
    call CompareStringsCase
    add esp, 8
    cmp eax, 1
    je EXEC_INCREMENT
    
    ; Command: decrement
    push esi
    push OFFSET decrementCmd
    call CompareStringsCase
    add esp, 8
    cmp eax, 1
    je EXEC_DECREMENT
    
    ; Command: show
    push esi
    push OFFSET showCmd
    call CompareStringsCase
    add esp, 8
    cmp eax, 1
    je EXEC_SHOW
    
    ; Command: clear
    push esi
    push OFFSET clearCmd
    call CompareStringsCase
    add esp, 8
    cmp eax, 1
    je EXEC_CLEAR
    
    ; Command: help
    push esi
    push OFFSET helpCmd
    call CompareStringsCase
    add esp, 8
    cmp eax, 1
    je EXEC_HELP
    
    ; Command: exit / quit
    push esi
    push OFFSET exitCmd
    call CompareStringsCase
    add esp, 8
    cmp eax, 1
    je EXEC_EXIT
    
    push esi
    push OFFSET quitCmd
    call CompareStringsCase
    add esp, 8
    cmp eax, 1
    je EXEC_EXIT
    
    ; Unknown command
    jmp EXEC_INVALID
    
EXEC_STORE:
    call doStore
    jmp EXEC_RETURN
    
EXEC_PRINT:
    call doPrint
    jmp EXEC_RETURN
    
EXEC_INCREMENT:
    call doIncrement
    jmp EXEC_RETURN
    
EXEC_DECREMENT:
    call doDecrement
    jmp EXEC_RETURN
    
EXEC_SHOW:
    call doShow
    jmp EXEC_RETURN
    
EXEC_CLEAR:
    call doClear
    jmp EXEC_RETURN
    
EXEC_HELP:
    call doHelp
    jmp EXEC_RETURN
    
EXEC_EXIT:
    mov exitFlag, 1
    jmp EXEC_RETURN
    
EXEC_INVALID:
    mov edx, OFFSET unrecognizedCmd
    call WriteString
    
EXEC_RETURN:
    pop ebp
    ret
ExecuteCommand ENDP

;==============================================================================
; doStore: store <value> in <var>
;==============================================================================
doStore PROC
    push ebp
    mov ebp, esp
    push eax
    push ebx
    push ecx
    push edx
    push esi
    push edi
    
    cmp tokenCount, 4
    jne STORE_ERROR
    
    ; Get value token (1)
    mov eax, 1
    call GetToken
    mov esi, eax
    
    ; Check "in" keyword
    mov eax, 2
    call GetToken
    ; push token then keyword (token first)
    push eax
    push OFFSET inCmd
    call CompareStringsCase
    add esp, 8
    cmp eax, 1
    jne STORE_ERROR
    
    ; Get variable name token (3)
    mov eax, 3
    call GetToken
    mov edi, eax
    
    ; Evaluate value
    ; ESI already points to value token
    call EvaluateExpression
    mov ebx, eax
    
    ; Store variable
    mov esi, edi        ; pass var name in ESI for FindVariable/StoreVariable uses
    push ebx
    push edi
    call StoreVariable
    add esp, 8
    
    mov edx, OFFSET successMsg
    call WriteString
    jmp STORE_EXIT
    
STORE_ERROR:
    mov edx, OFFSET invalidSyntax
    call WriteString
    
STORE_EXIT:
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    pop eax
    pop ebp
    ret
doStore ENDP

;==============================================================================
; doPrint: print <value> [<N> times]
;==============================================================================
doPrint PROC
    push ebp
    mov ebp, esp
    push eax
    push ebx
    push ecx
    push edx
    push esi
    push edi
    
    cmp tokenCount, 1
    jl PRINT_ERROR
    
    ; Get value (token 1)
    mov eax, 1
    call GetToken
    mov esi, eax
    
    ; Evaluate value
    call EvaluateExpression
    mov ebx, eax
    
    ; Check for "N times" pattern
    mov ecx, 1
    
    ; Get second token
    mov eax, 2
    call GetToken
    mov edi, eax
    
    ; Check if it's a number (repeat count)
    push edi
    call StringToInt
    pop edi
    jc PRINT_NOW
    
    ; It's a number, check for "times"
    mov eax, 3
    call GetToken
    push eax
    push OFFSET timesCmd
    call CompareStringsCase
    add esp, 8
    cmp eax, 1
    jne PRINT_NOW
    
    ; Get repeat count
    mov eax, 2
    call GetToken
    push eax
    call StringToInt
    pop eax
    mov ecx, eax
    call GetToken
    call StringToInt
    mov ecx, eax
    
PRINT_NOW:
    mov eax, ebx
    mov edx, ecx
    
PRINT_LOOP:
    cmp edx, 0
    je PRINT_EXIT
    
    mov eax, ebx
    call WriteDec
    call Crlf
    dec edx
    jmp PRINT_LOOP
    
PRINT_ERROR:
    mov edx, OFFSET invalidSyntax
    call WriteString
    
PRINT_EXIT:
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    pop eax
    pop ebp
    ret
doPrint ENDP

;==============================================================================
; doIncrement: increment <var> [by <value>]
;==============================================================================
doIncrement PROC
    push ebp
    mov ebp, esp
    push eax
    cmp tokenCount, 2
    jl INCR_ERROR
    
    mov eax, 1
    call GetToken
    mov esi, eax    ; ESI = token pointer (var name)
    
    mov ebx, 1
    
    cmp tokenCount, 4
    jne INCR_DO
    
    mov eax, 2
    call GetToken
    push eax
    push OFFSET byCmd
    call CompareStringsCase
    add esp, 8
    cmp eax, 1
    jne INCR_DO
    
    mov eax, 3
    call GetToken
    push eax
    call StringToInt
    pop eax
    mov ebx, eax
    
INCR_DO:
    ; Call FindVariable with ESI already set to var name
    call FindVariable
    
    cmp eax, -1
    je INCR_ERROR
    
    mov ecx, eax
    add dword ptr varValues[ecx * 4], ebx
    
    mov edx, OFFSET successMsg
    call WriteString
    jmp INCR_EXIT
    
INCR_ERROR:
    mov edx, OFFSET invalidSyntax
    call WriteString
    
INCR_EXIT:
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    pop eax
    pop ebp
    ret
doIncrement ENDP

;==============================================================================
; doDecrement: decrement <var> [by <value>]
;==============================================================================
doDecrement PROC
    push ebp
    mov ebp, esp
    cmp tokenCount, 2
    jl DECR_ERROR
    
    mov eax, 1
    call GetToken
    mov esi, eax    ; ESI = token pointer (var name)
    
    mov ebx, 1
    
    cmp tokenCount, 4
    jne DECR_DO
    
    mov eax, 2
    call GetToken
    push eax
    push OFFSET byCmd
    call CompareStringsCase
    add esp, 8
    cmp eax, 1
    jne DECR_DO
    
    mov eax, 3
    call GetToken
    push eax
    call StringToInt
    pop eax
    mov ebx, eax
    
DECR_DO:
    ; Call FindVariable with ESI already set to var name
    call FindVariable
    
    cmp eax, -1
    je DECR_ERROR
    
    mov ecx, eax
    sub dword ptr varValues[ecx * 4], ebx
    
    mov edx, OFFSET successMsg
    call WriteString
    jmp DECR_EXIT
    
DECR_ERROR:
    mov edx, OFFSET invalidSyntax
    call WriteString
    
DECR_EXIT:
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    pop eax
    pop ebp
    ret
doDecrement ENDP

;==============================================================================
; doShow: show <var>
;==============================================================================
doShow PROC
    push ebp
    mov ebp, esp
    push eax
    push ecx
    push edx
    push esi
    push edi
    
    cmp tokenCount, 2
    jne SHOW_ERROR
    
    mov eax, 1
    call GetToken
    mov esi, eax    ; ESI = var name pointer
    
    ; Call FindVariable with ESI set
    call FindVariable
    
    cmp eax, -1
    je SHOW_NOT_FOUND
    
    mov ecx, eax
    mov eax, varValues[ecx * 4]
    call WriteDec
    call Crlf
    jmp SHOW_EXIT
    
SHOW_NOT_FOUND:
    mov edx, OFFSET undefinedVar
    call WriteString
    mov edx, esi
    call WriteString
    call Crlf
    jmp SHOW_EXIT
    
SHOW_ERROR:
    mov edx, OFFSET invalidSyntax
    call WriteString
    
SHOW_EXIT:
    pop edi
    pop esi
    pop edx
    pop ecx
    pop eax
    pop ebp
    ret
doShow ENDP

;==============================================================================
; doClear: clear all variables
;==============================================================================
doClear PROC
    xor eax, eax
    mov varCount, eax
    mov edx, OFFSET successMsg
    call WriteString
    ret
doClear ENDP

;==============================================================================
; doHelp: display help
;==============================================================================
doHelp PROC
    push ebp
    mov ebp, esp
    
    mov edx, OFFSET helpMsg
    call WriteString
    call Crlf
    
    pop ebp
    ret
doHelp ENDP

;==============================================================================
; FindVariable: Find variable by name
; Input: ESI = variable name
; Output: EAX = index or -1
;==============================================================================
FindVariable PROC
    push ebx
    push ecx
    push edi
    
    xor ecx, ecx
    mov ebx, varCount
    
FIND_VAR_LOOP:
    cmp ecx, ebx
    jge FIND_VAR_NOT_FOUND
    
    mov edi, OFFSET varNames
    mov eax, ecx
    mov edx, MAX_VAR_NAME
    imul eax, edx
    add edi, eax
    
    ; Compare: push token then stored name (tokenPointer then storedName)
    push esi
    push edi
    call CompareStringsCase
    add esp, 8
    
    cmp eax, 1
    je FIND_VAR_FOUND
    
    inc ecx
    jmp FIND_VAR_LOOP
    
FIND_VAR_FOUND:
    mov eax, ecx
    jmp FIND_VAR_EXIT
    
FIND_VAR_NOT_FOUND:
    mov eax, -1
    
FIND_VAR_EXIT:
    pop edi
    pop ecx
    pop ebx
    ret
FindVariable ENDP
    
FIND_VAR_EXIT:
    pop edi
    pop esi
    pop ecx
;==============================================================================
; StoreVariable: Store variable
; Input: Stack [ebp+12]=varNamePtr, [ebp+8]=value
;==============================================================================
StoreVariable PROC
    push ebp
    mov ebp, esp
    push eax
    push ebx
    push ecx
    push edx
    push esi
    push edi
    
    mov edi, [ebp + 12]   ; varName pointer
    mov ebx, [ebp + 8]    ; value
    
    mov esi, edi          ; set ESI for FindVariable
    call FindVariable     ; returns index in EAX or -1
    
    cmp eax, -1
    jne STORE_VAR_EXISTS
    
    cmp varCount, MAX_VARS
    jge STORE_VAR_EXIT
    
    mov ecx, varCount
    mov esi, OFFSET varNames
    mov eax, ecx
    mov edx, MAX_VAR_NAME
    imul eax, edx
    add esi, eax
    
    mov ecx, 0
STORE_VAR_COPY:
    mov al, BYTE PTR [edi + ecx]
    mov BYTE PTR [esi + ecx], al
    cmp al, 0
    je STORE_VAR_COPY_DONE
    inc ecx
    cmp ecx, MAX_VAR_NAME
    jl STORE_VAR_COPY
    
STORE_VAR_COPY_DONE:
    mov eax, varCount
    mov varValues[eax * 4], ebx
    inc varCount
    jmp STORE_VAR_EXIT
    
STORE_VAR_EXISTS:
    mov ecx, eax
    mov varValues[ecx * 4], ebx
    
STORE_VAR_EXIT:
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    pop eax
    pop ebp
    ret 8      ; Clean up 2 parameters (8 bytes)
StoreVariable ENDP

;==============================================================================
; EvaluateExpression: Evaluate numeric expression
; Input: ESI = expression string
; Output: EAX = value
; Note: minimal numeric evaluator: try integer literal, else variable lookup.
;==============================================================================
EvaluateExpression PROC
    push ebx
    push ecx
    push edx
    push edi
    
    mov eax, esi
    push eax
    call StringToInt
    pop eax
    jnc EVAL_IS_NUMBER
    
    ; Try as variable: ESI already points to token string
    call FindVariable       ; returns index or -1 in EAX
    cmp eax, -1
    jne EVAL_IS_VAR
    
    xor eax, eax
    jmp EVAL_EXIT
    
EVAL_IS_NUMBER:
    jmp EVAL_EXIT
    
EVAL_IS_VAR:
    mov ecx, eax
    mov eax, varValues[ecx * 4]
    
EVAL_EXIT:
    pop edi
    pop edx
    pop ecx
    pop ebx
    ret
EvaluateExpression ENDP

;==============================================================================
; StringToInt: String to integer
; Input: EAX = string pointer
; Output: EAX = value, CF clear if valid
;==============================================================================
StringToInt PROC
    push ebx
    push ecx
    push edx
    push esi
    
    mov esi, eax
    xor eax, eax
    
STI_LOOP:
    mov cl, BYTE PTR [esi]
    
    cmp cl, 0
    je STI_DONE
    
    cmp cl, '0'
    jl STI_INVALID
    
    cmp cl, '9'
    jg STI_INVALID
    
    imul eax, eax, 10
    sub cl, '0'
    movzx ecx, cl
    add eax, ecx
    
    inc esi
    jmp STI_LOOP
    
STI_DONE:
    clc
    jmp STI_EXIT
    
STI_INVALID:
    stc
    
STI_EXIT:
    pop esi
    pop edx
    pop ecx
    pop ebx
    ret
StringToInt ENDP

;==============================================================================
; CompareStringsCase: Compare strings (case-insensitive)
; Stack: [ebp+12]=str1_ptr, [ebp+8]=str2_ptr
; Output: EAX = 1 if equal, 0 if not
;==============================================================================
CompareStringsCase PROC
    push ebp
    mov ebp, esp
    push esi
    push edi
    push ecx
    push edx
    
    mov esi, [ebp + 12]
    mov edi, [ebp + 8]
    
COMP_LOOP:
    movzx eax, BYTE PTR [esi]
    movzx edx, BYTE PTR [edi]
    
    call ToLower_AL
    mov cl, al
    
    mov eax, edx
    call ToLower_AL
    mov dl, al
    
    cmp cl, dl
    jne COMP_NOT_EQUAL
    
    cmp cl, 0
    je COMP_EQUAL
    
    inc esi
    inc edi
    jmp COMP_LOOP
    
COMP_EQUAL:
    mov eax, 1
    jmp COMP_EXIT
    
COMP_NOT_EQUAL:
    xor eax, eax
    
COMP_EXIT:
    pop edx
    pop ecx
    pop edi
    pop esi
    pop ebp
    ret 8      ; Clean up 2 parameters (8 bytes)
CompareStringsCase ENDP

;==============================================================================
; ToLower_AL: Convert AL to lowercase
;==============================================================================
ToLower_AL PROC
    cmp al, 'A'
    jl TOLOWER_EXIT
    
    cmp al, 'Z'
    jg TOLOWER_EXIT
    
    add al, 32
    
TOLOWER_EXIT:
    ret
ToLower_AL ENDP

END main
