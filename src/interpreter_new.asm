.386
.model flat, stdcall
option casemap:none

INCLUDE ..\include\Irvine32.inc

MAX_INPUT       EQU 256
MAX_TOKENS      EQU 32
MAX_TOKEN_LEN   EQU 32
MAX_VARS        EQU 64
MAX_VAR_NAME    EQU 20
MAX_BLOCK_LINES EQU 128

.data
    welcomeMsg  BYTE "========================================",0dh,0ah
                BYTE " Human Language Scripting Interpreter v2.0",0dh,0ah
                BYTE " Number of runnable commands: 15",0dh,0ah
                BYTE " Type 'help' for commands",0dh,0ah
                BYTE " Type 'exit' to quit",0dh,0ah
                BYTE "========================================",0dh,0ah,0

    prompt      BYTE ">>> ",0
    scriptPrompt BYTE "SCRIPT> ",0
    goodbyeMsg  BYTE "Goodbye!",0

    inputBuffer BYTE MAX_INPUT DUP(0)
    tokens      BYTE MAX_TOKENS * MAX_TOKEN_LEN DUP(0)
    tokenCount  DWORD 0

    ; Variable storage
    varNames    BYTE MAX_VARS * MAX_VAR_NAME DUP(0)
    varValues   SDWORD MAX_VARS DUP(0)
    varCount    DWORD 0

    exitFlag    BYTE 0
    signFlag    BYTE 0

    ; Block buffer
    blockLines  BYTE MAX_BLOCK_LINES * MAX_INPUT DUP(0)

    ; Text messages
    errUnknown  BYTE "Unknown command",0
    errVar      BYTE "Variable not found: ",0
    errDivZero  BYTE "Division by zero",0
    errSyntax   BYTE "Syntax error",0

    equalsText  BYTE " = ",0
    quotientMsg BYTE "Quotient: ",0
    remainderMsg BYTE "Remainder: ",0

    ; Trace helpers
    traceStart  BYTE "[TRACE] ProcessTokens enter",0
    traceCmd    BYTE "[TRACE] command: ",0
    traceExit   BYTE "[TRACE] ProcessTokens exit",0
    traceTokCnt BYTE "[TRACE] tokenCount=",0
    traceEsBeg  BYTE "[TRACE] EvalExpr start=",0
    traceEsEnd  BYTE "[TRACE] EvalExpr end",0
    traceStepPfx BYTE "[TRACE] step=",0
    traceCounter DWORD 0

    helpText    BYTE "Commands:",0dh,0ah
                BYTE "  print <text|var|expr>      - Display text or value",0dh,0ah
                BYTE "  output <expr>              - Display expression result",0dh,0ah
                BYTE "  add <expr> and <expr>      - Add",0dh,0ah
                BYTE "  subtract <expr> from <expr>- Subtract",0dh,0ah
                BYTE "  multiply <expr> and <expr> - Multiply",0dh,0ah
                BYTE "  divide <expr> by <expr>    - Divide",0dh,0ah
                BYTE "  store <expr> in <var>      - Assign",0dh,0ah
                BYTE "  show <var>                 - Show variable",0dh,0ah
                BYTE "  add 1 to <var>             - Increment",0dh,0ah
                BYTE "  subtract 1 from <var>      - Decrement",0dh,0ah
                BYTE "  script                     - Enter script mode",0dh,0ah
                BYTE "  loop <n> times ... endloop - Loop block",0dh,0ah
                BYTE "  if <cond> ... endif        - Conditional block",0dh,0ah
                BYTE "  clear                      - Clear screen",0dh,0ah
                BYTE "  help                       - This help",0dh,0ah
                BYTE "  exit / quit                - Exit interpreter",0dh,0ah,0

    ; Command keywords (lowercase)
    kw_print    BYTE "print",0
    kw_output   BYTE "output",0
    kw_add      BYTE "add",0
    kw_subtract BYTE "subtract",0
    kw_multiply BYTE "multiply",0
    kw_divide   BYTE "divide",0
    kw_store    BYTE "store",0
    kw_show     BYTE "show",0
    kw_help     BYTE "help",0
    kw_clear    BYTE "clear",0
    kw_exit     BYTE "exit",0
    kw_quit     BYTE "quit",0
    kw_script   BYTE "script",0
    kw_loop     BYTE "loop",0
    kw_if       BYTE "if",0
    kw_endloop  BYTE "endloop",0
    kw_endif    BYTE "endif",0

    tok_times   BYTE "times",0
    tok_to      BYTE "to",0
    tok_from    BYTE "from",0
    tok_in      BYTE "in",0
    tok_by      BYTE "by",0
    tok_and     BYTE "and",0
    oneLit      BYTE "1",0

    tok_plus    BYTE "+",0
    tok_minus   BYTE "-",0
    tok_mul     BYTE "*",0
    tok_div     BYTE "/",0
    tok_mod     BYTE "%",0

    cmp_eq      BYTE "=",0
    cmp_equals  BYTE "equals",0
    cmp_noteq   BYTE "!=",0
    cmp_neq     BYTE "notequals",0
    cmp_gt      BYTE ">",0
    cmp_lt      BYTE "<",0
    cmp_ge      BYTE ">=",0
    cmp_le      BYTE "<=",0

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
    mov  ecx, MAX_INPUT-1
    call ReadString
    cmp  eax, 0
    je   mainLoop

    ; strip trailing CR/LF
    lea  esi, inputBuffer
    add  esi, eax
    dec  esi
    mov  al, [esi]
    cmp  al, 0Ah
    jne  noTrim
    mov  BYTE PTR [esi], 0
    dec  esi
    mov  al, [esi]
    cmp  al, 0Dh
    jne  noTrim
    mov  BYTE PTR [esi], 0
noTrim:
    call StripComment
    call TokenizeLine
    cmp  tokenCount, 0
    je   mainLoop
    call ProcessTokens
    jmp  mainLoop

exitProgram:
    call Crlf
    mov  edx, OFFSET goodbyeMsg
    call WriteString
    call Crlf
    exit
main ENDP

; ------------------------------------------------------------
; Basic helpers
; ------------------------------------------------------------

StripComment PROC
    push esi
    lea  esi, inputBuffer
scLoop:
    mov  al, [esi]
    cmp  al, 0
    je   scDone
    cmp  al, '#'
    je   scZap
    inc  esi
    jmp  scLoop
scZap:
    mov  BYTE PTR [esi], 0
scDone:
    pop  esi
    ret
StripComment ENDP

ToLowerInPlace PROC
    push esi
    mov  esi, [esp+8]
lowLp:
    mov  al, [esi]
    cmp  al, 0
    je   lowDone
    cmp  al, 'A'
    jb   lowNext
    cmp  al, 'Z'
    ja   lowNext
    or   al, 20h
    mov  [esi], al
lowNext:
    inc  esi
    jmp  lowLp
lowDone:
    pop  esi
    ret
ToLowerInPlace ENDP

StrEq PROC
    ; esi=str1, edi=str2
    push esi
    push edi
strCmp:
    mov  al, [esi]
    mov  bl, [edi]
    cmp  al, bl
    jne  strNe
    cmp  al, 0
    je   strOk
    inc  esi
    inc  edi
    jmp  strCmp
strOk:
    mov  al, 1
    jmp  strExit
strNe:
    mov  al, 0
strExit:
    pop  edi
    pop  esi
    ret
StrEq ENDP

; ------------------------------------------------------------
; Tokenization
; ------------------------------------------------------------

TokenizeLine PROC
    push ebx
    push esi
    push edi
    push ecx
    push edx

    lea  esi, inputBuffer
    lea  edi, tokens
    mov  ebx, 0            ; token count
    mov  cl, 1             ; lastWasDelim

nextChar:
    mov  al, [esi]
    cmp  al, 0
    je   tokDone

    cmp  al, ' '
    je   skipWs
    cmp  al, 9
    je   skipWs

    cmp  ebx, MAX_TOKENS
    jge  tokDone

    cmp  al, '+'
    je   checkPlus
    cmp  al, '-'
    je   checkMinus
    cmp  al, '*'
    je   storeSingleOp
    cmp  al, '/'
    je   storeSingleOp
    cmp  al, '%'
    je   storeSingleOp
    cmp  al, '<'
    je   storeCmp
    cmp  al, '>'
    je   storeCmp
    cmp  al, '!'
    je   storeCmp
    cmp  al, '='
    je   storeCmp

    jmp  storeGeneral

checkPlus:
    cmp  cl, 1
    jne  storeSingleOp
    mov  dl, [esi+1]
    cmp  dl, '0'
    jb   storeSingleOp
    cmp  dl, '9'
    ja   storeSingleOp
    jmp  storeGeneral

checkMinus:
    cmp  cl, 1
    jne  storeSingleOp
    mov  dl, [esi+1]
    cmp  dl, '0'
    jb   storeSingleOp
    cmp  dl, '9'
    ja   storeSingleOp
    jmp  storeGeneral

storeSingleOp:
    mov  BYTE PTR [edi], al
    mov  BYTE PTR [edi+1], 0
    add  edi, MAX_TOKEN_LEN
    inc  ebx
    inc  esi
    mov  cl, 1
    jmp  nextChar

storeCmp:
    mov  BYTE PTR [edi], al
    mov  dl, [esi+1]
    cmp  dl, '='
    jne  cmpNoEq
    mov  BYTE PTR [edi+1], '='
    mov  BYTE PTR [edi+2], 0
    add  esi, 2
    jmp  cmpStored
cmpNoEq:
    mov  BYTE PTR [edi+1], 0
    inc  esi
cmpStored:
    add  edi, MAX_TOKEN_LEN
    inc  ebx
    mov  cl, 1
    jmp  nextChar

storeGeneral:
    mov  edx, 0
copyGen:
    cmp  edx, MAX_TOKEN_LEN-1
    jge  endGen
    mov  al, [esi]
    cmp  al, 0
    je   endGen
    cmp  al, ' '
    je   endGen
    cmp  al, 9
    je   endGen
    cmp  al, '#'
    je   endGen
    cmp  al, '+'
    je   endGen
    cmp  al, '-'
    je   endGen
    cmp  al, '*'
    je   endGen
    cmp  al, '/'
    je   endGen
    cmp  al, '%'
    je   endGen
    cmp  al, '<'
    je   endGen
    cmp  al, '>'
    je   endGen
    cmp  al, '!'
    je   endGen
    cmp  al, '='
    je   endGen
    cmp  al, '{'
    je   endGen
    cmp  al, '}'
    je   endGen
    cmp  al, ','
    je   endGen
    cmp  al, ';'
    je   endGen
    cmp  al, '('
    je   endGen
    cmp  al, ')'
    je   endGen

    cmp  al, 'A'
    jb   noLower
    cmp  al, 'Z'
    ja   noLower
    or   al, 20h
noLower:
    mov  BYTE PTR [edi+edx], al
    inc  edx
    inc  esi
    jmp  copyGen
endGen:
    mov  BYTE PTR [edi+edx], 0
    add  edi, MAX_TOKEN_LEN
    inc  ebx
    mov  cl, 0
    jmp  nextChar

skipWs:
    inc  esi
    mov  cl, 1
    jmp  nextChar

tokDone:
    mov  tokenCount, ebx
    pop  edx
    pop  ecx
    pop  edi
    pop  esi
    pop  ebx
    ret
TokenizeLine ENDP

; ------------------------------------------------------------
; Token access
; ------------------------------------------------------------

GetTokenPtr PROC
    push ebp
    mov  ebp, esp
    mov  eax, [ebp+8]
    mov  ecx, MAX_TOKEN_LEN
    xor  edx, edx        ; clear high dword before multiply to avoid overflow
    mul  ecx
    lea  eax, tokens[eax]
    pop  ebp
    ret 4
GetTokenPtr ENDP

GetToken0 PROC
    push 0
    call GetTokenPtr
    ret
GetToken0 ENDP
GetToken1 PROC
    push 1
    call GetTokenPtr
    ret
GetToken1 ENDP
GetToken2 PROC
    push 2
    call GetTokenPtr
    ret
GetToken2 ENDP
GetToken3 PROC
    push 3
    call GetTokenPtr
    ret
GetToken3 ENDP

; ------------------------------------------------------------
; Variable storage
; ------------------------------------------------------------

FindVariable PROC
    ; edx = name ptr
    push esi
    push edi
    push ecx
    mov  ecx, varCount
    cmp  ecx, 0
    je   fvNot
    mov  esi, 0
fvLoop:
    push ecx
    push esi
    mov  eax, MAX_VAR_NAME
    mul  esi
    lea  edi, varNames[eax]
    mov  esi, edx
    call StrEq
    pop  esi
    cmp  al, 1
    je   fvFound
    pop  ecx
    inc  esi
    cmp  esi, varCount
    jl   fvLoop
    jmp  fvNot
fvFound:
    pop  ecx
    mov  eax, esi
    jmp  fvDone
fvNot:
    mov  eax, -1
fvDone:
    pop  ecx
    pop  edi
    pop  esi
    ret
FindVariable ENDP

SetVariable PROC
    ; edx=name ptr, eax=value
    push ebx
    push ecx
    push esi
    push edi
    mov  ebx, eax
    mov  eax, edx
    call FindVariable
    cmp  eax, -1
    jne  updateVar
    cmp  varCount, MAX_VARS
    jge  setDone
    mov  esi, varCount
    mov  eax, MAX_VAR_NAME
    mul  esi
    lea  edi, varNames[eax]
    mov  ecx, MAX_VAR_NAME
copyNm:
    mov  al, BYTE PTR [edx]
    mov  BYTE PTR [edi], al
    cmp  al, 0
    je   nameDone
    inc  edx
    inc  edi
    dec  ecx
    cmp  ecx, 0
    jne  copyNm
nameDone:
    mov  eax, ebx
    mov  varValues[esi*4], eax
    inc  varCount
    jmp  setDone
updateVar:
    mov  varValues[eax*4], ebx
setDone:
    pop  edi
    pop  esi
    pop  ecx
    pop  ebx
    ret
SetVariable ENDP

; ------------------------------------------------------------
; Numeric helpers
; ------------------------------------------------------------

IsNumberStr PROC
    ; eax = ptr, return al=1 yes
    push esi
    mov  esi, eax
    mov  al, [esi]
    cmp  al, '+'
    je   skipSign
    cmp  al, '-'
    jne  checkDigit
skipSign:
    inc  esi
checkDigit:
    mov  al, [esi]
    cmp  al, 0
    je   notNum
    cmp  al, '0'
    jb   notNum
    cmp  al, '9'
    ja   notNum
    mov  al, 1
    pop  esi
    ret
notNum:
    mov  al, 0
    pop  esi
    ret
IsNumberStr ENDP

StringToInt PROC
    ; eax=ptr -> eax=value
    push esi
    push ebx
    mov  esi, eax
    xor  eax, eax
    mov  ebx, 10
    mov  cl, 0
    mov  dl, [esi]
    cmp  dl, '-'
    jne  stParse
    mov  cl, 1
    inc  esi
stParse:
    mov  dl, [esi]
    cmp  dl, 0
    je   stDone
    cmp  dl, '0'
    jb   stDone
    cmp  dl, '9'
    ja   stDone
    imul eax, ebx
    sub  dl, '0'
    movzx edx, dl
    add  eax, edx
    inc  esi
    jmp  stParse
stDone:
    cmp  cl, 1
    jne  stExit
    neg  eax
stExit:
    pop  ebx
    pop  esi
    ret
StringToInt ENDP

; ------------------------------------------------------------
; Expression evaluation
; ------------------------------------------------------------

EvalAtomAtIndex PROC
    ; param: index (DWORD)
    push ebp
    mov  ebp, esp
    push esi
    push edi
    mov  esi, [ebp+8]
    push esi
    call GetTokenPtr
    mov  edi, eax        ; token ptr
    ; number?
    mov  eax, edi
    call IsNumberStr
    cmp  al, 1
    jne  checkAtomVar
    mov  eax, edi
    call StringToInt
    mov  edx, 1
    jmp  atomDone
checkAtomVar:
    mov  edx, edi
    call FindVariable
    cmp  eax, -1
    je   atomFail
    mov  eax, varValues[eax*4]
    mov  edx, 1
    jmp  atomDone
atomFail:
    mov  eax, 0
    mov  edx, 0
atomDone:
    pop  edi
    pop  esi
    pop  ebp
    ret 4
EvalAtomAtIndex ENDP

EvaluateSimpleExpression PROC
    ; parameters: startIndex (DWORD), endIndexExclusive (DWORD)
    ; returns eax=result, edx=1 success, edx=0 fail
    push ebp
    mov  ebp, esp
    push ebx
    push esi
    push edi
    push ecx

    mov  esi, [ebp+8]
    mov  edi, [ebp+12]
    cmp  esi, edi
    jge  esFail

    push esi
    call EvalAtomAtIndex
    add  esp, 4
    cmp  edx, 1
    jne  esFail
    mov  ecx, eax        ; current multiplicative value
    mov  ebx, 0          ; additive accumulator
    mov  signFlag, 0     ; 0=plus,1=minus
    inc  esi

