INCLUDE Irvine32.inc

MAX_VARS = 32
MAX_LINE = 128
MAX_TOKENS = 16

.data
prompt       BYTE ">>> ",0
helpText     BYTE "Commands: store <num> in <var>, print <num>, show <var>, increment <var>, help, exit",13,10,0
inputBuffer  BYTE MAX_LINE DUP(0)
tokens       BYTE MAX_TOKENS*16 DUP(0)
varNames     BYTE MAX_VARS*16 DUP(0)
varValues    SDWORD MAX_VARS DUP(0)
varCount     DWORD 0
tempValue    SDWORD 0
tokenIndex   DWORD 0
varIndex     DWORD 0
tokenCounter DWORD 0

.code
main PROC
    call Clrscr
    
mainLoop:
    mov edx, OFFSET prompt
    call WriteString
    
    mov edx, OFFSET inputBuffer
    mov ecx, MAX_LINE-1
    call ReadString
    
    cmp eax, 0
    je mainLoop
    
    call tokenizeInput
    call processCommand
    cmp eax, 1
    je endProg
    
    jmp mainLoop

endProg:
    exit
main ENDP

tokenizeInput PROC USES esi edi ecx edx
    mov esi, OFFSET inputBuffer
    mov edi, OFFSET tokens
    mov tokenCounter, 0
    xor ecx, ecx
    
tokenLoop:
    lodsb
    cmp al, 0
    je tokensDone
    cmp al, ' '
    je checkToken
    cmp al, ';'
    je tokensDone
    
    mov [edi], al
    inc edi
    inc ecx
    cmp ecx, 15
    jl tokenLoop
    
    mov BYTE PTR [edi], 0
    inc edi
    inc tokenCounter
    xor ecx, ecx
    jmp tokenLoop
    
checkToken:
    cmp ecx, 0
    je tokenLoop
    
    mov BYTE PTR [edi], 0
    inc edi
    inc tokenCounter
    xor ecx, ecx
    jmp tokenLoop
    
tokensDone:
    cmp ecx, 0
    je tokensDoneClean
    mov BYTE PTR [edi], 0
    inc tokenCounter
    
tokensDoneClean:
    mov tokenIndex, 0
    ret
tokenizeInput ENDP

getNextToken PROC USES esi ecx
    mov eax, tokenIndex
    cmp eax, tokenCounter
    jge noMoreTokens
    
    mov esi, OFFSET tokens
    mov ecx, eax
    mov edx, 0
    
findTokenStart:
    cmp ecx, tokenCounter
    jge noMoreTokens
    
    mov al, byte ptr [esi + ecx*16]
    cmp al, 0
    jne foundToken
    
    inc ecx
    jmp findTokenStart
    
foundToken:
    mov eax, ecx
    mov tokenIndex, eax
    inc tokenIndex
    mov eax, dword ptr [esi + ecx*16]
    ret
    
noMoreTokens:
    mov al, 0
    ret
getNextToken ENDP

getNumber PROC USES ebx ecx esi
    call getNextToken
    
    mov esi, OFFSET tokens
    mov ecx, tokenIndex
    dec ecx
    
    xor eax, eax
    xor ebx, ebx
    
numLoop:
    mov cl, byte ptr [esi + ecx*16 + ebx]
    cmp cl, 0
    je numDone
    cmp cl, '0'
    jb numDone
    cmp cl, '9'
    ja numDone
    
    sub cl, '0'
    movzx ecx, cl
    imul eax, 10
    add eax, ecx
    inc ebx
    jmp numLoop
    
numDone:
    ret
getNumber ENDP

findVariable PROC USES ebx ecx edi esi
    mov esi, OFFSET tokens
    mov ecx, tokenIndex
    dec ecx
    mov al, byte ptr [esi + ecx*16]
    
    mov ebx, 0
    mov edx, varCount
    
searchLoop:
    cmp ebx, edx
    jge notFound
    
    mov eax, ebx
    inc ebx
    jmp searchLoop
    
notFound:
    mov eax, -1
    ret
findVariable ENDP

findOrCreateVar PROC USES ebx ecx esi edi
    call findVariable
    cmp eax, -1
    jne varExists
    
    mov eax, varCount
    cmp eax, MAX_VARS
    jge tooManyVars
    
    mov esi, OFFSET tokens
    mov ecx, tokenIndex
    dec ecx
    mov edi, OFFSET varNames
    mov ebx, eax
    imul ebx, 16
    add edi, ebx
    
    xor ecx, ecx
copyLoop:
    cmp ecx, 16
    jge copyDone
    
    mov al, byte ptr [esi + ecx*16 + ecx]
    mov byte ptr [edi + ecx], al
    inc ecx
    jmp copyLoop
    
copyDone:
    mov eax, varCount
    inc varCount
    ret
    
varExists:
    ret
    
tooManyVars:
    mov eax, -1
    ret
findOrCreateVar ENDP

processCommand PROC USES ebx ecx esi edi
    mov tokenIndex, 0
    call getNextToken
    
    cmp al, 'h'
    je cmdHelp
    cmp al, 'e'
    je cmdExit
    cmp al, 's'
    je cmdStore
    cmp al, 'p'
    je cmdPrint
    cmp al, 'i'
    je cmdIncrement
    cmp al, 'o'
    je cmdShow
    
    xor eax, eax
    ret
    
cmdHelp:
    mov edx, OFFSET helpText
    call WriteString
    xor eax, eax
    ret
    
cmdExit:
    mov eax, 1
    ret
    
cmdStore:
    call getNumber
    mov tempValue, eax
    
    call getNextToken
    call getNextToken
    call findOrCreateVar
    cmp eax, -1
    je storeError
    
    mov varIndex, eax
    mov eax, tempValue
    mov ebx, varIndex
    imul ebx, 4
    mov varValues[ebx], eax
    xor eax, eax
    ret
    
storeError:
    xor eax, eax
    ret
    
cmdPrint:
    call getNumber
    call WriteInt
    call Crlf
    xor eax, eax
    ret
    
cmdIncrement:
    call getNextToken
    call findVariable
    cmp eax, -1
    je incError
    
    mov varIndex, eax
    mov ebx, eax
    imul ebx, 4
    mov ecx, varValues[ebx]
    inc ecx
    mov varValues[ebx], ecx
    xor eax, eax
    ret
    
incError:
    xor eax, eax
    ret
    
cmdShow:
    call getNextToken
    call findVariable
    cmp eax, -1
    je showError
    
    mov varIndex, eax
    mov ebx, eax
    imul ebx, 16
    mov edx, OFFSET varNames
    add edx, ebx
    call WriteString
    mov al, ' '
    call WriteChar
    mov al, '='
    call WriteChar
    mov al, ' '
    call WriteChar
    mov ebx, varIndex
    imul ebx, 4
    mov eax, varValues[ebx]
    call WriteInt
    call Crlf
    xor eax, eax
    ret
    
showError:
    xor eax, eax
    ret
    
processCommand ENDP

END main
