; program irq
;   Set the irq.

%include "forth.h"
%include "kernel_words.h"
%include "kernel_video.h"

[BITS 32]
global forth_irq_handler

;   -- isr_no isr_err
defcode isr_info, isr_info, 0
    mov eax, [esp + 64]
    push eax
    mov eax, [esp + 64]
    push eax
    NEXT

%define SPC ' '
%define _irqmsg irqmsg
%define _irqmsg2 irqmsg2
: forth_irq_handler, forth_irq_handler, 0
   _irqmsg PRINTCSTRING
   isr_info  intprint SPC EMIT   intprint SPC EMIT
   _irqmsg2 PRINTCSTRING CR
    # FIXME - unconditional clean
    0x20 0xA0 OUTB
    0x20 0x20 OUTB
;

section .rodata
irqmsg: db "The interrupt (", 0
irqmsg2: db ") has been fired", 0
