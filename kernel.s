%include "forth_words.s"
%include "kernel_video.s"

[BITS 32]

; XXX: Mientras se hagan pruebas en kernel_video
; definimos esta variable aca
defconst SCREEN, SCREEN, 0, 0xB8000


; Assembly Entry point
section .text
GLOBAL main
main:
            mov ebp, return_stack_top   ; init the return stack
            mov esi, cold_start         ; fist foth word to exec
            NEXT
            ret

; Forth Entry point
section .rodata
cold_start:
            dd CLEAR
            LITN 5
            dd INK
            LITN bienvenida
            dd PRINTCSTRING
            LITN 15
            dd INK
            LITN osname
            dd PRINTCSTRING
            LITN 1
            LITN 8
            dd atx
            LITN colofon
            dd PRINTCSTRING
            dd STOP
section .data
bienvenida:     db 'Bienvenido a ', 0
osname          db 'Goyo-OS', 0
colofon         db 'Espere cosas grandes de Goyo-OS en el futuro...', 0


; stacks
section   .bss
align 4096
            RETURN_STACK_SIZE equ 8192
return_stack:
            resb RETURN_STACK_SIZE
return_stack_top:

