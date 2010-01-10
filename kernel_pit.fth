; program: pit
;   Initialize the Programmable Interruption Timer

; License: GPL
; José Dinuncio <jdinunci@uc.edu.ve>, 12/2009.
; This file is based on Bran's kernel development tutorial file start.asm


[BITS 32]
%include "forth.h"
%include "kernel_words.h"

; function: pit_init
;   Initializes the PIT clock
;
; stack:
;   f --
: pit_init, pit_init, 0
    1193180 swap /      ( calculates our divisor )
    dup  1 n_byte       ( get byte1 of divisor )
    swap 0 n_byte       ( get byte0 of divisor )
    0x36 0x43 outb
         0x40 outb   
         0x40 outb
;
