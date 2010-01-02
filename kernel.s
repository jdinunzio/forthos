; program: kernel
; by José Dinuncio <jdinunci@uc.edu.veZ
; 12/2009

%include "forth.h"
global MAIN
extern MAIN_TEST

[BITS 32]
section .text

; function: main
;   Initialize the forth machinery.
;
global main
main:
			mov [var_S0], esp 			; Save the initial data stack pointer in FORTH variable S0.
            mov ebp, return_stack_top   ; init the return stack
            mov esi, cold_start         ; fist foth word to exec
            NEXT

section .rodata

; Bridge to the forth's word MAIN
cold_start:
            dd MAIN

; function: main
;   Firts foth word to be executed by the kernel
extern pit_init
extern irq_init
extern idt_init
defword  MAIN, MAIN, 0
        dd idt_init
        dd pit_init
        dd irq_init
        dd MAIN_TEST
        dd EXIT


; stacks
section   .bss
align 4096
            RETURN_STACK_SIZE equ 8192
return_stack:
            resb RETURN_STACK_SIZE
return_stack_top:

