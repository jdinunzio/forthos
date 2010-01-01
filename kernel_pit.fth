; program: pit
;   Initialize the Programmable Interruption Timer

; License: GPL
; José Dinuncio <jdinunci@uc.edu.ve>, 12/2009.
; This file is based on Bran's kernel development tutorial file start.asm


[BITS 32]
%include "forth.h"
%include "kernel_words.h"


global pit_init
pit_init:
    call_forth pit_init_
    ret

: pit_init_, pit_init_, 0
    0x43 0x36 OUTB
    21931800  DUP hi SWAP lo
        0x40 OUTB   0x40 OUTB
;
