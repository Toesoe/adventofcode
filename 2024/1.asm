section .data
    inputFn db "2024/input/1.txt", 0

section .text
global _start
extern setupFile, closeFile, readChunk, readLine

_start:
    mov ebx, inputFn
    call setupFile
    call readChunk                    ; gives us the location of the first newline in edi

    ; do stuff
    call readLine                     ; next line. eax contains start, ebx the length