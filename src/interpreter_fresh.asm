.386
.model flat, stdcall
.stack 4096
ExitProcess PROTO, dwExitCode:DWORD

INCLUDE Irvine32.inc

.data
    banner      BYTE "========================================",0Dh,0Ah
                BYTE " Human Language Scripting Interpreter v2.0 (fresh)",0Dh,0Ah
                BYTE " Type 'help' for commands",0Dh,0Ah
                BYTE " Type 'exit' to quit",0Dh,0Ah
                BYTE "========================================",0Dh,0Ah,0
    prompt      BYTE ">>> ",0
    inputBuffer BYTE 256 DUP(0)
    exprBuffer  BYTE 256 DUP(0)

    MAX_TOKENS      EQU 20
    MAX_TOKEN_LEN   EQU 32
    tokens          BYTE MAX_TOKENS * MAX_TOKEN_LEN DUP(0)
    tokenCount      DWORD 0

    MAX_VARS        EQU 10
    varNames        BYTE MAX_VARS * MAX_TOKEN_LEN DUP(0)
    varValues       DWORD MAX_VARS DUP(0)
    varCount        DWORD 0

    tempVarName BYTE MAX_TOKEN_LEN DUP(0)

    cmdHelp     BYTE "help",0
    cmdPrint    BYTE "print",0
    cmdCalculate BYTE "calculate",0
    cmdStore    BYTE "store",0
    cmdShow     BYTE "show",0
    cmdClear    BYTE "clear",0
    cmdExit     BYTE "exit",0
    cmdQuit     BYTE "quit",0
    cmdIn       BYTE "in",0

    helpText    BYTE "Commands:",0Dh,0Ah
                BYTE "  help                     - Show this help",0Dh,0Ah
                BYTE "  print <text>             - Print text",0Dh,0Ah
                BYTE "  calculate <expr>         - Calculate expression (supports vars)",0Dh,0Ah
                BYTE "  store <expr> in <var>    - Save expression to variable",0Dh,0Ah
                BYTE "  show <var>               - Display variable",0Dh,0Ah
                BYTE "  clear                    - Clear screen",0Dh,0Ah
                BYTE "  exit                     - Exit interpreter",0Dh,0Ah,0

    errorMsg    BYTE "Error: invalid command or syntax",0Dh,0Ah,0
    storeErrMsg BYTE "Error: syntax is 'store <expr> in <var>'",0Dh,0Ah,0
    showErrMsg  BYTE "Error: syntax is 'show <var>'",0Dh,0Ah,0
    varNotFoundMsg BYTE "Error: variable not found",0Dh,0Ah,0

.code

; ------------- Utility -------------
SkipWs PROC USES eax esi
done:
skipWsLoop:
    mov al, BYTE PTR [esi]
    cmp al, ' '
    je short skipWsAdv
    cmp al, 0Dh
    je short skipWsAdv
    cmp al, 0Ah
    jne short done
skipWsAdv:
    inc esi
    jmp short skipWsLoop
skipWsDone:
    ret
SkipWs ENDP

StrEq PROC USES esi edi
strCompare:
    mov al, BYTE PTR [esi]
    mov ah, BYTE PTR [edi]
    cmp al, ah
    jne strNotEq
    cmp al, 0
    je strEq
    inc esi
    inc edi
    jmp strCompare
strNotEq:
    mov eax, 1
    ret
strEq:
    xor eax, eax
    ret
StrEq ENDP

; ------------- Tokenize -------------
Tokenize PROC USES eax ebx ecx edx esi edi
    mov tokenCount, 0
    mov edi, OFFSET tokens
    mov ecx, MAX_TOKENS * MAX_TOKEN_LEN
    xor al, al
    rep stosb

    mov esi, OFFSET inputBuffer
    mov ebx, 0

nextTok:
    ; skip spaces
    mov al, BYTE PTR [esi]
    cmp al, 0
    je done
    cmp al, ' '
    jne start
    inc esi
    jmp nextTok
start:
    cmp ebx, MAX_TOKENS
    jge done
    mov eax, ebx
    mov ecx, MAX_TOKEN_LEN
    mul ecx
    lea edi, tokens[eax]
    xor ecx, ecx
copy:
    mov al, BYTE PTR [esi]
    cmp al, 0
    je endTok
    cmp al, ' '
    je endTok
    cmp ecx, MAX_TOKEN_LEN-1
    jge endTok
    mov BYTE PTR [edi], al
    inc esi
    inc edi
    inc ecx
    jmp copy
endTok:
    mov BYTE PTR [edi], 0
    inc ebx
    jmp nextTok

done:
    mov tokenCount, ebx
    ret
Tokenize ENDP

GetToken PROC USES ecx eax
    mov ecx, MAX_TOKEN_LEN
    mul ecx
    lea eax, tokens[eax]
    ret
GetToken ENDP

; ------------- Variables -------------
FindVariable PROC USES ecx edx edi esi
    xor ecx, ecx
search:
    cmp ecx, varCount
    jge notFound
    mov eax, ecx
    mov edx, MAX_TOKEN_LEN
    mul edx
    lea edi, varNames[eax]
    push esi
    mov esi, edi
    call StrEq
    pop esi
    cmp eax, 0
    je found
    inc ecx
    jmp search
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

StoreVariable PROC USES ebx ecx edx edi esi eax
    mov ebx, eax    ; value
    xor ecx, ecx
findSlot:
    cmp ecx, varCount
    jge newVar
    mov eax, ecx
    mov edx, MAX_TOKEN_LEN
    mul edx
    lea edi, varNames[eax]
    push esi
    mov esi, edi
    call StrEq
    pop esi
    cmp eax, 0
    je update
    inc ecx
    jmp findSlot
update:
    mov eax, ecx
    mov edx, 4
    mul edx
    mov varValues[eax], ebx
    ret
newVar:
    cmp varCount, MAX_VARS
    jge storeDone
    mov eax, varCount
    mov edx, MAX_TOKEN_LEN
    mul edx
    lea edi, varNames[eax]
copyName:
    mov dl, BYTE PTR [esi]
    mov BYTE PTR [edi], dl
    cmp dl, 0
    je nameDone
    inc esi
    inc edi
    jmp copyName
nameDone:
    mov eax, varCount
    mov edx, 4
    mul edx
    mov varValues[eax], ebx
    inc varCount
storeDone:
    ret
StoreVariable ENDP

; ------------- Expression Parser -------------
; expr   -> term { (+|-) term }
; term   -> factor { (*|/) factor }
; factor -> number | variable

EvaluateExpression PROC USES ebx ecx edx esi edi
    xor eax, eax          ; result
    call ParseTerm        ; EBX = term
    mov eax, ebx
exprLoop:
    call SkipWs
    mov dl, BYTE PTR [esi]
    cmp dl, 0
    je exprDone
    cmp dl, '+'
    je doAdd
    cmp dl, '-'
    je doSub
    ret                    ; unexpected char, return current result

doAdd:
    inc esi
    call ParseTerm        ; EBX = next term
    add eax, ebx
    jmp exprLoop

doSub:
    inc esi
    call ParseTerm
    sub eax, ebx
    jmp exprLoop

exprDone:
    ret
EvaluateExpression ENDP

ParseTerm PROC USES eax ecx edx esi edi
    call ParseFactor      ; EDX = factor
    mov ebx, edx
termLoop:
    call SkipWs
    mov al, BYTE PTR [esi]
    cmp al, '*'
    je termMul
    cmp al, '/'
    je termDiv
    ret
termMul:
    inc esi
    call ParseFactor
    imul ebx, edx
    jmp termLoop
termDiv:
    inc esi
    call ParseFactor
    cmp edx, 0
    je zeroDiv
    mov eax, ebx
    cdq
    idiv edx
    mov ebx, eax
    jmp termLoop
zeroDiv:
    xor ebx, ebx
    jmp termLoop
ParseTerm ENDP

ParseFactor PROC USES eax ecx edi esi
    call SkipWs
    mov al, BYTE PTR [esi]
    cmp al, 'a'
    jb parseNum
    cmp al, 'z'
    ja parseNum
    ; variable
    xor ecx, ecx
varLoop:
    mov al, BYTE PTR [esi]
    cmp al, 'a'
    jb varDone
    cmp al, 'z'
    ja varDone
    mov BYTE PTR tempVarName[ecx], al
    inc ecx
    inc esi
    jmp varLoop
varDone:
    mov BYTE PTR tempVarName[ecx], 0
    push esi
    lea esi, tempVarName
    call FindVariable
    mov edx, eax
    pop esi
    jnc factorExit
    xor edx, edx
    jmp factorExit
parseNum:
    xor edx, edx
    mov ecx, 0
numLoop:
    mov al, BYTE PTR [esi]
    cmp al, '0'
    jb factorExit
    cmp al, '9'
    ja factorExit
    imul edx, 10
    movzx ecx, al
    sub ecx, '0'
    add edx, ecx
    inc esi
    jmp numLoop
factorExit:
    ret
ParseFactor ENDP

; ------------- Main -------------
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

    mov eax, 0
    call GetToken
    mov esi, eax           ; command token pointer
    mov ebx, eax           ; save command token pointer

    mov edi, OFFSET cmdHelp
    call StrEq
    cmp eax, 0
    je doHelp

    mov edi, OFFSET cmdPrint
    mov esi, ebx
    call StrEq
    cmp eax, 0
    je doPrint

    mov edi, OFFSET cmdCalculate
    mov esi, ebx
    call StrEq
    cmp eax, 0
    je doCalc

    mov edi, OFFSET cmdStore
    mov esi, ebx
    call StrEq
    cmp eax, 0
    je doStore

    mov edi, OFFSET cmdShow
    mov esi, ebx
    call StrEq
    cmp eax, 0
    je doShow

    mov edi, OFFSET cmdClear
    mov esi, ebx
    call StrEq
    cmp eax, 0
    je doClear

    mov edi, OFFSET cmdExit
    mov esi, ebx
    call StrEq
    cmp eax, 0
    je doExit

    mov edi, OFFSET cmdQuit
    mov esi, ebx
    call StrEq
    cmp eax, 0
    je doExit

    jmp mainLoop

doHelp:
    mov edx, OFFSET helpText
    call WriteString
    jmp mainLoop

doPrint:
    mov ebx, 1
printNext:
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
    jmp printNext
printDone:
    call Crlf
    jmp mainLoop

doCalc:
    cmp tokenCount, 1
    je calcErr
    lea edi, exprBuffer
    mov ebx, 1
buildExpr:
    cmp ebx, tokenCount
    jge evalExpr
    mov eax, ebx
    call GetToken
    mov esi, eax
    cmp ebx, 1
    je noSpace
    mov BYTE PTR [edi], ' '
    inc edi
noSpace:
copyTok:
    mov al, BYTE PTR [esi]
    mov BYTE PTR [edi], al
    cmp al, 0
    je tokDone
    inc esi
    inc edi
    jmp copyTok
tokDone:
    inc ebx
    jmp buildExpr
evalExpr:
    mov BYTE PTR [edi], 0
    lea esi, exprBuffer
    call EvaluateExpression
    call WriteInt
    call Crlf
    jmp mainLoop
calcErr:
    mov edx, OFFSET errorMsg
    call WriteString
    jmp mainLoop

doStore:
    cmp tokenCount, 4
    jl storeErr
    mov eax, 2
    call GetToken
    mov esi, eax
    mov edi, OFFSET cmdIn
    call StrEq
    cmp eax, 0
    jne storeErr
    mov eax, 1
    call GetToken
    mov esi, eax
    call EvaluateExpression
    mov ebx, eax
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

doClear:
    call Clrscr
    jmp mainLoop

doExit:
    INVOKE ExitProcess, 0

main ENDP
END main
