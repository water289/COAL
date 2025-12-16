INCLUDE ..\include\Irvine32.inc

; Constants
MAX_INPUT       EQU 128
MAX_TOKENS      EQU 16
MAX_TOKEN_LEN   EQU 64
MAX_VARS        EQU 64
MAX_VAR_NAME    EQU 20
MAX_STR_VAL     EQU 64

.data
    ; Messages
    welcomeMsg  BYTE "========================================",0dh,0ah
                BYTE " Human Language Scripting Interpreter v2.0",0dh,0ah
                BYTE " Number of runnable commands: 13",0dh,0ah
                BYTE " Type 'help' for commands",0dh,0ah
                BYTE " Type 'exit' to quit",0dh,0ah
                BYTE "========================================",0dh,0ah,0
    
    prompt      BYTE ">>> ",0
    goodbyeMsg  BYTE "Goodbye!",0
    
    ; Buffers
    inputBuffer BYTE MAX_INPUT DUP(0)
    tokens      BYTE MAX_TOKENS * MAX_TOKEN_LEN DUP(0)
    tokenCount  DWORD 0
    
    ; Variable storage - numbers
    varNames    BYTE MAX_VARS * MAX_VAR_NAME DUP(0)
    varValues   SDWORD MAX_VARS DUP(0)
    
    ; Variable storage - strings
    varStrings  BYTE MAX_VARS * MAX_STR_VAL DUP(0)
    varIsString BYTE MAX_VARS DUP(0)  ; 1 = string, 0 = number
    
    varCount    DWORD 0
    exitFlag    BYTE 0
    
    ; Error messages
    errMsg      BYTE "Error: ",0
    varNotFound BYTE "Variable not found",0
    divZeroMsg  BYTE "Error: Division by zero",0
    syntaxErr   BYTE "Syntax error",0
    unknownCmd  BYTE "Unknown command",0
    
    ; Help text
    helpMsg     BYTE "Commands:",0dh,0ah
                BYTE "  print <text>               - Display text or variable",0dh,0ah
                BYTE "  output <expr>              - Display expression result",0dh,0ah
                BYTE "  add <expr> and <expr>      - Add two values",0dh,0ah
                BYTE "  subtract <expr> from <expr> - Subtract",0dh,0ah
                BYTE "  multiply <expr> and <expr>  - Multiply",0dh,0ah
                BYTE "  divide <expr> by <expr>    - Divide",0dh,0ah
                BYTE "  store <expr> in <var>      - Assign variable",0dh,0ah
                BYTE "  show <var>                 - Display variable",0dh,0ah
                BYTE "  add 1 to <var>             - Increment",0dh,0ah
                BYTE "  subtract 1 from <var>      - Decrement",0dh,0ah
                BYTE "  clear                      - Clear screen",0dh,0ah
                BYTE "  help                       - Show this help",0dh,0ah
                BYTE "  exit / quit                - Exit interpreter",0dh,0ah,0
    
    space       BYTE " ",0
    equals      BYTE " = ",0
    quotientMsg BYTE "Quotient: ",0
    remainderMsg BYTE "Remainder: ",0
    
    ; Command keywords
    cmd_print   BYTE "print",0
    cmd_output  BYTE "output",0
    cmd_add     BYTE "add",0
    cmd_subtract BYTE "subtract",0
    cmd_multiply BYTE "multiply",0
    cmd_divide  BYTE "divide",0
    cmd_store   BYTE "store",0
    cmd_show    BYTE "show",0
    cmd_help    BYTE "help",0
    cmd_clear   BYTE "clear",0
    cmd_exit    BYTE "exit",0
    cmd_quit    BYTE "quit",0
    tok_1       BYTE "1",0
    tok_to      BYTE "to",0
    tok_and     BYTE "and",0
    tok_from    BYTE "from",0
    tok_by      BYTE "by",0
    tok_in      BYTE "in",0

.code

main PROC
    call Clrscr
    mov  edx, OFFSET welcomeMsg
    call WriteString
    call Crlf
    