esLoop:
    mov  edx, [ebp+12]
    cmp  esi, edx
    jge  esFinishAdd
    push esi
    call GetTokenPtr
    push eax
    push esi

    mov  esi, eax
    mov  edi, OFFSET tok_mul
    call StrEq
    cmp  al, 1
    je   esLoopMul
    pop  esi
    push esi
    mov  esi, [esp+4]
    mov  edi, OFFSET tok_div
    call StrEq
    cmp  al, 1
    je   esLoopDiv
    pop  esi
    push esi
    mov  esi, [esp+4]
    mov  edi, OFFSET tok_mod
    call StrEq
    cmp  al, 1
    je   esLoopMod

    pop  esi
    push esi
    mov  esi, [esp+4]
    mov  edi, OFFSET tok_plus
    call StrEq
    cmp  al, 1
    je   esLoopPlus
    pop  esi
    push esi
    mov  esi, [esp+4]
    mov  edi, OFFSET tok_minus
    call StrEq
    cmp  al, 1
    je   esLoopMinus

    pop  esi
    add  esp, 4
    jmp  esFail

esLoopMul:
    pop  esi
    add  esp, 4
    jmp  esMul
esLoopDiv:
    pop  esi
    add  esp, 4
    jmp  esDiv
esLoopMod:
    pop  esi
    add  esp, 4
    jmp  esMod
esLoopPlus:
    pop  esi
    add  esp, 4
    jmp  esPlus
esLoopMinus:
    pop  esi
    add  esp, 4
    jmp  esMinus

esPlus:
    cmp  signFlag, 0
    jne  esPlusSub
    add  ebx, ecx
    mov  signFlag, 0
    jmp  esLoadAdd
esPlusSub:
    sub  ebx, ecx
    mov  signFlag, 0
    jmp  esLoadAdd

esMinus:
    cmp  signFlag, 0
    jne  esMinusSub
    add  ebx, ecx
    mov  signFlag, 1
    jmp  esLoadAdd
esMinusSub:
    sub  ebx, ecx
    mov  signFlag, 1
    jmp  esLoadAdd

esLoadAdd:
    inc  esi
    push esi
    call EvalAtomAtIndex
    add  esp, 4
    cmp  edx, 1
    jne  esFail
    mov  ecx, eax
    inc  esi
    jmp  esLoop

esMul:
    inc  esi
    push esi
    call EvalAtomAtIndex
    add  esp, 4
    cmp  edx, 1
    jne  esFail
    imul ecx, eax
    inc  esi
    jmp  esLoop

esDiv:
    inc  esi
    push esi
    call EvalAtomAtIndex
    add  esp, 4
    cmp  edx, 1
    jne  esFail
    cmp  eax, 0
    je   esFail
    mov  edx, eax        ; divisor
    mov  eax, ecx
    cdq
    idiv edx
    mov  ecx, eax
    inc  esi
    jmp  esLoop

esMod:
    inc  esi
    push esi
    call EvalAtomAtIndex
    add  esp, 4
    cmp  edx, 1
    jne  esFail
    cmp  eax, 0
    je   esFail
    mov  edx, eax
    mov  eax, ecx
    cdq
    idiv edx
    mov  ecx, edx
    inc  esi
    jmp  esLoop

esFinishAdd:
    cmp  signFlag, 0
    jne  esDoSub
    add  ebx, ecx
    jmp  esOk
esDoSub:
    sub  ebx, ecx
esOk:
    mov  eax, ebx
    mov  edx, 1
    jmp  esExit

esFail:
    mov  eax, 0
    mov  edx, 0

esExit:
    pop  ecx
    pop  edi
    pop  esi
    pop  ebx
    pop  ebp
    ret 8
EvaluateSimpleExpression ENDP

; ------------------------------------------------------------
; Conditions
; ------------------------------------------------------------

EvalConditionFrom PROC
    ; param: start index
    push ebp
    mov  ebp, esp
    push esi
    push edi
    push ebx
    mov  esi, [ebp+8]
    mov  ebx, esi
    mov  edi, tokenCount
    mov  ah, 0           ; found flag
    mov  al, 0           ; op code

findOp:
    cmp  ebx, edi
    jge  condFail
    push ebx
    call GetTokenPtr
    mov  edx, eax
    pop  ebx
    mov  esi, edx
    mov  edi, OFFSET cmp_eq
    call StrEq
    cmp  al, 1
    je   opEq
    mov  esi, edx
    mov  edi, OFFSET cmp_equals
    call StrEq
    cmp  al, 1
    je   opEq
    mov  esi, edx
    mov  edi, OFFSET cmp_noteq
    call StrEq
    cmp  al, 1
    je   opNe
    mov  esi, edx
    mov  edi, OFFSET cmp_neq
    call StrEq
    cmp  al, 1
    je   opNe
    mov  esi, edx
    mov  edi, OFFSET cmp_gt
    call StrEq
    cmp  al, 1
    je   opGt
    mov  esi, edx
    mov  edi, OFFSET cmp_ge
    call StrEq
    cmp  al, 1
    je   opGe
    mov  esi, edx
    mov  edi, OFFSET cmp_lt
    call StrEq
    cmp  al, 1
    je   opLt
    mov  esi, edx
    mov  edi, OFFSET cmp_le
    call StrEq
    cmp  al, 1
    je   opLe
    inc  ebx
    jmp  findOp

opEq: mov ah,1
    mov al,0
    jmp opFound
opNe: mov ah,1
    mov al,1
    jmp opFound
opGt: mov ah,1
    mov al,2
    jmp opFound
opLt: mov ah,1
    mov al,3
    jmp opFound
opGe: mov ah,1
    mov al,4
    jmp opFound
opLe: mov ah,1
    mov al,5
    jmp opFound

