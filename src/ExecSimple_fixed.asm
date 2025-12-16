; ============================================================================
; ExecSimple with standard frame - COMPLETE REPLACEMENT
; Copy this entire function to replace the existing ExecSimple in HLS_Final_fixed.asm
; ============================================================================

ExecSimple PROC
    ; ESI=command on entry, ret EAX=1 continue, 0 exit
    ; Standard frame with proper register preservation
    
    push ebp
    mov ebp, esp
    sub esp, 8          ; local space if needed
    push ebx
    push ecx
    push edx
    push esi
    push edi
    
    ; TRACE: enter ExecSimple
    mov edx, OFFSET traceEnterExecSimple
    call WriteString
    
    ; ESI already points to command string (passed by caller)
    call SkipSpaces
    cmp BYTE PTR [esi], 0
    je ExitOK
    
    ; Get first token
    mov edi, OFFSET tokenBuf
    call GetToken
    test eax, eax
    jz ExitOK
    
    ; Check which command (tokenBuf now has the command word)
    push esi            ; save command pointer
    
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
    
    ; Unknown command
    pop esi
    mov edx, OFFSET errMsg
    call WriteString
    jmp ExitOK
    
IsExit:
    pop esi
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    mov esp, ebp
    pop ebp
    
    mov edx, OFFSET traceExitExecSimple
    call WriteString
    xor eax, eax
    ret
    
IsHelp:
    pop esi
    mov edx, OFFSET traceBeforeHelp
    call WriteString
    mov edx, OFFSET helpMsg
    call WriteString
    jmp ExitOK
    
IsPrint:
    pop esi            ; restore command pointer
    push esi
    mov edi, esi
    
FindIf_loop:
    mov al, [edi]
    test al, al
    je NoIf
    cmp al, 'i'
    je ChkIf
    cmp al, 'I'
    je ChkIf
    inc edi
    jmp FindIf_loop
    
ChkIf:
    push edi
    mov esi, edi
    mov edi, OFFSET cmdIf
    call StrCmpI
    pop edi
    test eax, eax
    jz HasIf
    inc edi
    jmp FindIf_loop
    
HasIf:
    mov BYTE PTR [edi], 0
    pop esi
    push esi
    lea esi, [edi+3]
    call EvalCond
    pop esi
    push esi
    test eax, eax
    jz PrintDone
    call EvalExpr
    cmp edx, 1
    jne PrintDone
    call WriteInt
    call Crlf
    jmp PrintDone
    
NoIf:
    pop esi
    push esi
    call EvalExpr
    cmp edx, 1
    jne PrintDone
    call WriteInt
    call Crlf
    
PrintDone:
    pop esi
    jmp ExitOK
    
IsStore:
    pop esi            ; restore command pointer
    push esi
    mov ebx, esi
    
StoreFind_loop:
    mov al, [ebx]
    test al, al
    jz StoreError
    cmp al, ' '
    jne StoreFind_next
    inc ebx
    mov al, [ebx]
    cmp al, 'i'
    je StoreCandidate
    cmp al, 'I'
    je StoreCandidate
    jmp StoreFind_next
    
StoreCandidate:
    inc ebx
    mov al, [ebx]
    cmp al, 'n'
    je StoreCheckSpace
    cmp al, 'N'
    je StoreCheckSpace
    dec ebx
    jmp StoreFind_next
    
StoreCheckSpace:
    inc ebx
    mov al, [ebx]
    cmp al, ' '
    je StoreFound
    cmp al, 0
    je StoreFound
    dec ebx
    dec ebx
    jmp StoreFind_next
    
StoreFind_next:
    inc ebx
    jmp StoreFind_loop
    
StoreFound:
    sub ebx, 3
    mov BYTE PTR [ebx], 0
    pop esi
    push esi
    call EvalExpr
    cmp edx, 1
    jne StoreError
    push eax
    mov esi, OFFSET workBuf
    
StoreFind_end:
    mov al, [esi]
    test al, al
    je StoreFound_end
    inc esi
    jmp StoreFind_end
    
StoreFound_end:
    inc esi
    call SkipSpaces
    mov edi, OFFSET tokenBuf
    
StoreCopy_var:
    mov al, [esi]
    test al, al
    jz StoreDone_copy
    cmp al, ' '
    je StoreDone_copy
    mov [edi], al
    inc esi
    inc edi
    jmp StoreCopy_var
    
StoreDone_copy:
    mov BYTE PTR [edi], 0
    mov esi, OFFSET tokenBuf
    pop eax
    call SetVar
    pop esi
    jmp ExitOK
    
StoreError:
    pop esi
    mov edx, OFFSET errMsg
    call WriteString
    jmp ExitOK
    
IsShow:
    pop esi
    push esi
    mov edi, OFFSET tokenBuf
    call GetToken
    mov esi, OFFSET tokenBuf
    call GetVar
    cmp edx, 1
    jne ShowError
    push eax
    mov edx, OFFSET tokenBuf
    call WriteString
    mov al, ' '
    call WriteChar
    mov al, '='
    call WriteChar
    mov al, ' '
    call WriteChar
    pop eax
    call WriteInt
    call Crlf
    pop esi
    jmp ExitOK
    
ShowError:
    pop esi
    jmp ExitOK
    
IsIncr:
    pop esi
    push esi
    add esi, 9
    call SkipSpaces
    mov edi, OFFSET tokenBuf
    call GetToken
    mov esi, OFFSET tokenBuf
    call GetVar
    cmp edx, 1
    jne IncrNew
    inc eax
    mov esi, OFFSET tokenBuf
    call SetVar
    pop esi
    jmp ExitOK
    
IncrNew:
    mov eax, 1
    mov esi, OFFSET tokenBuf
    call SetVar
    pop esi
    jmp ExitOK
    
ExitOK:
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    mov esp, ebp
    pop ebp
    
    mov edx, OFFSET traceExitExecSimple
    call WriteString
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
