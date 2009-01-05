%include "forth_words.s"

defconst SCREEN, SCREEN, 0, screenbuffer

%include "kernel_video.s"

[BITS 32]
section .text
GLOBAL start
GLOBAL _start
_start:
start:
            mov ebp, return_stack_top   ; init the return stack
            mov esi, test               ; first foth word to exec
            NEXT                        ;

; Forth Entry point
section .rodata
test:

test_at_hw:
            dd CURSOR_POS_REL
            dd AT_HW
            dd SYS_EXIT


test_printcstring:
            LITN hola
            dd PRINTCSTRING
            dd SYS_EXIT
            section .data
hola:       db 'hola, mundo', 0


test_shr:
            LITN 0x12ab34de
            LITN 8
            dd SHR
            dd SYS_EXIT



defcode SYS_EXIT, SYS_EXIT, 0
            mov eax, 1                  ; Exit to the OS cleanly
            mov ebx, 0                  ; 
            int 0x80                    ;


; stacks
section   .bss
align 4096

screenbuffer:   
            resb 2000 ;80*25

return_stack:
            RETURN_STACK_SIZE equ 8192
            resb RETURN_STACK_SIZE
return_stack_top:

