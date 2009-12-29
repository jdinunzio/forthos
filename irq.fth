; program irq
;   Set the irq.

%include "forth.h"
%include "kernel_words.h"
%include "kernel_video.h"

[BITS 32]
global forth_irq_handler
%define _irqmsg irqmsg
: forth_irq_handler, forth_irq_handler, 0
   _irqmsg PRINTCSTRING CR
    # FIXME - unconditional clean
    0x20 0xA0 OUTB
    0x20 0x20 OUTB
;

section .rodata
irqmsg: db "An interrupt has been fired"
