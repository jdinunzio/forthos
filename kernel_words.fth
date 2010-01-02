; program: kernel_words
; Useful words for kernel management.

; License: GPL
; José Dinuncio <jdinunci@uc.edu.ve>, 12/2009.

%include "forth.h"

[BITS 32]
; function: outb
;   Executes an out assembly instruction
;
; Stack:
;   val port --
;
; Parameters:
;   val - The value to out. Byte.
;   port - The port to output the value. int16.
defcode outb, outb, 0
        pop edx
        pop eax
        out dx, al
        next

; function: inb
;   Executes an IN assembly instruction
;
; Stack:
;   port -- val
defcode inb, inb, 0
        pop edx
        xor eax, eax
        in  al, dx
        push eax
        next

; b3b2b1b0 -- 0000b1b0
: lo, lo, 0
    0xFFFF and
;

; b3b2b1b0 -- 0000b1b0
: hi, hi, 0
    16 shr 0xFFFF and
;