opFound:
    cmp  ah, 1
    jne  condFail
    mov  edx, ebx        ; operator index
    mov  cl, al          ; preserve operator code
    push edx             ; end for left
    push [ebp+8]         ; start for left
    call EvaluateSimpleExpression
    add  esp, 8
    cmp  edx, 1
    jne  condFail
    mov  esi, eax        ; left
    mov  ecx, ebx
    inc  ecx
    push tokenCount      ; end for right
    push ecx             ; start for right
    call EvaluateSimpleExpression
    add  esp, 8
    cmp  edx, 1
    jne  condFail
    mov  ebx, eax        ; right

    cmp  cl, 0
    je   doEq
    cmp  cl, 1
    je   doNe
    cmp  cl, 2
    je   doGt
    cmp  cl, 3
    je   doLt
    cmp  cl, 4
    je   doGe
    cmp  cl, 5
    je   doLe
    jmp  condFail

doEq: cmp  esi, ebx
    sete al
    movzx eax, al
    jmp  condExit

doNe: cmp  esi, ebx
    setne al
    movzx eax, al
    jmp  condExit

doGt: cmp  esi, ebx
    setg al
    movzx eax, al
    jmp  condExit

doLt: cmp  esi, ebx
    setl al
    movzx eax, al
    jmp  condExit

doGe: cmp  esi, ebx
    setge al
    movzx eax, al
    jmp  condExit

doLe: cmp  esi, ebx
    setle al
    movzx eax, al
    jmp  condExit

condFail:
    mov  eax, 0
condExit:
    pop  ebx
    pop  edi
    pop  esi
    pop  ebp
    ret 4
EvalConditionFrom ENDP

; ------------------------------------------------------------
; Token search helpers
; ------------------------------------------------------------

FindTokenIndexAnd PROC
    push ebx
    mov  ebx, 1
ftAndLoop:
    cmp  ebx, tokenCount
    jge  ftAndMiss
    push ebx
    call GetTokenPtr
    pop  ebx
    mov  esi, eax
    mov  edi, OFFSET tok_and
    call StrEq
    cmp  al, 1
    je   ftAndHit
    inc  ebx
    jmp  ftAndLoop
ftAndHit:
    mov  eax, ebx
    pop  ebx
    ret
ftAndMiss:
    mov  eax, 0
    pop  ebx
    ret
FindTokenIndexAnd ENDP

FindTokenIndexBy PROC
    push ebx
    mov  ebx, 1
ftBy:
    cmp  ebx, tokenCount
    jge  ftByMiss
    push ebx
    call GetTokenPtr
    pop  ebx
    mov  esi, eax
    mov  edi, OFFSET tok_by
    call StrEq
    cmp  al, 1
    je   ftByHit
    inc  ebx
    jmp  ftBy
ftByHit:
    mov  eax, ebx
    pop  ebx
    ret
ftByMiss:
    mov  eax, 0
    pop  ebx
    ret
FindTokenIndexBy ENDP

FindTokenIndexFrom PROC
    push ebx
    mov  ebx, 1
ftFrom:
    cmp  ebx, tokenCount
    jge  ftFromMiss
    push ebx
    call GetTokenPtr
    pop  ebx
    mov  esi, eax
    mov  edi, OFFSET tok_from
    call StrEq
    cmp  al, 1
    je   ftFromHit
    inc  ebx
    jmp  ftFrom
ftFromHit:
    mov  eax, ebx
    pop  ebx
    ret
ftFromMiss:
    mov  eax, 0
    pop  ebx
    ret
FindTokenIndexFrom ENDP

FindTokenIndexIn PROC
    push ebx
    mov  ebx, 1
ftIn:
    cmp  ebx, tokenCount
    jge  ftInMiss
    push ebx
    call GetTokenPtr
    pop  ebx
    mov  esi, eax
    mov  edi, OFFSET tok_in
    call StrEq
    cmp  al, 1
    je   ftInHit
    inc  ebx
    jmp  ftIn
ftInHit:
    mov  eax, ebx
    pop  ebx
    ret
ftInMiss:
    mov  eax, 0
    pop  ebx
    ret
FindTokenIndexIn ENDP

FindTokenIndexTimes PROC
    push ebx
    mov  ebx, 1
ftTimes:
    cmp  ebx, tokenCount
    jge  ftTimesMiss
    push ebx
    call GetTokenPtr
    pop  ebx
    mov  esi, eax
    mov  edi, OFFSET tok_times
    call StrEq
    cmp  al, 1
    je   ftTimesHit
    inc  ebx
    jmp  ftTimes
ftTimesHit:
    mov  eax, ebx
    pop  ebx
    ret
ftTimesMiss:
    mov  eax, 0
    pop  ebx
    ret
FindTokenIndexTimes ENDP

; ------------------------------------------------------------
; Command dispatcher
; ------------------------------------------------------------

ProcessTokens PROC
    push ebp
    mov  ebp, esp
    push ebx
    push esi
    push edi

    ; inline condition (token "if" not at start)
    cmp  tokenCount, 2
    jl   dispatch
    mov  ebx, 1
findInlineIf:
    cmp  ebx, tokenCount
    jge  dispatch
    push ebx
    call GetTokenPtr
    pop  ebx
    mov  esi, eax
    mov  edi, OFFSET kw_if
    call StrEq
    cmp  al, 1
    jne  noInline
    mov  eax, ebx
    inc  eax
    push eax
    call EvalConditionFrom
    add  esp, 4
    cmp  eax, 0
    je   doneProcess
    jmp  dispatch
noInline:
    inc  ebx
    jmp  findInlineIf