mainLoop:
    cmp  exitFlag, 0
    jne  exitProgram
    
    mov  edx, OFFSET prompt
    call WriteString
    
    mov  edx, OFFSET inputBuffer
    mov  ecx, MAX_INPUT - 1
    call ReadString
    
    cmp  eax, 0
    je   mainLoop
    
    mov  esi, OFFSET inputBuffer
    mov  al, BYTE PTR [esi]
    cmp  al, '#'
    je   mainLoop
    cmp  al, 0
    je   mainLoop
    
    call Tokenize
    mov  tokenCount, eax
    
    cmp  eax, 0
    je   mainLoop
    
    call ExecuteCommand
    jmp  mainLoop

exitProgram:
    call Crlf
    mov  edx, OFFSET goodbyeMsg
    call WriteString
    call Crlf
    exit
main ENDP

; Tokenize - Split input into tokens
Tokenize PROC
    push ebx
    push esi
    push edi
    
    lea  esi, inputBuffer
    lea  edi, tokens
    mov  ebx, 0
    
tokenLoop:
    mov  al, BYTE PTR [esi]
    cmp  al, 0
    je   tokDone
    
    cmp  al, ' '
    je   skipChar
    cmp  al, 9
    je   skipChar
    cmp  al, ','
    je   skipChar
    cmp  al, '{'
    je   skipChar
    cmp  al, '}'
    je   skipChar
    cmp  al, '('
    je   skipChar
    cmp  al, ')'
    je   skipChar
    cmp  al, ';'
    je   skipChar
    cmp  al, '+'
    je   skipChar
    cmp  al, '*'
    je   skipChar
    jmp  copyToken
    
skipChar:
    inc  esi
    jmp  tokenLoop
    
copyToken:
    cmp  ebx, MAX_TOKENS
    jge  tokDone
    
    mov  ecx, 0
copyChar:
    mov  al, BYTE PTR [esi]
    cmp  al, 0
    je   endToken
    cmp  al, ' '
    je   endToken
    cmp  al, 9
    je   endToken
    cmp  al, ','
    je   endToken
    cmp  al, '{'
    je   endToken
    cmp  al, '}'
    je   endToken
    cmp  al, '('
    je   endToken
    cmp  al, ')'
    je   endToken
    cmp  al, ';'
    je   endToken
    cmp  al, '#'
    je   tokDone
    cmp  al, '%'
    je   endToken
    cmp  al, '='
    je   endToken
    cmp  al, '+'
    je   endToken
    cmp  al, '*'
    je   endToken
    
    cmp  ecx, MAX_TOKEN_LEN - 1
    jge  skipC
    
    mov  BYTE PTR [edi + ecx], al
    inc  ecx
    
skipC:
    inc  esi
    jmp  copyChar
    
endToken:
    mov  BYTE PTR [edi + ecx], 0
    push esi
    push edi
    call ToLower
    pop  edi
    pop  esi
    
    add  edi, MAX_TOKEN_LEN
    inc  ebx
    jmp  tokenLoop
    
tokDone:
    mov  eax, ebx
    pop  edi
    pop  esi
    pop  ebx
    ret
Tokenize ENDP

; ExecuteCommand - Execute parsed command
ExecuteCommand PROC
    cmp  tokenCount, 0
    je   execDone
    
    ; Check "add 1 to" (increment)
    cmp  tokenCount, 4
    jge  checkIncrement
    jmp  checkDecrement
    
checkIncrement:
    call GetToken0
    mov  esi, eax
    mov  edi, OFFSET cmd_add
    call CompareStrings
    cmp  al, 1
    jne  checkDecrement
    
    call GetToken1
    mov  esi, eax
    mov  edi, OFFSET tok_1
    call CompareStrings
    cmp  al, 1
    jne  checkDecrement
    
    call GetToken2
    mov  esi, eax
    mov  edi, OFFSET tok_to
    call CompareStrings
    cmp  al, 1
    je   doIncrement
    
checkDecrement:
    cmp  tokenCount, 4
    jge  checkDecrementEx
    jmp  checkOtherCmds
    
checkDecrementEx:
    call GetToken0
    mov  esi, eax
    mov  edi, OFFSET cmd_subtract
    call CompareStrings
    cmp  al, 1
    jne  checkOtherCmds
    
    call GetToken1
    mov  esi, eax
    mov  edi, OFFSET tok_1
    call CompareStrings
    cmp  al, 1
    jne  checkOtherCmds
    
    call GetToken2
    mov  esi, eax
    mov  edi, OFFSET tok_from
    call CompareStrings
    cmp  al, 1
    je   doDecrement
    
checkOtherCmds:
    call GetToken0
    mov  esi, eax
    mov  edi, OFFSET cmd_print
    call CompareStrings
    cmp  al, 1
    je   doPrint
    
    call GetToken0
    mov  esi, eax
    mov  edi, OFFSET cmd_output
    call CompareStrings
    cmp  al, 1
    je   doOutput
    
    call GetToken0
    mov  esi, eax
    mov  edi, OFFSET cmd_add
    call CompareStrings
    cmp  al, 1
    je   doAdd
    
    call GetToken0
    mov  esi, eax
    mov  edi, OFFSET cmd_subtract
    call CompareStrings
    cmp  al, 1
    je   doSubtract
    
    call GetToken0
    mov  esi, eax
    mov  edi, OFFSET cmd_multiply
    call CompareStrings
    cmp  al, 1
    je   doMultiply
    
    call GetToken0
    mov  esi, eax
    mov  edi, OFFSET cmd_divide
    call CompareStrings
    cmp  al, 1
    je   doDivide
    
    call GetToken0
    mov  esi, eax
    mov  edi, OFFSET cmd_store
    call CompareStrings
    cmp  al, 1
    je   doStore
    
    call GetToken0
    mov  esi, eax
    mov  edi, OFFSET cmd_show
    call CompareStrings
    cmp  al, 1
    je   doShow
    
    call GetToken0
    mov  esi, eax
    mov  edi, OFFSET cmd_help
    call CompareStrings
    cmp  al, 1
    je   doHelp
    
    call GetToken0
    mov  esi, eax
    mov  edi, OFFSET cmd_clear
    call CompareStrings
    cmp  al, 1
    je   doClear
    
    call GetToken0
    mov  esi, eax
    mov  edi, OFFSET cmd_exit
    call CompareStrings
    cmp  al, 1
    je   doExit
    
    call GetToken0
    mov  esi, eax
    mov  edi, OFFSET cmd_quit
    call CompareStrings
    cmp  al, 1
    je   doExit
    
    mov  edx, OFFSET unknownCmd
    call WriteString
    call Crlf
    jmp  execDone

doPrint:
    cmp  tokenCount, 1
    jle  execDone
    
    call GetToken1
    call IsNumber
    cmp  al, 1
    je   printNum
    
    call GetToken1
    call FindVariable
    cmp  eax, -1
    je   printStr
    
    ; Print variable value
    mov  ecx, eax
    mov  bl, varIsString[ecx]
    cmp  bl, 1
    je   printStrVar
    
    mov  eax, varValues[ecx*4]
    call WriteInt
    call Crlf
    jmp  execDone
    
printStrVar:
    mov  eax, ecx
    imul eax, MAX_STR_VAL
    lea  esi, varStrings[eax]
    mov  edx, esi
    call WriteString
    call Crlf
    jmp  execDone

printNum:
    call GetToken1
    call StringToInt
    call WriteInt
    call Crlf
    jmp  execDone

printStr:
    mov  edx, eax
    call WriteString
    call Crlf
    jmp  execDone

doOutput:
    cmp  tokenCount, 2
    jl   execDone
    
    call GetToken1
    call EvaluateExpression
    call WriteInt
    call Crlf
    jmp  execDone

doAdd:
    cmp  tokenCount, 4
    jl   execDone
    
    call GetToken1
    call EvaluateExpression
    mov  ebx, eax
    
    call GetToken3
    call EvaluateExpression
    add  eax, ebx
    
    call WriteInt
    call Crlf
    jmp  execDone

doSubtract:
    cmp  tokenCount, 4
    jl   execDone
    
    call GetToken3
    call EvaluateExpression
    mov  ebx, eax
    
    call GetToken1
    call EvaluateExpression
    sub  eax, ebx
    
    call WriteInt
    call Crlf
    jmp  execDone

