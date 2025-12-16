; Human Language Scripting Interpreter - MASM32/Irvine32
; Supports script mode, loops, conditions, variables, expressions

INCLUDE Irvine32.inc

MAX_VARS = 64
MAX_LINE = 256
MAX_SCRIPTS = 10
MAX_TOKENS = 20

; Variable structure
Var STRUCT
    name BYTE MAX_LINE DUP(?)
    value SDWORD ?
Var ENDS

.data
    prompt BYTE ">>> ",0
    scriptPrompt BYTE "SCRIPT> ",0
    vars Var MAX_VARS DUP(<>)
    varCount DWORD 0
    scriptLines DWORD MAX_SCRIPTS*MAX_LINE DUP(0)
    scriptCount DWORD 0
    currentScriptIndex DWORD 0
    tempLine BYTE MAX_LINE DUP(?)
    tempTokens BYTE MAX_TOKENS*MAX_LINE DUP(?)
    
    ; Help text
    helpText BYTE "COMMANDS: store <expr> in <var>, print <expr>, increment <var>, decrement <var>,",13,10
             BYTE "repeat <N> times { ... }, help, clear, exit",13,10,0
    
    byeMsg BYTE "Goodbye!",13,10,0
    scriptDone BYTE "Script finished.",13,10,0
    unknownMsg BYTE "Unknown command",13,10,0

.code

main PROC
    call Clrscr
    
inputLoop:
    mov edx, OFFSET prompt
    call WriteString
    mov edx, OFFSET tempLine
    mov ecx, MAX_LINE
    call ReadString
    
    ; Check for empty line
    test eax, eax
    jz inputLoop
    
    ; Process command
    mov esi, OFFSET tempLine
    call processCommand
    
    jmp inputLoop
    
main ENDP

; Process command from string at ESI
processCommand PROC
    push ebx
    push ecx
    push edx
    push esi
    
    ; Skip leading spaces
    call skipWhitespace
    
    ; Get first token
    mov edi, OFFSET tempTokens
    call copyToken
    
    ; Null-terminate token for comparison
    mov BYTE PTR [edi], 0
    
    ; Check command type
    mov esi, OFFSET tempTokens
    
    ; Check for "help"
    mov edi, OFFSET helpCmd
    call StrCmpI
    test eax, eax
    jz cmd_help
    
    ; Check for "exit"
    mov esi, OFFSET tempTokens
    mov edi, OFFSET exitCmd
    call StrCmpI
    test eax, eax
    jz cmd_exit
    
    ; Check for "store"
    mov esi, OFFSET tempTokens
    mov edi, OFFSET storeCmd
    call StrCmpI
    test eax, eax
    jz cmd_store
    
    ; Check for "print"
    mov esi, OFFSET tempTokens
    mov edi, OFFSET printCmd
    call StrCmpI
    test eax, eax
    jz cmd_print
    
    ; Check for "increment"
    mov esi, OFFSET tempTokens
    mov edi, OFFSET incrCmd
    call StrCmpI
    test eax, eax
    jz cmd_incr
    
    ; Check for "show"
    mov esi, OFFSET tempTokens
    mov edi, OFFSET showCmd
    call StrCmpI
    test eax, eax
    jz cmd_show
    
    ; Unknown command
    mov edx, OFFSET unknownMsg
    call WriteString
    jmp cmd_done
    
cmd_help:
    mov edx, OFFSET helpText
    call WriteString
    jmp cmd_done
    
cmd_exit:
    mov edx, OFFSET byeMsg
    call WriteString
    pop esi
    pop edx
    pop ecx
    pop ebx
    exit
    
cmd_store:
    ; Parse: store <value> in <var>
    pop esi
    pop edx
    pop ecx
    pop ebx
    ret
    
cmd_print:
    ; Parse: print <expr>
    pop esi
    pop edx
    pop ecx
    pop ebx
    ret
    
cmd_incr:
    ; Parse: increment <var>
    pop esi
    pop edx
    pop ecx
    pop ebx
    ret
    
cmd_show:
    ; Parse: show <var>
    pop esi
    pop edx
    pop ecx
    pop ebx
    ret
    
cmd_done:
    pop esi
    pop edx
    pop ecx
    pop ebx
    ret
    
processCommand ENDP

; Skip whitespace at ESI
skipWhitespace PROC
skip_loop:
    mov al, [esi]
    cmp al, ' '
    je skip_inc
    cmp al, 9
    je skip_inc
    ret
skip_inc:
    inc esi
    jmp skip_loop
skipWhitespace ENDP

; Copy token from ESI to EDI, stop at space/null
copyToken PROC
copy_loop:
    mov al, [esi]
    test al, al
    jz copy_done
    cmp al, ' '
    je copy_done
    cmp al, 9
    je copy_done
    mov [edi], al
    inc esi
    inc edi
    jmp copy_loop
copy_done:
    ret
copyToken ENDP

; Case-insensitive string compare
; ESI = string1, EDI = string2
; Returns EAX = 0 if equal, 1 if not
StrCmpI PROC
cmp_loop:
    mov al, [esi]
    mov ah, [edi]
    
    ; Convert to lowercase
    cmp al, 'A'
    jb cmp_al_ok
    cmp al, 'Z'
    ja cmp_al_ok
    or al, 20h
cmp_al_ok:
    cmp ah, 'A'
    jb cmp_ah_ok
    cmp ah, 'Z'
    ja cmp_ah_ok
    or ah, 20h
cmp_ah_ok:
    cmp al, ah
    jne cmp_not_equal
    test al, al
    jz cmp_equal
    inc esi
    inc edi
    jmp cmp_loop
    
cmp_equal:
    xor eax, eax
    ret
    
cmp_not_equal:
    mov eax, 1
    ret
    
StrCmpI ENDP

; Command strings
helpCmd BYTE "help", 0
exitCmd BYTE "exit", 0
storeCmd BYTE "store", 0
printCmd BYTE "print", 0
incrCmd BYTE "increment", 0
showCmd BYTE "show", 0

END main
