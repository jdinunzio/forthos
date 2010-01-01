; program: kernel_words
; Useful words for kernel management.

; License: GPL
; José Dinuncio <jdinunci@uc.edu.ve>, 12/2009.

%include "forth.h"

[BITS 32]
; function: OUTB
;   Executes an out assembly instruction
;
; Stack:
;   val port --
;
; Parameters:
;   val - The value to out. Byte.
;   port - The port to output the value. int16.
defcode OUTB, OUTB, 0
        pop edx
        pop eax
        out dx, al
        NEXT

; function: INB
;   Executes an IN assembly instruction
;
; Stack:
;   port -- val
defcode INB, INB, 0
        pop edx
        xor eax, eax
        in  al, dx
        push eax
        NEXT

; b3b2b1b0 -- 0000b1b0
: lo, lo, 0
    0xFFFF AND
;

; b3b2b1b0 -- 0000b1b0
: hi, hi, 0
    16 SHR 0xFFFF AND
;


