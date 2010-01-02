; program irq
;   Set the irq.

%include "forth.h"
%include "kernel_words.h"
%include "kernel_video.h"

[BITS 32]
global forth_irq_handler
%define _irqmsg irqmsg
%define _irqmsg2 irqmsg2

; function: irq_init
;   Initialize the IRQ handling.
defcode irq_init, irq_init, 0
        ; Magic happens here
        mov al, 0x11
        out 0x20, al
        out 0xA0, al
        mov al, 0x20
        out 0x21, al
        mov al, 0x28
        out 0xA1, al
        mov al, 0x04
        out 0x21, al
        mov al, 0x02
        out 0xA1, al
        mov al, 0x01
        out 0x21, al
        out 0xA1, al
        mov al, 0
        out 0x21, al
        out 0xA1, al

        ; TEST - Disable all interrupts but keyboard and clock
        mov al, 0xfc
        out 0x21, al
        mov al, 0xff
        out 0xa1, al
        sti
        NEXT

; function: isr_info
;   Returns the isr id and isr error code
;
; stack:
;  {isr info} -- isr_no isr_err
defcode isr_info, isr_info, 0
    mov eax, [esp + 64]
    push eax
    mov eax, [esp + 64]
    push eax
    NEXT

; function: irq_handler
;   Handles all interruptions
: irq_handler, irq_handler, 0
   _irqmsg PRINTCSTRING
   isr_info  intprint SPC    intprint  
   _irqmsg2 PRINTCSTRING CR
    # FIXME - unconditional clean
    0x20 0xA0 OUTB
    0x20 0x20 OUTB
;

section .rodata
irqmsg: db "The interrupt (", 0
irqmsg2: db ") has been fired", 0
