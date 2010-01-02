; program: test
;   Used to test words as they are developed


%include "forth.h"

[BITS 32]
section .text

GLOBAL _start
_start:
			mov [var_S0], esp 			; Save the initial data stack pointer in FORTH variable S0.
            mov ebp, return_stack_top   ; init the return stack
            mov esi, cold_start         ; fist foth word to exec
            next

; Forth Entry point
section .rodata
cold_start:
            dd main

: test_add, test_add, 0
    2 2 + drop
;


%define _invoke_addr invoke_addr
: test_invoke, test_invoke, 0
    _invoke_addr execute
;

GLOBAL main
: main, main, 0
    test_invoke
;



; stacks
section   .bss
align 4096
            RETURN_STACK_SIZE equ 8192
return_stack:
            resb RETURN_STACK_SIZE
return_stack_top:


; data
section .rodata
_invoke_addr: dd test_add
