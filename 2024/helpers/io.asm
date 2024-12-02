; nasm syntax, x86, linux syscalls

section .data
    errMsg db "Error reading file!", 10, 0

section .bss
    fd resd 1                           ; File descriptor (uninitialized)

section .text
global rdFile

; read a file (filename in ebx) into a buffer passed in ecx, length in edx.
; length of file is retured in eax, buffer in ecx
rdFile:
    ; open file
    pop ecx                             ; get buffer
    pop edx                             ; buffer size
    mov eax, 5                          ; sys_open
    mov ecx, 0                          ; O_RDONLY
    int 0x80                            ; do syscall
    cmp eax, 0                          ; get errno
    js handle_error
    mov [fd], eax                       ; store fd

    ; read file
    mov eax, 3                          ; sys_read
    mov ebx, [fd]
    mov ecx, readBuffer
    mov edx, 65536                      ; buffer size
    int 0x80                            ; do syscall
    cmp eax, 0                          ; get errno
    js handle_error
    ret

handle_error:
    ; Write error message (sys_write)
    mov eax, 4                          ; sys_write
    mov ebx, 1                          ; stdout
    mov ecx, errMsg
    mov edx, 19
    int 0x80

    ; Exit with error code
    mov eax, 1                          ; sys_exit
    mov ebx, 1                          ; status 1
    int 0x80