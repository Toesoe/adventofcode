; nasm syntax, x86, linux syscalls

section .data
    errMsg db "Error reading file!", 10, 0

section .bss
    fd resd 1
    bufIdx resd 1
    buffer resb 0xFF
    outstring resb 0xFF ; max 256b strings

section .text
global setupFile, closeFile, readChunk, readLine

; open a file (filename in ebx)
; length of file is retured in eax
setupFile:
    mov eax, 5                          ; sys_open
    mov ecx, 0                          ; O_RDONLY
    int 0x80                            ; do syscall
    cmp eax, 0                          ; get errno
    js handle_error
    mov [fd], eax                       ; store fd
    ret

closeFile:
    mov eax, 6                          ; sys_close
    mov ebx, [fd]
    int 0x80
    ret

readChunk:
    mov eax, 3                          ; sys_read
    mov ebx, [fd]
    lea ecx, buffer
    mov edx, 0xFF
    int 0x80
    cmp eax, 0                          ; get errno
    js handle_error
    mov dword [bufIdx], 0

; read a line.
readLine:
    cmp eax, 0
    je _eol                             ; jump out if we haven't read anything
    mov ecx, eax                        ; ecx holds the number of bytes read
    mov edx, [bufIdx]                   ; current srcbuffer index
    lea ebx, [buffer + edx]             ; srcbuffer pointer
    lea edx, [outstring + edx]          ; destbuffer pointer

    _getNextChar:
        mov al, byte [ebx]
        cmp al, 0xA                     ; check for LF
        je _eol
        cmp al, 0xD                     ; check for CR
        je _eol
        mov byte [edx], al              ; store byte in output buffer
        inc edx
        inc ebx
        dec ecx
        jg _getNextChar

    ; no newline found, or buffer empty. read more data
    jmp readChunk

_eol:
    mov byte [ebx + 1], 0               ; null terminate string
    lea eax, [outstring]                ; return pointer to start of line
    ret

handle_error:
    ; Write error message (sys_write)
    call closeFile
    mov eax, 4                          ; sys_write
    mov ebx, 1                          ; stdout
    mov ecx, errMsg
    mov edx, 19
    int 0x80

    ; Exit with error code
    mov eax, 1                          ; sys_exit
    mov ebx, 1                          ; status 1
    int 0x80