dispatch:
    call GetToken0
    mov  esi, eax
    mov  edi, OFFSET kw_print
    call StrEq
    cmp  al, 1
    je   doPrint

    call GetToken0
    mov  esi, eax
    mov  edi, OFFSET kw_output
    call StrEq
    cmp  al, 1
    je   doOutput

    call GetToken0
    mov  esi, eax
    mov  edi, OFFSET kw_add
    call StrEq
    cmp  al, 1
    je   doAdd

    call GetToken0
    mov  esi, eax
    mov  edi, OFFSET kw_subtract
    call StrEq
    cmp  al, 1
    je   doSubtract

    call GetToken0
    mov  esi, eax
    mov  edi, OFFSET kw_multiply
    call StrEq
    cmp  al, 1
    je   doMultiply

    call GetToken0
    mov  esi, eax
    mov  edi, OFFSET kw_divide
    call StrEq
    cmp  al, 1
    je   doDivide

    call GetToken0
    mov  esi, eax
    mov  edi, OFFSET kw_store
    call StrEq
    cmp  al, 1
    je   doStore

    call GetToken0
    mov  esi, eax
    mov  edi, OFFSET kw_show
    call StrEq
    cmp  al, 1
    je   doShow

    cmp  tokenCount, 4
    jl   checkDec
    call GetToken0
    mov  esi, eax
    mov  edi, OFFSET kw_add
    call StrEq
    cmp  al, 1
    jne  checkDec
    call GetToken1
    mov  esi, eax
    mov  edi, OFFSET oneLit
    call StrEq
    cmp  al, 1
    jne  checkDec
    call GetToken2
    mov  esi, eax
    mov  edi, OFFSET tok_to
    call StrEq
    cmp  al, 1
    jne  checkDec
    jmp  doIncrement

checkDec:
    cmp  tokenCount, 4
    jl   checkHelp
    call GetToken0
    mov  esi, eax
    mov  edi, OFFSET kw_subtract
    call StrEq
    cmp  al, 1
    jne  checkHelp
    call GetToken1
    mov  esi, eax
    mov  edi, OFFSET oneLit
    call StrEq
    cmp  al, 1
    jne  checkHelp
    call GetToken2
    mov  esi, eax
    mov  edi, OFFSET tok_from
    call StrEq
    cmp  al, 1
    jne  checkHelp
    jmp  doDecrement

checkHelp:
    call GetToken0
    mov  esi, eax
    mov  edi, OFFSET kw_help
    call StrEq
    cmp  al, 1
    je   doHelp

    call GetToken0
    mov  esi, eax
    mov  edi, OFFSET kw_clear
    call StrEq
    cmp  al, 1
    je   doClear

    call GetToken0
    mov  esi, eax
    mov  edi, OFFSET kw_exit
    call StrEq
    cmp  al, 1
    je   doExit
    call GetToken0
    mov  esi, eax
    mov  edi, OFFSET kw_quit
    call StrEq
    cmp  al, 1
    je   doExit

    call GetToken0
    mov  esi, eax
    mov  edi, OFFSET kw_script
    call StrEq
    cmp  al, 1
    je   doScript

    call GetToken0
    mov  esi, eax
    mov  edi, OFFSET kw_loop
    call StrEq
    cmp  al, 1
    je   doLoop

    call GetToken0
    mov  esi, eax
    mov  edi, OFFSET kw_if
    call StrEq
    cmp  al, 1
    je   doIfBlock

    mov  edx, OFFSET errUnknown
    call WriteString
    call Crlf
    jmp  doneProcess

; --- command handlers ---

doPrint:
    mov  eax, 1
    push tokenCount
    push eax
    call EvaluateSimpleExpression
    add  esp, 8
    cmp  edx, 1
    je   printValue
    mov  ebx, 1
printText:
    cmp  ebx, tokenCount
    jge  afterPrint
    push ebx
    call GetTokenPtr
    mov  edx, eax
    call WriteString
    inc  ebx
    cmp  ebx, tokenCount
    jge  afterPrint
    mov  dl, ' '
    call WriteChar
    jmp  printText
printValue:
    call WriteInt
afterPrint:
    call Crlf
    jmp  doneProcess

doOutput:
    mov  eax, 1
    push tokenCount
    push eax
    call EvaluateSimpleExpression
    add  esp, 8
    cmp  edx, 1
    jne  syntaxErr
    call WriteInt
    call Crlf
    jmp  doneProcess
syntaxErr:
    mov  edx, OFFSET errSyntax
    call WriteString
    call Crlf
    jmp  doneProcess

doAdd:
    call FindTokenIndexAnd
    mov  ebx, eax
    cmp  ebx, 0
    je   syntaxErr
    push ebx
    push 1
    call EvaluateSimpleExpression
    add  esp, 8
    cmp  edx, 1
    jne  syntaxErr
    mov  esi, eax
    mov  eax, ebx
    inc  eax
    push tokenCount
    push eax
    call EvaluateSimpleExpression
    add  esp, 8
    cmp  edx, 1
    jne  syntaxErr
    add  eax, esi
    call WriteInt
    call Crlf
    jmp  doneProcess

doSubtract:
    call FindTokenIndexFrom
    mov  ebx, eax
    cmp  ebx, 0
    je   syntaxErr
    push ebx
    push 1
    call EvaluateSimpleExpression
    add  esp, 8
    cmp  edx, 1
    jne  syntaxErr
    mov  esi, eax
    mov  eax, ebx
    inc  eax
    push tokenCount
    push eax
    call EvaluateSimpleExpression
    add  esp, 8
    cmp  edx, 1
    jne  syntaxErr
    sub  eax, esi
    call WriteInt
    call Crlf
    jmp  doneProcess

doMultiply:
    call FindTokenIndexAnd
    mov  ebx, eax
    cmp  ebx, 0
    je   syntaxErr
    push ebx
    push 1
    call EvaluateSimpleExpression
    add  esp, 8
    cmp  edx, 1
    jne  syntaxErr
    mov  esi, eax
    mov  eax, ebx
    inc  eax
    push tokenCount
    push eax
    call EvaluateSimpleExpression
    add  esp, 8
    cmp  edx, 1
    jne  syntaxErr
    imul eax, esi
    call WriteInt
    call Crlf
    jmp  doneProcess

doDivide:
    call FindTokenIndexBy
    mov  ebx, eax
    cmp  ebx, 0
    je   syntaxErr
    push ebx
    push 1
    call EvaluateSimpleExpression
    add  esp, 8
    cmp  edx, 1
    jne  syntaxErr
    mov  esi, eax        ; numerator
    mov  eax, ebx
    inc  eax
    push tokenCount
    push eax
    call EvaluateSimpleExpression
    add  esp, 8
    cmp  edx, 1
    jne  syntaxErr
    cmp  eax, 0
    je   divZero
    mov  ebx, eax
    mov  eax, esi
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
    jmp  doneProcess
divZero:
    mov  edx, OFFSET errDivZero
    call WriteString
    call Crlf
    jmp  doneProcess

doStore:
    call FindTokenIndexIn
    mov  ebx, eax
    cmp  ebx, 0
    je   syntaxErr
    mov  eax, ebx
    dec  eax
    push eax
    push 1
    call EvaluateSimpleExpression
    add  esp, 8
    cmp  edx, 1
    jne  syntaxErr
    mov  esi, eax
    mov  eax, ebx
    inc  eax
    push eax
    call GetTokenPtr
    mov  edx, eax
    mov  eax, esi
    call SetVariable
    jmp  doneProcess

doShow:
    cmp  tokenCount, 2
    jl   syntaxErr
    call GetToken1
    mov  edx, eax
    call FindVariable
    cmp  eax, -1
    je   showErr
    mov  ebx, eax
    call GetToken1
    mov  edx, eax
    call WriteString
    mov  edx, OFFSET equalsText
    call WriteString
    mov  eax, varValues[ebx*4]
    call WriteInt
    call Crlf
    jmp  doneProcess
showErr:
    mov  edx, OFFSET errVar
    call WriteString
    call GetToken1
    mov  edx, eax
    call WriteString
    call Crlf
    jmp  doneProcess

doIncrement:
    call GetToken3
    mov  edx, eax
    call FindVariable
    cmp  eax, -1
    je   showErr
    inc  varValues[eax*4]
    jmp  doneProcess

doDecrement:
    call GetToken3
    mov  edx, eax
    call FindVariable
    cmp  eax, -1
    je   showErr
    dec  varValues[eax*4]
    jmp  doneProcess

doHelp:
    mov  edx, OFFSET helpText
    call WriteString
    jmp  doneProcess

doClear:
    call Clrscr
    jmp  doneProcess

doExit:
    mov  exitFlag, 1
    jmp  doneProcess

doScript:
    call CaptureBlockUntilEnd
    jmp  doneProcess

doLoop:
    call HandleLoop
    jmp  doneProcess

doIfBlock:
    call HandleIf
    jmp  doneProcess

doneProcess:
    pop  edi
    pop  esi
    pop  ebx
    pop  ebp
    ret
ProcessTokens ENDP

; ------------------------------------------------------------
; Block capture and control flow
; ------------------------------------------------------------

CaptureBlockUntilEnd PROC
    push ebx
    push esi
    push edi
    mov  ebx, 0
    lea  edi, blockLines
capLoop:
    cmp  ebx, MAX_BLOCK_LINES
    jge  capDone
    mov  edx, OFFSET scriptPrompt
    call WriteString
    mov  edx, edi
    mov  ecx, MAX_INPUT-1
    call ReadString
    cmp  eax, 0
    je   capDone
    mov  esi, edi
    add  esi, eax
    dec  esi
    mov  al, [esi]
    cmp  al, 0Ah
    jne  capChk
    mov  BYTE PTR [esi], 0
    dec  esi
    mov  al, [esi]
    cmp  al, 0Dh
    jne  capChk
    mov  BYTE PTR [esi], 0
capChk:
    cmp  BYTE PTR [edi], 0
    je   capDone
    push edi
    call ToLowerInPlace
    pop  edi
    cmp  BYTE PTR [edi], 'e'
    jne  storeCap
    cmp  BYTE PTR [edi+1], 'n'
    jne  storeCap
    cmp  BYTE PTR [edi+2], 'd'
    jne  storeCap
    cmp  BYTE PTR [edi+3], 0
    je   capDone
storeCap:
    add  edi, MAX_INPUT
    inc  ebx
    jmp  capLoop
capDone:
    mov  esi, 0
execCap:
    cmp  esi, ebx
    jge  capExit
    mov  edi, OFFSET blockLines
    mov  eax, esi
    imul eax, MAX_INPUT
    add  edi, eax
    lea  edx, inputBuffer
    mov  ecx, MAX_INPUT
copyCap:
    mov  al, [edi]
    mov  [edx], al
    inc  edi
    inc  edx
    dec  ecx
    cmp  al, 0
    jne  copyCap
    call StripComment
    call TokenizeLine
    cmp  tokenCount, 0
    je   nextCap
    call ProcessTokens
nextCap:
    inc  esi
    jmp  execCap
capExit:
    pop  edi
    pop  esi
    pop  ebx
    ret
CaptureBlockUntilEnd ENDP

HandleLoop PROC
    push ebp
    mov  ebp, esp
    sub  esp, 8              ; locals: [ebp-4]=loop count, [ebp-8]=line count
    push ebx
    push esi
    push edi
    call FindTokenIndexTimes
    mov  ebx, eax
    cmp  ebx, 0
    je   hlDone
    mov  eax, ebx
    dec  eax
    push eax
    push 1
    call EvaluateSimpleExpression
    add  esp, 8
    cmp  edx, 1
    jne  hlDone
    mov  [ebp-4], eax    ; persist loop count across copy loops
    cmp  eax, 0
    jle  hlDone
    mov  esi, 0
    lea  edi, blockLines
    mov  ebx, 0
loopCap:
    cmp  ebx, MAX_BLOCK_LINES
    jge  loopExec
    mov  edx, OFFSET scriptPrompt
    call WriteString
    mov  edx, edi
    mov  ecx, MAX_INPUT-1
    call ReadString
    cmp  eax, 0
    je   loopExec
    mov  edx, edi
    add  edx, eax
    dec  edx
    mov  al, [edx]
    cmp  al, 0Ah
    jne  loopChk
    mov  BYTE PTR [edx], 0
    dec  edx
    mov  al, [edx]
    cmp  al, 0Dh
    jne  loopChk
    mov  BYTE PTR [edx], 0
loopChk:
    push edi
    call ToLowerInPlace
    pop  edi
    cmp  BYTE PTR [edi], 'e'
    jne  loopStore
    cmp  BYTE PTR [edi+1], 'n'
    jne  loopStore
    cmp  BYTE PTR [edi+2], 'd'
    jne  loopStore
    cmp  BYTE PTR [edi+3], 'l'
    jne  loopStore
    cmp  BYTE PTR [edi+4], 'o'
    jne  loopStore
    cmp  BYTE PTR [edi+5], 'o'
    jne  loopStore
    cmp  BYTE PTR [edi+6], 'p'
    jne  loopStore
    cmp  BYTE PTR [edi+7], 0
    je   loopExec
loopStore:
    add  edi, MAX_INPUT
    inc  ebx
    jmp  loopCap
loopExec:
    mov  [ebp-8], ebx    ; stash captured line count
    mov  esi, 0
outerLoop:
    mov  edx, [ebp-4]
    cmp  esi, edx
    jge  hlDone
    mov  edi, 0
loopRun:
    mov  edx, [ebp-8]
    cmp  edi, edx
    jge  nextIter
    mov  eax, edi
    imul eax, MAX_INPUT
    lea  edx, blockLines[eax]
    lea  eax, inputBuffer
copyRun:
    mov  bl, [edx]
    mov  [eax], bl
    inc  edx
    inc  eax
    test bl, bl
    jne  copyRun
    call StripComment
    call TokenizeLine
    cmp  tokenCount, 0
    je   skipRun
    call ProcessTokens
skipRun:
    inc  edi
    jmp  loopRun
nextIter:
    inc  esi
    jmp  outerLoop
hlDone:
    add  esp, 8
    pop  edi
    pop  esi
    pop  ebx
    pop  ebp
    ret
HandleLoop ENDP

HandleIf PROC
    push ebp
    mov  ebp, esp
    sub  esp, 4              ; local: [ebp-4]=captured line count
    mov  DWORD PTR [ebp-4], 0
    push ebx
    push esi
    push edi
    push 1
    call EvalConditionFrom
    add  esp, 4
    cmp  eax, 0
    je   skipIf
    mov  ebx, 0
    lea  edi, blockLines
ifCap:
    cmp  ebx, MAX_BLOCK_LINES
    jge  ifExec
    mov  edx, OFFSET scriptPrompt
    call WriteString
    mov  edx, edi
    mov  ecx, MAX_INPUT-1
    call ReadString
    cmp  eax, 0
    je   ifExec
    mov  edx, edi
    add  edx, eax
    dec  edx
    mov  al, [edx]
    cmp  al, 0Ah
    jne  ifChk
    mov  BYTE PTR [edx], 0
    dec  edx
    mov  al, [edx]
    cmp  al, 0Dh
    jne  ifChk
    mov  BYTE PTR [edx], 0
ifChk:
    push edi
    call ToLowerInPlace
    pop  edi
    cmp  BYTE PTR [edi], 'e'
    jne  ifStore
    cmp  BYTE PTR [edi+1], 'n'
    jne  ifStore
    cmp  BYTE PTR [edi+2], 'd'
    jne  ifStore
    cmp  BYTE PTR [edi+3], 'i'
    jne  ifStore
    cmp  BYTE PTR [edi+4], 'f'
    jne  ifStore
    cmp  BYTE PTR [edi+5], 0
    je   ifExec
ifStore:
    add  edi, MAX_INPUT
    inc  ebx
    jmp  ifCap
ifExec:
    mov  [ebp-4], ebx        ; persist captured line count
    mov  esi, 0
ifRun:
    cmp  esi, [ebp-4]
    jge  ifDone
    mov  eax, esi
    imul eax, MAX_INPUT
    lea  edx, blockLines[eax]
    lea  eax, inputBuffer
copyIf:
    mov  bl, [edx]
    mov  [eax], bl
    inc  edx
    inc  eax
    test bl, bl
    jne  copyIf
    call StripComment
    call TokenizeLine
    cmp  tokenCount, 0
    je   nextIf
    call ProcessTokens
nextIf:
    inc  esi
    jmp  ifRun
ifDone:
    jmp  ifExit
skipIf:
    lea  edi, inputBuffer
skipIfLoop:
    mov  edx, OFFSET scriptPrompt
    call WriteString
    mov  edx, edi
    mov  ecx, MAX_INPUT-1
    call ReadString
    cmp  eax, 0
    je   ifExit
    mov  ebx, eax
    mov  esi, edi
    add  esi, ebx
    dec  esi
    mov  al, [esi]
    cmp  al, 0Ah
    jne  skipIfChk
    mov  BYTE PTR [esi], 0
    dec  esi
    mov  al, [esi]
    cmp  al, 0Dh
    jne  skipIfChk
    mov  BYTE PTR [esi], 0
skipIfChk:
    push edi
    call ToLowerInPlace
    pop  edi
    cmp  BYTE PTR [edi], 'e'
    jne  skipIfLoop
    cmp  BYTE PTR [edi+1], 'n'
    jne  skipIfLoop
    cmp  BYTE PTR [edi+2], 'd'
    jne  skipIfLoop
    cmp  BYTE PTR [edi+3], 'i'
    jne  skipIfLoop
    cmp  BYTE PTR [edi+4], 'f'
    jne  skipIfLoop
    cmp  BYTE PTR [edi+5], 0
    jne  skipIfLoop
ifExit:
    add  esp, 4
    pop  edi
    pop  esi
    pop  ebx
    pop  ebp
    ret
HandleIf ENDP

END main
    cmp  BYTE PTR [edi+5], 0
    jne  skipIfLoop
ifExit:
    add  esp, 4
    pop  edi
    pop  esi
    pop  ebx
    pop  ebp
    ret
HandleIf ENDP

END main