doMultiply:
    cmp  tokenCount, 4
    jl   execDone
    
    call GetToken1
    call EvaluateExpression
    mov  ebx, eax
    
    call GetToken3
    call EvaluateExpression
    imul eax, ebx
    
    call WriteInt
    call Crlf
    jmp  execDone

doDivide:
    cmp  tokenCount, 4
    jl   execDone
    
    call GetToken3
    call EvaluateExpression
    cmp  eax, 0
    je   divZero
    
    mov  ebx, eax
    
    call GetToken1
    call EvaluateExpression
    
    cdq
    idiv ebx
    
    push edx
    
    mov  edx, OFFSET quotientMsg
    call WriteString
    call WriteInt
    call Crlf
    
    mov  edx, OFFSET remainderMsg
    call WriteString
    pop  eax
    call WriteInt
    call Crlf
    jmp  execDone

divZero:
    mov  edx, OFFSET divZeroMsg
    call WriteString
    call Crlf
    jmp  execDone

doStore:
    cmp  tokenCount, 4
    jl   execDone
    
    call GetToken1
    call EvaluateExpression
    mov  ebx, eax
    
    call GetToken3
    mov  edx, eax
    call StoreVariable
    jmp  execDone

doShow:
    cmp  tokenCount, 2
    jl   execDone
    
    call GetToken1
    mov  edx, eax
    call WriteString
    
    mov  edx, OFFSET equals
    call WriteString
    
    call GetToken1
    call FindVariable
    cmp  eax, -1
    je   varErr
    
    mov  ecx, eax
    mov  bl, varIsString[ecx]
    cmp  bl, 1
    je   showStrVar
    
    mov  eax, varValues[ecx*4]
    call WriteInt
    call Crlf
    jmp  execDone
    
showStrVar:
    mov  eax, ecx
    imul eax, MAX_STR_VAL
    lea  esi, varStrings[eax]
    mov  edx, esi
    call WriteString
    call Crlf
    jmp  execDone

varErr:
    mov  edx, OFFSET varNotFound
    call WriteString
    call Crlf
    jmp  execDone

doIncrement:
    call GetToken3
    call FindVariable
    cmp  eax, -1
    je   varErr
    
    inc  varValues[eax*4]
    jmp  execDone

doDecrement:
    call GetToken3
    call FindVariable
    cmp  eax, -1
    je   varErr
    
    dec  varValues[eax*4]
    jmp  execDone

doHelp:
    mov  edx, OFFSET helpMsg
    call WriteString
    jmp  execDone

doClear:
    call Clrscr
    jmp  execDone

doExit:
    mov  exitFlag, 1
    jmp  execDone

execDone:
    ret
ExecuteCommand ENDP

; Helper procedures

ToLower PROC
    push esi
    mov  esi, OFFSET tokens
    
lowerLoop:
    mov  al, BYTE PTR [esi]
    cmp  al, 0
    je   lowerDone
    
    cmp  al, 'A'
    jb   nextLower
    cmp  al, 'Z'
    ja   nextLower
    add  al, 32
    mov  BYTE PTR [esi], al
    
nextLower:
    inc  esi
    jmp  lowerLoop
    
lowerDone:
    pop  esi
    ret
ToLower ENDP

CompareStrings PROC
    ; esi = str1, edi = str2
    ; returns al = 1 if equal, 0 if not
    push esi
    push edi
    
cmpLoop:
    mov  al, BYTE PTR [esi]
    mov  bl, BYTE PTR [edi]
    
    cmp  al, bl
    jne  notEqual
    
    cmp  al, 0
    je   isEqual
    
    inc  esi
    inc  edi
    jmp  cmpLoop
    
isEqual:
    mov  al, 1
    jmp  cmpDone
    
notEqual:
    mov  al, 0
    
cmpDone:
    pop  edi
    pop  esi
    ret
CompareStrings ENDP

FindVariable PROC
    ; eax = varName pointer
    push esi
    push edi
    push ecx
    
    mov  ecx, varCount
    cmp  ecx, 0
    je   notFound
    
    mov  esi, 0
findLoop:
    push ecx
    mov  edi, MAX_VAR_NAME
    mul  esi
    lea  ecx, varNames[eax]
    
    mov  esi, ecx
    mov  edi, eax
    call CompareStrings
    cmp  al, 1
    je   found
    
    pop  ecx
    inc  esi
    loop findLoop
    
notFound:
    mov  eax, -1
    jmp  findDone
    
found:
    pop  ecx
    mov  eax, esi
    
findDone:
    pop  ecx
    pop  edi
    pop  esi
    ret
FindVariable ENDP

StoreVariable PROC
    ; edx = varName, ebx = value
    push esi
    push edi
    push ecx
    
    mov  eax, edx
    call FindVariable
    cmp  eax, -1
    jne  updateVar
    
    ; Create new variable
    mov  esi, varCount
    cmp  esi, MAX_VARS
    jge  storeDone
    
    mov  eax, MAX_VAR_NAME
    mul  esi
    lea  edi, varNames[eax]
    
    mov  esi, edx
    mov  ecx, MAX_VAR_NAME - 1
copyName:
    mov  al, BYTE PTR [esi]
    mov  BYTE PTR [edi], al
    cmp  al, 0
    je   nameDone
    inc  esi
    inc  edi
    loop copyName
    
nameDone:
    mov  BYTE PTR [edi], 0
    
    mov  esi, varCount
    mov  eax, ebx
    mov  varValues[esi*4], eax
    mov  varIsString[esi], 0  ; Number by default
    
    inc  varCount
    jmp  storeDone
    
updateVar:
    mov  esi, eax
    mov  varValues[esi*4], ebx
    mov  varIsString[esi], 0
    
storeDone:
    pop  ecx
    pop  edi
    pop  esi
    ret
StoreVariable ENDP

EvaluateExpression PROC
    ; eax = exprStr
    push esi
    
    mov  esi, eax
    
    call IsNumber
    cmp  al, 1
    je   isNum
    
    mov  eax, esi
    call FindVariable
    cmp  eax, -1
    je   evalZero
    
    mov  eax, varValues[eax*4]
    jmp  evalDone
    
isNum:
    mov  eax, esi
    call StringToInt
    jmp  evalDone
    
evalZero:
    mov  eax, 0
    
evalDone:
    pop  esi
    ret
EvaluateExpression ENDP

IsNumber PROC
    ; eax = strPtr
    push esi
    mov  esi, eax
    
    mov  al, BYTE PTR [esi]
    cmp  al, '-'
    je   skipSign
    cmp  al, '+'
    je   skipSign
    jmp  checkDigit
    
skipSign:
    inc  esi
    
checkDigit:
    mov  al, BYTE PTR [esi]
    cmp  al, 0
    je   notNum
    cmp  al, '0'
    jb   notNum
    cmp  al, '9'
    ja   notNum
    
    mov  al, 1
    jmp  isNumDone
    
notNum:
    mov  al, 0
    
isNumDone:
    pop  esi
    ret
IsNumber ENDP

StringToInt PROC
    ; eax = strPtr
    push esi
    push ebx
    push ecx
    
    mov  esi, eax
    mov  eax, 0
    mov  ebx, 10
    mov  ecx, 0
    
    mov  dl, BYTE PTR [esi]
    cmp  dl, '-'
    jne  parseDigits
    mov  cl, 1
    inc  esi
    
parseDigits:
    mov  dl, BYTE PTR [esi]
    cmp  dl, 0
    je   parseDone
    cmp  dl, '0'
    jb   parseDone
    cmp  dl, '9'
    ja   parseDone
    
    imul eax, ebx
    sub  dl, '0'
    movzx edx, dl
    add  eax, edx
    
    inc  esi
    jmp  parseDigits
    
parseDone:
    cmp  ecx, 1
    jne  positive
    neg  eax
    
positive:
    pop  ecx
    pop  ebx
    pop  esi
    ret
StringToInt ENDP

GetToken0 PROC
    lea  eax, tokens
    ret
GetToken0 ENDP

GetToken1 PROC
    lea  eax, tokens[MAX_TOKEN_LEN]
    ret
GetToken1 ENDP

GetToken2 PROC
    lea  eax, tokens[MAX_TOKEN_LEN*2]
    ret
GetToken2 ENDP

GetToken3 PROC
    lea  eax, tokens[MAX_TOKEN_LEN*3]
    ret
GetToken3 ENDP

END main
