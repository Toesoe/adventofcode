section .data
    inputFn db "2024/input/1.txt", 0

section .text
global _start
extern setupFile, closeFile, readChunk, readLine

_start:
    mov ebx, inputFn
    call setupFile
    call readChunk                      ; returns a null terminated single line in eax

parseNumber:
    mov ebx, 0
    mov ecx, 0
    mov edx, 0
    _nextChar:
        mov bl, byte [eax]             ; get first char
        cmp bl, 0x20                   ; check for space
        je storeNumber
        sub bl, '0'                    ; convert to number
        imul ecx, ecx, 10
        add ecx, ebx
        inc eax
        jmp _nextChar

storeNumber:
    ; store ECX, left list
    inc edx
    cmp edx, 2
    je rightList
    add eax, 3                          ; skip spaces
    jmp parseNumber
    rightList:
        ; store number in right list
        call readLine
        mov edx, 0
        jmp parseNumber

; do stuff: find smallest numbers in both lists