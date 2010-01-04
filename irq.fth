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

        ; test - Disable all interrupts but keyboard and clock
        mov al, 0xfc
        out 0x21, al
        mov al, 0xff
        out 0xa1, al
        sti
        next

; function: isr_info
;   Returns the isr id and isr error code
;
; stack:
;  {isr info} -- {isr info} isr_no isr_err
defcode isr_info, isr_info, 0
    mov eax, [esp + 64]
    push eax
    mov eax, [esp + 64]
    push eax
    next

; function: irq_handler
;   Handles all interruptions
;
; stack:
;   {isr info} -- {isr info}
: irq_handler, irq_handler, 0
    isr_info swap drop  4 * isr_table + @
    dup 0<> if execute else drop then

    ; FIXME - unconditional clean
    0x20 0xA0 outb
    0x20 0x20 outb
;

; function: register_isr_handler
;   Register a handler for an irq.
;
; stack:
;   addr i --
: register_isr_handler, register_isr_handler, 0
    4 *  isr_table + !
;

section .data
; table: isr_table
;   Table of the routines that handle an isr
isr_table: times 48 dq 0
