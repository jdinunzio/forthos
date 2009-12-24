; program: kernel
; by José Dinuncio <jdinunci@uc.edu.veZ
; 12/2009

%include "forth.h"
extern MAIN

[BITS 32]
; Assembly Entry point
section .text
GLOBAL main
main:
			mov [var_S0], esp 			; Save the initial data stack pointer in FORTH variable S0.
            mov ebp, return_stack_top   ; init the return stack
            mov esi, cold_start         ; fist foth word to exec
            NEXT

; Forth Entry point
section .rodata
cold_start:
            dd MAIN



; stacks
section   .bss
align 4096
            RETURN_STACK_SIZE equ 8192
return_stack:
            resb RETURN_STACK_SIZE
return_stack_top:

