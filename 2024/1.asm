section .data
    buffer db 65536
    bufferSize equ 65536
    inputFn db "input/1.txt", 0
    c_newline db 10

section .text
global _start, buffer

_start:
    mov ebx, inputFn
    push bufferSize
    push buffer
    call rdFile                       ; filelen in eax
    add esp, 8                        ; clean up stack

getLine:
