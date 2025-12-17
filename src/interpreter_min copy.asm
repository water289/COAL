.386
.model flat, stdcall
.stack 4096
ExitProcess PROTO, dwExitCode:DWORD

INCLUDE Irvine32.inc

.data
    banner      BYTE "========================================",0Dh,0Ah
                BYTE " Human Language Scripting Interpreter (minimal)",0Dh,0Ah
                BYTE " Type 'help' for commands",0Dh,0Ah
                BYTE " Type 'exit' to quit",0Dh,0Ah
                BYTE "========================================",0Dh,0Ah,0
    prompt      BYTE ">>> ",0
    inputBuffer BYTE 256 DUP(0)

    MAX_TOKENS      EQU 32
    MAX_TOKEN_LEN   EQU 32
    tokens          BYTE MAX_TOKENS * MAX_TOKEN_LEN DUP(0)
    tokenCount      DWORD 0

    MAX_VARS        EQU 10
    varNames        BYTE MAX_VARS * MAX_TOKEN_LEN DUP(0)
    varValues       DWORD MAX_VARS DUP(0)
    varCount        DWORD 0

    cmdHelp     BYTE "help",0
    cmdPrint    BYTE "print",0
    cmdCalculate BYTE "calculate",0
    cmdStore    BYTE "store",0
    cmdShow     BYTE "show",0
    cmdIn       BYTE "in",0
    cmdExit     BYTE "exit",0
    cmdQuit     BYTE "quit",0

    helpText    BYTE "Commands:",0Dh,0Ah
                BYTE "  help                 - Show this help",0Dh,0Ah
                BYTE "  print <text>         - Print text",0Dh,0Ah
                BYTE "  calculate <expr>     - Evaluate + - * / with nums/vars",0Dh,0Ah
                BYTE "  store <n> in <var>   - Save number to variable",0Dh,0Ah
                BYTE "  show <var>           - Display variable",0Dh,0Ah
                BYTE "  exit                 - Exit interpreter",0Dh,0Ah,0

    storeErrMsg BYTE "Error: syntax is 'store <number> in <var>'",0Dh,0Ah,0
    showErrMsg  BYTE "Error: syntax is 'show <var>'",0Dh,0Ah,0
    varNotFoundMsg BYTE "Error: variable not found",0Dh,0Ah,0
    calcErrMsg  BYTE "Error: invalid calculate expression",0Dh,0Ah,0
    dbgOpMsg    BYTE "op:",0
    dbgTermMsg  BYTE " term:",0
    dbgOpdMsg   BYTE " opd:",0
    dbgAccMsg   BYTE " acc:",0
    dbgTokens   BYTE "tokens:",0

.code

; Compare two null-terminated strings; returns 0 if equal, 1 otherwise
; ESI = string1, EDI = string2
StrEq PROC USES esi edi edx
strLoop:
    mov al, BYTE PTR [esi]
    mov dl, BYTE PTR [edi]
    cmp al, dl
    jne strNot
    cmp al, 0
    je strEq
    inc esi
    inc edi
    jmp strLoop
strNot:
    mov eax, 1
    ret
strEq:
    xor eax, eax
    ret
StrEq ENDP

; ParseInt - simple decimal parser
; Input: ESI -> null-terminated numeric string
; Output: EAX = value, CF=0 on success, CF=1 on invalid
ParseInt PROC USES ebx ecx edx esi
    xor eax, eax
    xor ebx, ebx
    xor ecx, ecx
parseDigits:
    mov dl, BYTE PTR [esi]
    cmp dl, 0
    je parsed
    cmp dl, '0'
    jb invalid
    cmp dl, '9'
    ja invalid
    imul eax, 10
    movzx edx, dl
    sub edx, '0'
    add eax, edx
    inc esi
    jmp parseDigits
parsed:
    clc
    ret
invalid:
    stc
    ret
ParseInt ENDP

; FindVariable - search by name
; ESI = name ptr; returns EAX=value, CF=0 found; CF=1 not found
FindVariable PROC USES ecx edx edi esi
    xor ecx, ecx
findLp:
    cmp ecx, varCount
    jge notFound
    mov eax, ecx
    mov edx, MAX_TOKEN_LEN
    mul edx
    lea edi, varNames[eax]
    ; compare input name (ESI) with stored name (EDI)
    call StrEq
    cmp eax, 0
    je found
    inc ecx
    jmp findLp
found:
    mov eax, ecx
    mov edx, 4
    mul edx
    mov eax, varValues[eax]
    clc
    ret
notFound:
    xor eax, eax
    stc
    ret
FindVariable ENDP

; StoreVariable - create/update
; ESI = name ptr, EAX = value
StoreVariable PROC USES ebx ecx edx edi esi
    mov ebx, eax
    xor ecx, ecx
storeSearch:
    cmp ecx, varCount
    jge storeNew
    mov eax, ecx
    mov edx, MAX_TOKEN_LEN
    mul edx
    lea edi, varNames[eax]
    ; compare input name (ESI) with stored name (EDI)
    call StrEq
    cmp eax, 0
    je storeUpdate
    inc ecx
    jmp storeSearch
storeUpdate:
    mov eax, ecx
    mov edx, 4
    mul edx
    mov varValues[eax], ebx
    ret
storeNew:
    cmp varCount, MAX_VARS
    jge storeDone
    mov eax, varCount
    mov edx, MAX_TOKEN_LEN
    mul edx
    lea edi, varNames[eax]
copyNm:
    mov dl, BYTE PTR [esi]
    mov BYTE PTR [edi], dl
    cmp dl, 0
    je nmDone
    inc esi
    inc edi
    jmp copyNm
nmDone:
    mov eax, varCount
    mov edx, 4
    mul edx
    mov varValues[eax], ebx
    inc varCount
storeDone:
    ret
StoreVariable ENDP

; EvaluateCalcTokens - evaluates tokens[1..tokenCount-1] as expr (left-to-right, no precedence)
; Simple left-to-right evaluation for + - * /
; On success: CF=0, EAX=result. On failure: CF=1
EvaluateCalcTokens PROC USES ebx ecx edx esi edi
    ; Need at least one operand
    cmp tokenCount, 2
    jl calcFail

    ; Load first operand into EAX (result accumulator)
    mov eax, 1
    call GetToken
    mov esi, eax
    call ParseOperandValue
    jc calcFail
    ; EAX now has the result value

    mov ecx, 2              ; start from operator index

calcLoop:
    cmp ecx, tokenCount
    jge calcDone            ; no more operators/operands

    ; Load operator at index ECX
    mov ebx, eax            ; save current result in EBX
    mov eax, ecx
    call GetToken
    mov esi, eax
    mov dl, BYTE PTR [esi]  ; operator in DL
    cmp dl, 0
    je calcDone

    ; Increment to operand index
    inc ecx
    cmp ecx, tokenCount
    jge calcFail            ; missing operand

    ; Load next operand into EDI
    mov eax, ecx
    call GetToken
    mov esi, eax
    call ParseOperandValue
    jc calcFail
    mov edi, eax            ; operand in EDI

    ; EBX = current result, EDI = next operand, DL = operator
    ; Perform operation: result = result OP operand
    cmp dl, '+'
    je opAdd
    cmp dl, '-'
    je opSub
    cmp dl, '*'
    je opMul
    cmp dl, '/'
    je opDiv
    jmp calcFail

opAdd:
    add ebx, edi
    mov eax, ebx
    jmp calcNext
opSub:
    sub ebx, edi
    mov eax, ebx
    jmp calcNext
opMul:
    imul ebx, edi
    mov eax, ebx
    jmp calcNext
opDiv:
    cmp edi, 0
    je calcFail
    mov eax, ebx
    cdq
    idiv edi
    ; result in EAX
    jmp calcNext

calcNext:
    inc ecx
    jmp calcLoop

calcDone:
    clc
    ret

calcFail:
    stc
    ret
EvaluateCalcTokens ENDP

; ParseOperandValue - parse number or variable at ESI
; Returns EAX=value, CF=0 on success, CF=1 on error
ParseOperandValue PROC USES esi
    mov al, BYTE PTR [esi]
    cmp al, 'a'
    jb tryNum
    cmp al, 'z'
    ja tryNum
    ; variable
    push esi
    call FindVariable
    pop esi
    ret                     ; CF set by FindVariable
tryNum:
    call ParseInt
    ret
ParseOperandValue ENDP

; Tokenize inputBuffer into tokens separated by spaces
Tokenize PROC USES eax ebx ecx edx esi edi
    mov tokenCount, 0
    mov edi, OFFSET tokens
    mov ecx, MAX_TOKENS * MAX_TOKEN_LEN
    xor al, al
    rep stosb

    mov esi, OFFSET inputBuffer
    mov ebx, 0

nextTok:
    mov al, BYTE PTR [esi]
    cmp al, 0
    je tokDone
    cmp al, ' '
    je skipSpace
    cmp al, 0Dh             ; carriage return
    je skipSpace
    cmp al, 0Ah             ; line feed (just in case)
    je skipSpace

    ; single-char operators become their own tokens
    cmp al, '+'
    je opToken
    cmp al, '-'
    je opToken
    cmp al, '*'
    je opToken
    cmp al, '/'
    je opToken

    ; regular token (word/number)
    cmp ebx, MAX_TOKENS
    jge tokDone
    mov eax, ebx
    mov ecx, MAX_TOKEN_LEN
    mul ecx
    lea edi, tokens[eax]
    xor ecx, ecx
copyTok:
    mov al, BYTE PTR [esi]
    cmp al, 0
    je endTok
    cmp al, ' '
    je endTok
    cmp al, 0Dh
    je endTok
    cmp al, 0Ah
    je endTok
    cmp al, '+'
    je endTok
    cmp al, '-'
    je endTok
    cmp al, '*'
    je endTok
    cmp al, '/'
    je endTok
    cmp ecx, MAX_TOKEN_LEN-1
    jge endTok
    mov BYTE PTR [edi], al
    inc esi
    inc edi
    inc ecx
    jmp copyTok
endTok:
    mov BYTE PTR [edi], 0
    inc ebx
    jmp nextTok

opToken:
    cmp ebx, MAX_TOKENS
    jge tokDone
    push eax                ; Save EAX containing operator character in AL
    mov eax, ebx            ; EAX = token index  
    mov ecx, MAX_TOKEN_LEN
    mul ecx                 ; EDX:EAX = result (clobbers EDX/EAX)
    lea edi, tokens[eax]    ; EDI points to token storage
    pop eax                 ; Restore EAX with operator in AL
    mov BYTE PTR [edi], al  ; Store operator
    mov BYTE PTR [edi+1], 0
    inc ebx
    inc esi
    jmp nextTok

skipSpace:
    inc esi
    jmp nextTok

tokDone:
    mov tokenCount, ebx
    ret
Tokenize ENDP

; GetToken: EAX=index -> EAX=pointer
GetToken PROC USES ecx edx
    mov edx, eax            ; preserve index
    mov eax, MAX_TOKEN_LEN
    mul edx                 ; eax = index * MAX_TOKEN_LEN
    lea eax, tokens[eax]
    ret
GetToken ENDP

main PROC
    mov edx, OFFSET banner
    call WriteString

mainLoop:
    mov edx, OFFSET prompt
    call WriteString

    mov edx, OFFSET inputBuffer
    mov ecx, SIZEOF inputBuffer
    call ReadString
    cmp eax, 0
    je mainLoop
    mov BYTE PTR [inputBuffer + eax], 0

    call Tokenize
    cmp tokenCount, 0
    je mainLoop

    ; Get first token pointer once
    mov eax, 0
    call GetToken
    mov ebx, eax            ; save pointer to first token

    ; help
    mov esi, ebx
    mov edi, OFFSET cmdHelp
    call StrEq
    cmp eax, 0
    je doHelp

    ; print
    mov esi, ebx
    mov edi, OFFSET cmdPrint
    call StrEq
    cmp eax, 0
    je doPrint

    ; store
    mov esi, ebx
    mov edi, OFFSET cmdStore
    call StrEq
    cmp eax, 0
    je doStore

    ; show
    mov esi, ebx
    mov edi, OFFSET cmdShow
    call StrEq
    cmp eax, 0
    je doShow

    ; calculate
    mov esi, ebx
    mov edi, OFFSET cmdCalculate
    call StrEq
    cmp eax, 0
    je doCalc

    ; exit
    mov esi, ebx
    mov edi, OFFSET cmdExit
    call StrEq
    cmp eax, 0
    je doExit

    ; quit
    mov esi, ebx
    mov edi, OFFSET cmdQuit
    call StrEq
    cmp eax, 0
    je doExit

    jmp mainLoop

doHelp:
    mov edx, OFFSET helpText
    call WriteString
    jmp mainLoop

doPrint:
    mov ebx, 1              ; start from token 1
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
    mov al, ' '
    call WriteChar
    jmp printLoop
printDone:
    call Crlf
    jmp mainLoop

doStore:
    cmp tokenCount, 4
    jl storeErr
    ; token1 = number
    mov eax, 1
    call GetToken
    mov esi, eax
    call ParseInt
    jc storeErr
    mov ebx, eax            ; value
    ; token2 must be "in"
    mov eax, 2
    call GetToken
    mov esi, eax
    mov edi, OFFSET cmdIn
    call StrEq
    cmp eax, 0
    jne storeErr
    ; token3 = var name
    mov eax, 3
    call GetToken
    mov esi, eax
    mov eax, ebx
    call StoreVariable
    jmp mainLoop
storeErr:
    mov edx, OFFSET storeErrMsg
    call WriteString
    jmp mainLoop

doShow:
    cmp tokenCount, 2
    jl showErr
    mov eax, 1
    call GetToken
    mov esi, eax
    call FindVariable
    jc varMissing
    call WriteInt
    call Crlf
    jmp mainLoop
varMissing:
    mov edx, OFFSET varNotFoundMsg
    call WriteString
    jmp mainLoop
showErr:
    mov edx, OFFSET showErrMsg
    call WriteString
    jmp mainLoop

doCalc:
    cmp tokenCount, 2
    jl calcErr
    call EvaluateCalcTokens
    jc calcErr
    call WriteInt
    call Crlf
    jmp mainLoop
calcErr:
    mov edx, OFFSET calcErrMsg
    call WriteString
    jmp mainLoop

doExit:
    INVOKE ExitProcess, 0

main ENDP
END main
