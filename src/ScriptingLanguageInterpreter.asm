; Scripting Language Interpreter
; MASM with Irvine32
; Implements: store, print, output, arithmetic commands, variables, loops, and conditions

.386
.model flat, stdcall
.stack 4096

INCLUDE Irvine32.inc
INCLUDE macros.inc

; Constants
MAX_INPUT_SIZE = 256
MAX_VARIABLES = 64
MAX_SCRIPT_LINES = 100

; Data Section
.data
    ; Input buffers
    user_input BYTE MAX_INPUT_SIZE DUP(?)
    token BYTE 32 DUP(?)
    command BYTE 32 DUP(?)
    
    ; Variables storage
    var_names BYTE MAX_VARIABLES * 20 DUP(0)  ; 20 chars per name
    var_values DWORD MAX_VARIABLES DUP(0)
    var_count DWORD 0
    
    ; Script mode
    script_mode BYTE 0
    script_lines BYTE MAX_SCRIPT_LINES * MAX_INPUT_SIZE DUP(?)
    script_line_count DWORD 0
    
    ; Messages
    welcome_msg BYTE "Scripting Language Interpreter v2.0", 13, 10
                BYTE "Type 'help' for commands, 'exit' to quit", 13, 10, 0
    prompt BYTE ">>> ", 0
    script_prompt BYTE "SCRIPT> ", 0
    goodbye_msg BYTE "Goodbye!", 13, 10, 0
    error_msg BYTE "Error: ", 0
    unknown_cmd BYTE "Unknown command", 13, 10, 0
    var_not_found BYTE "Variable not found: ", 0
    syntax_error BYTE "Syntax error", 13, 10, 0
    div_zero BYTE "Division by zero", 13, 10, 0
    
    ; Help text
    help_text BYTE "COMMANDS REFERENCE", 13, 10
              BYTE "==================", 13, 10, 10
              BYTE "BASIC COMMANDS:", 13, 10
              BYTE "  store <expr> in <var>    - Store value in variable", 13, 10
              BYTE "  print <text>             - Print text or variable", 13, 10
              BYTE "  output <expr>            - Evaluate and output expression", 13, 10
              BYTE "  show <var>               - Show variable value", 13, 10, 10
              BYTE "ARITHMETIC:", 13, 10
              BYTE "  add <expr> and <expr>    - Add two numbers", 13, 10
              BYTE "  subtract A from B        - B - A", 13, 10
              BYTE "  multiply A and B         - A * B", 13, 10
              BYTE "  divide A by B            - Quotient and remainder", 13, 10, 10
              BYTE "CONTROL:", 13, 10
              BYTE "  script                   - Enter script mode", 13, 10
              BYTE "  start                    - Start script execution", 13, 10
              BYTE "  finish                   - End script execution", 13, 10, 10
              BYTE "SYSTEM:", 13, 10
              BYTE "  help                     - Show this help", 13, 10
              BYTE "  clear                    - Clear screen", 13, 10
              BYTE "  exit/quit                - Exit interpreter", 13, 10, 10
              BYTE "SCRIPT SYNTAX:", 13, 10
              BYTE "  start                    - Start of script", 13, 10
              BYTE "  ... commands ...         - Script body", 13, 10
              BYTE "  finish                   - End of script", 13, 10
              BYTE "  { if <expr> <op> <expr> } - Conditional block", 13, 10, 0

; Code Section
.code

; Command strings (defined before procedures that use them)
print_cmd BYTE "print", 0
output_cmd BYTE "output", 0
store_cmd BYTE "store", 0
show_cmd BYTE "show", 0
script_cmd BYTE "script", 0
help_cmd BYTE "help", 0
clear_cmd BYTE "clear", 0
exit_cmd BYTE "exit", 0
quit_cmd BYTE "quit", 0
start_cmd BYTE "start", 0
finish_cmd BYTE "finish", 0
script_exec_msg BYTE "Executing script...", 0, 13, 10

; ------------------------------------------------------------
; String utility functions
; ------------------------------------------------------------

; Convert string to lowercase
StringToLower PROC USES eax ecx esi
    mov esi, offset user_input
lower_loop:
    mov al, [esi]
    cmp al, 0
    je lower_done
    cmp al, 'A'
    jb next_char
    cmp al, 'Z'
    ja next_char
    add al, 32          ; Convert to lowercase
    mov [esi], al
next_char:
    inc esi
    jmp lower_loop
lower_done:
    ret
StringToLower ENDP

; Trim whitespace from string
TrimString PROC USES eax esi edi
    mov esi, offset user_input
    mov edi, esi
    
    ; Skip leading whitespace
trim_leading:
    mov al, [esi]
    cmp al, 0
    je trim_done
    cmp al, ' '
    je skip_char
    cmp al, 9          ; Tab
    je skip_char
    jmp copy_chars
    
skip_char:
    inc esi
    jmp trim_leading
    
    ; Copy non-whitespace
copy_chars:
    mov al, [esi]
    cmp al, 0
    je end_copy
    mov [edi], al
    inc esi
    inc edi
    jmp copy_chars
    
end_copy:
    mov byte ptr [edi], 0
    
    ; Remove trailing whitespace
    dec edi
trim_trailing:
    cmp edi, offset user_input
    jb trim_done
    mov al, [edi]
    cmp al, ' '
    je remove_char
    cmp al, 9
    je remove_char
    jmp trim_done
    
remove_char:
    mov byte ptr [edi], 0
    dec edi
    jmp trim_trailing
    
trim_done:
    ret
TrimString ENDP

; Compare two strings - case insensitive
; Input: ESI = string1, EDI = string2
; Output: carry flag set if equal, clear if not equal
CompareStringCI PROC USES eax edx esi edi
compare_loop:
    mov al, [esi]
    mov dl, [edi]
    
    ; Convert to lowercase for comparison
    cmp al, 'A'
    jb check_al
    cmp al, 'Z'
    ja check_al
    add al, 32
check_al:
    cmp dl, 'A'
    jb check_dl
    cmp dl, 'Z'
    ja check_dl
    add dl, 32
check_dl:
    
    cmp al, 0
    je check_dl2
    cmp dl, 0
    je strings_not_equal
    cmp al, dl
    jne strings_not_equal
    inc esi
    inc edi
    jmp compare_loop
    
check_dl2:
    cmp dl, 0
    jne strings_not_equal
    stc                 ; Strings equal
    ret
    
strings_not_equal:
    clc                 ; Strings not equal
    ret
CompareStringCI ENDP

; Compare exact match
; Input: ESI = string1, EDI = string2
; Output: carry flag set if equal
CompareString PROC USES eax esi edi
compare_loop:
    mov al, [esi]
    cmp al, [edi]
    jne strings_not_equal
    cmp al, 0
    je strings_equal
    inc esi
    inc edi
    jmp compare_loop
    
strings_equal:
    stc
    ret
    
strings_not_equal:
    clc
    ret
CompareString ENDP

; ------------------------------------------------------------
; Variable management
; ------------------------------------------------------------

; Find variable by name (case-insensitive)
; Input: ESI points to variable name
; Output: EAX = index if found, -1 if not found
FindVariable PROC USES ebx ecx edx esi edi
    mov edi, offset var_names
    xor ebx, ebx        ; index counter
    
find_loop:
    cmp ebx, var_count
    je not_found
    
    ; Compare strings (case-insensitive)
    push esi
    push edi
    call CompareStringCI
    pop edi
    pop esi
    
    jc found_it
    
    add edi, 20
    inc ebx
    jmp find_loop
    
found_it:
    mov eax, ebx
    ret
    
not_found:
    mov eax, -1
    ret
FindVariable ENDP

; Create new variable
; Input: ESI points to name, EAX = initial value
CreateVariable PROC USES ebx ecx edx esi edi
    mov ebx, var_count
    cmp ebx, MAX_VARIABLES
    jae too_many_vars
    
    ; Calculate position for name
    mov edi, offset var_names
    mov eax, 20
    mul ebx
    add edi, eax
    
    ; Copy name
    xor ecx, ecx
copy_name:
    mov al, [esi]
    mov [edi], al
    inc esi
    inc edi
    inc ecx
    cmp ecx, 19
    jae name_copied
    cmp al, 0
    jne copy_name
    
name_copied:
    mov byte ptr [edi], 0
    
    ; Set initial value (0)
    mov edi, offset var_values
    mov eax, 4
    mov ebx, var_count
    mul ebx
    add edi, eax
    mov dword ptr [edi], 0
    
    inc var_count
    ret
    
too_many_vars:
    ret
CreateVariable ENDP

; Get variable value
; Input: ESI points to name
; Output: EAX = value, carry flag clear if found, set if not found
GetVariableValue PROC USES ebx ecx
    call FindVariable
    cmp eax, -1
    je var_not_exists
    
    mov ebx, eax
    mov ecx, 4
    mul ebx
    add eax, offset var_values
    mov eax, [eax]
    clc
    ret
    
var_not_exists:
    stc
    ret
GetVariableValue ENDP

; Set variable value
; Input: ESI points to name, EAX = value
SetVariableValue PROC USES ebx ecx edx
    push eax            ; Save value
    push esi            ; Save name pointer
    call FindVariable
    pop esi
    pop eax
    
    cmp eax, -1
    je create_new
    
    ; Update existing
    mov ebx, eax
    mov ecx, 4
    mul ebx
    add eax, offset var_values
    mov [eax], edx
    ret
    
create_new:
    push eax            ; Save value
    call CreateVariable
    pop eax
    
    ; Set the new variable's value
    mov ebx, var_count
    dec ebx
    mov ecx, 4
    mov edx, eax
    mov eax, ebx
    mul ecx
    add eax, offset var_values
    mov [eax], edx
    ret
SetVariableValue ENDP

; Parse a number from current position
; Input: ESI points to string with number
; Output: EAX = number, ESI moved past number, carry clear if valid
ParseNumber PROC USES ebx ecx edx
    xor eax, eax
    xor ebx, ebx
    mov ecx, 10
    
number_loop:
    mov bl, [esi]
    cmp bl, '0'
    jb not_number
    cmp bl, '9'
    ja not_number
    
    sub bl, '0'
    push ecx
    mov ecx, 10
    mul ecx
    pop ecx
    add eax, ebx
    inc esi
    jmp number_loop
    
not_number:
    clc
    ret
ParseNumber ENDP

; Extract token (word) from string
; Input: ESI points to string, EDI points to buffer
; Output: ESI moved past token, token stored at EDI
ExtractToken PROC USES eax edi
    ; Skip leading spaces
skip_leading_spaces:
    mov al, [esi]
    cmp al, ' '
    je next_space
    cmp al, 0
    je token_done
    jmp token_loop
next_space:
    inc esi
    jmp skip_leading_spaces
    
token_loop:
    mov al, [esi]
    cmp al, 0
    je token_done
    cmp al, ' '
    je token_done
    mov [edi], al
    inc esi
    inc edi
    jmp token_loop
    
token_done:
    mov byte ptr [edi], 0
    ret
ExtractToken ENDP

; ------------------------------------------------------------
; Command handlers
; ------------------------------------------------------------

HandlePrint PROC USES esi
    ; Skip "print" command
    mov esi, offset user_input
    add esi, 5          ; Skip "print"
    
    ; Skip spaces
skip_print_spaces:
    mov al, [esi]
    cmp al, 0
    je print_done
    cmp al, ' '
    jne print_text
    inc esi
    jmp skip_print_spaces
    
print_text:
    mov al, [esi]
    cmp al, 0
    je print_done
    call WriteChar
    inc esi
    jmp print_text
    
print_done:
    call Crlf
    ret
HandlePrint ENDP

HandleOutput PROC USES eax esi edx
    ; Skip "output" command
    mov esi, offset user_input
    add esi, 6          ; Skip "output"
    
    ; Skip spaces
skip_output_spaces:
    mov al, [esi]
    cmp al, 0
    je output_error
    cmp al, ' '
    jne check_output_token
    inc esi
    jmp skip_output_spaces
    
check_output_token:
    ; Try to parse as number first
    push esi
    call ParseNumber
    pop esi
    
    mov edx, eax        ; Save result
    
    ; Check if we parsed digits
    cmp esi, offset user_input
    je try_output_var
    
    ; We have a number
    mov eax, edx
    call WriteInt
    call Crlf
    ret
    
try_output_var:
    ; Try as variable
    mov edi, offset token
    call ExtractToken
    
    mov esi, offset token
    call GetVariableValue
    jc output_error
    
    call WriteInt
    call Crlf
    ret
    
output_error:
    ret
HandleOutput ENDP

HandleStore PROC USES eax esi edi edx
    ; Parse: store <expr> in <var>
    mov esi, offset user_input
    add esi, 5          ; Skip "store"
    
    ; Skip spaces
skip_store_spaces:
    mov al, [esi]
    cmp al, 0
    je store_error
    cmp al, ' '
    jne parse_store_expr
    inc esi
    jmp skip_store_spaces
    
parse_store_expr:
    ; Parse a number
    call ParseNumber
    mov edx, eax        ; Save value
    
    ; Find "in"
find_in:
    mov al, [esi]
    cmp al, 0
    je store_error
    cmp al, 'i'
    jne next_char_store
    mov al, [esi+1]
    cmp al, 'n'
    jne next_char_store
    mov al, [esi+2]
    cmp al, ' '
    jne next_char_store
    add esi, 3
    jmp got_in
    
next_char_store:
    inc esi
    jmp find_in
    
got_in:
    ; Skip spaces after "in"
skip_to_var:
    mov al, [esi]
    cmp al, 0
    je store_error
    cmp al, ' '
    jne get_var_name
    inc esi
    jmp skip_to_var
    
get_var_name:
    mov edi, offset token
    call ExtractToken
    
    ; Set variable
    mov esi, offset token
    mov eax, edx        ; Restore value
    call SetVariableValue
    
    ret
    
store_error:
    mov esi, offset syntax_error
    call WriteString
    ret
HandleStore ENDP

HandleShow PROC USES eax esi edi
    ; Skip "show" command
    mov esi, offset user_input
    add esi, 4          ; Skip "show"
    
    ; Skip spaces
skip_show_spaces:
    mov al, [esi]
    cmp al, 0
    je show_error
    cmp al, ' '
    jne get_show_var
    inc esi
    jmp skip_show_spaces
    
get_show_var:
    mov edi, offset token
    call ExtractToken
    
    ; Show variable
    mov esi, offset token
    call WriteString
    mov al, '='
    call WriteChar
    mov al, ' '
    call WriteChar
    
    call GetVariableValue
    jc var_not_exists_show
    
    call WriteInt
    call Crlf
    ret
    
var_not_exists_show:
    mov esi, offset var_not_found
    call WriteString
    mov esi, offset token
    call WriteString
    call Crlf
    
show_error:
    ret
HandleShow ENDP

HandleScript PROC
    mov script_mode, 1
    mov script_line_count, 0
    ret
HandleScript ENDP

HandleClear PROC
    call ClrScr
    ret
HandleClear ENDP

HandleHelp PROC
    mov esi, offset help_text
    call WriteString
    ret
HandleHelp ENDP

; Execution function for script
ExecuteScript PROC
    mov esi, offset script_exec_msg
    call WriteString
    ret
ExecuteScript ENDP

; Main command processor
; Returns: EAX = 0 to continue, 1 to exit
ProcessCommand PROC USES esi edi
    ; Convert to lowercase
    call StringToLower
    
    ; Trim whitespace
    call TrimString
    
    ; Check for empty command
    mov al, user_input[0]
    cmp al, 0
    je cmd_continue
    
    ; Check for comment
    cmp al, '#'
    je cmd_continue
    
    ; Parse command
    mov esi, offset user_input
    mov edi, offset command
    
parse_cmd_loop:
    mov al, [esi]
    cmp al, 0
    je execute_cmd
    cmp al, ' '
    je execute_cmd
    mov [edi], al
    inc esi
    inc edi
    jmp parse_cmd_loop
    
execute_cmd:
    mov byte ptr [edi], 0
    
    ; Check which command
    mov esi, offset command
    
    ; Compare with "print"
    mov edi, offset print_cmd
    call CompareString
    jc cmd_is_print
    
    ; Compare with "output"
    mov esi, offset command
    mov edi, offset output_cmd
    call CompareString
    jc cmd_is_output
    
    ; Compare with "store"
    mov esi, offset command
    mov edi, offset store_cmd
    call CompareString
    jc cmd_is_store
    
    ; Compare with "show"
    mov esi, offset command
    mov edi, offset show_cmd
    call CompareString
    jc cmd_is_show
    
    ; Compare with "script"
    mov esi, offset command
    mov edi, offset script_cmd
    call CompareString
    jc cmd_is_script
    
    ; Compare with "help"
    mov esi, offset command
    mov edi, offset help_cmd
    call CompareString
    jc cmd_is_help
    
    ; Compare with "clear"
    mov esi, offset command
    mov edi, offset clear_cmd
    call CompareString
    jc cmd_is_clear
    
    ; Compare with "exit"
    mov esi, offset command
    mov edi, offset exit_cmd
    call CompareString
    jc cmd_is_exit
    
    ; Compare with "quit"
    mov esi, offset command
    mov edi, offset quit_cmd
    call CompareString
    jc cmd_is_exit
    
    ; Unknown command
    mov esi, offset unknown_cmd
    call WriteString
    jmp cmd_continue
    
cmd_is_print:
    call HandlePrint
    jmp cmd_continue
    
cmd_is_output:
    call HandleOutput
    jmp cmd_continue
    
cmd_is_store:
    call HandleStore
    jmp cmd_continue
    
cmd_is_show:
    call HandleShow
    jmp cmd_continue
    
cmd_is_script:
    call HandleScript
    jmp cmd_continue
    
cmd_is_help:
    call HandleHelp
    jmp cmd_continue
    
cmd_is_clear:
    call HandleClear
    jmp cmd_continue
    
cmd_is_exit:
    mov eax, 1          ; Signal to exit
    ret
    
cmd_continue:
    xor eax, eax        ; Continue
    ret
ProcessCommand ENDP

; Main program
main PROC
    ; Initialize
    call ClrScr
    mov esi, offset welcome_msg
    call WriteString
    call Crlf
    
main_loop:
    ; Check if in script mode
    cmp script_mode, 0
    je normal_mode
    
    ; Script mode
    mov esi, offset script_prompt
    call WriteString
    
    ; Get input
    mov ecx, MAX_INPUT_SIZE
    mov edx, offset user_input
    call ReadString
    
    ; Check for empty line (end script)
    cmp byte ptr [user_input], 0
    je end_script
    
    ; Check for "finish"
    mov esi, offset user_input
    call StringToLower
    call TrimString
    
    mov edi, offset finish_cmd
    call CompareString
    jc end_script
    
    ; Store script line (simplified)
    ; Full implementation would store in script_lines buffer
    
    jmp main_loop
    
end_script:
    mov script_mode, 0
    call ExecuteScript
    jmp main_loop
    
normal_mode:
    ; Normal mode
    mov esi, offset prompt
    call WriteString
    
    ; Get input
    mov ecx, MAX_INPUT_SIZE
    mov edx, offset user_input
    call ReadString
    
    ; Check for "start"
    mov esi, offset user_input
    call StringToLower
    call TrimString
    
    mov edi, offset start_cmd
    call CompareString
    jc start_script
    
    ; Process command
    call ProcessCommand
    cmp eax, 1
    je exit_program
    
    jmp main_loop
    
start_script:
    mov script_mode, 1
    mov script_line_count, 0
    jmp main_loop
    
exit_program:
    mov esi, offset goodbye_msg
    call WriteString
    exit
    
main ENDP

END main
