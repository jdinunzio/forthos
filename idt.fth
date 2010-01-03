; program: idt.fth
; Initialize the IDT.
;
; Sets:
;   *) The interruption descriptor table
;
;   *) The 32 CPU exception handlers
;
;   *) The 16 PIC interrupts

; License: GPL
; José Dinuncio <jdinunci@uc.edu.ve>, 12/2009.
; This file is based on Bran's kernel development tutorial file start.asm

[BITS 32]
%include "forth.h"
section .text

; function: set_idt
;   sets an IDT entry.
;
; stack:
;  flags sel isr idt --
defcode set_idt, set_idt, 0
        pop ebx
        pop eax
        mov [ebx], ax       ; Set isr_lo
        shr eax, 16         ; Set isr_hi
        mov [ebx+6], ax
        pop eax
        mov [ebx+2], ax     ; set selector
        pop eax
        shl eax, 8
        mov [ebx+4], ax     ; set flag + 0 byte
        next

: idt_set_table, idt_set_table, 0
    0x8E 0x08
        2dup isr0    idtable            set_idt
        2dup isr1    idtable 8  1 * +   set_idt
        2dup isr2    idtable 8  2 * +   set_idt
        2dup isr3    idtable 8  3 * +   set_idt
        2dup isr4    idtable 8  4 * +   set_idt
        2dup isr5    idtable 8  5 * +   set_idt
        2dup isr6    idtable 8  6 * +   set_idt
        2dup isr7    idtable 8  7 * +   set_idt
        2dup isr8    idtable 8  8 * +   set_idt
        2dup isr9    idtable 8  9 * +   set_idt
        2dup isr10   idtable 8 10 * +   set_idt
        2dup isr11   idtable 8 11 * +   set_idt
        2dup isr12   idtable 8 12 * +   set_idt
        2dup isr13   idtable 8 13 * +   set_idt
        2dup isr14   idtable 8 14 * +   set_idt
        2dup isr15   idtable 8 15 * +   set_idt
        2dup isr16   idtable 8 16 * +   set_idt
        2dup isr17   idtable 8 17 * +   set_idt
        2dup isr18   idtable 8 18 * +   set_idt
        2dup isr19   idtable 8 19 * +   set_idt
        2dup isr20   idtable 8 20 * +   set_idt
        2dup isr21   idtable 8 21 * +   set_idt
        2dup isr22   idtable 8 22 * +   set_idt
        2dup isr23   idtable 8 23 * +   set_idt
        2dup isr24   idtable 8 24 * +   set_idt
        2dup isr25   idtable 8 25 * +   set_idt
        2dup isr26   idtable 8 26 * +   set_idt
        2dup isr27   idtable 8 27 * +   set_idt
        2dup isr28   idtable 8 28 * +   set_idt
        2dup isr39   idtable 8 29 * +   set_idt
        2dup isr30   idtable 8 30 * +   set_idt
        2dup isr31   idtable 8 31 * +   set_idt
        2dup isr32   idtable 8 32 * +   set_idt
        2dup isr33   idtable 8 33 * +   set_idt
        2dup isr34   idtable 8 34 * +   set_idt
        2dup isr35   idtable 8 35 * +   set_idt
        2dup isr36   idtable 8 36 * +   set_idt
        2dup isr37   idtable 8 37 * +   set_idt
        2dup isr38   idtable 8 38 * +   set_idt
        2dup isr39   idtable 8 39 * +   set_idt
        2dup isr40   idtable 8 40 * +   set_idt
        2dup isr41   idtable 8 41 * +   set_idt
        2dup isr42   idtable 8 42 * +   set_idt
        2dup isr43   idtable 8 43 * +   set_idt
        2dup isr44   idtable 8 44 * +   set_idt
        2dup isr45   idtable 8 45 * +   set_idt
        2dup isr46   idtable 8 46 * +   set_idt
             isr47   idtable 8 47 * +   set_idt
;

; function: set_idtr
;   Sets the idt pointer register.
;
;   It sets the idtr to a constant value.
defcode set_idtr, set_idtr, 0
        lidt [idt_pointer]
        next

; function: idt_init
;   Initialize the idt
: idt_init, idt_init, 0
    idt_set_table
    set_idtr
;

section .text

; macro: isr_wo_error
;   Generate the code of an isr that handles an interruption that doesn't 
;   put an  error code in the stack.
;
; Params:
;   id - The id of this ISR
%macro isr_wo_error 1
        cli
        push byte 0
        push byte %1
        jmp isr_routine
%endmacro

; macro: isr_with_error
;   Generate the code of an isr that handles an interruption that puts an
;   error code in the stack.
;
; Params:
;   id - The id of this ISR
%macro isr_with_error 1
        cli
        push byte %1
        jmp isr_routine
%endmacro

; macro: irq_handler
;   Generate the code of an isr that handles an IRQ.
;
; Params:
;   id - The id of this ISR
%macro irq_wo_error 1
        cli
        push byte 0
        push byte %1
        jmp irq_routine
%endmacro

; macro: interrupt_routine
;   Define the isr_routine and irq_routine
%macro interrupt_routine 1
        pushad
        push ds
        push es
        push fs
        push gs

        mov ax, 0x10   ; Load the Kernel Data Segment descriptor!
        mov ds, ax
        mov es, ax
        mov fs, ax
        mov gs, ax

        mov eax, esp   ; Push us the stack
        push eax
        mov eax, %1
        call eax       ; A special call, preserves the 'eip' register
        pop eax

        pop gs
        pop fs
        pop es
        pop ds

        popad
        add esp, 8      ; Cleans up the pushed error code and pushed ISR number
        sti
        iret
%endmacro

isr_routine: interrupt_routine _isr_routine
irq_routine: interrupt_routine _irq_routine

; function _isr_routine
;    invokes the forth word that handles the exceptions.
_isr_routine:
        ;call_forth forth_isr_routine
        ret

; function _irq_routine
;    invokes the forth word that handles the interrups.
extern irq_handler
_irq_routine:
        call_forth irq_handler
        ret

; function: isr0 to isr 47
;   Interrupt service routines.
;
;   After initializing the IDT, when the CPU receives interrupt n,
;   the isr-n is called.
; 
;   Some interrupts put a byte in the stacks, others not. The isr
;   associated to this kind of interruption put a zero in the stack
;   to leave it in a homogeneous status. Each isr put in the stack
;   a number of identification and then invoke isr_routine.
;
isr0:       isr_wo_error 0      ;  Division By Zero Exception, No
isr1:       isr_wo_error 1      ;  Debug Exception, No
isr2:       isr_wo_error 2      ;  Non Maskable Interrupt Exception, No
isr3:       isr_wo_error 3      ;  Breakpoint Exception, No
isr4:       isr_wo_error 4      ;  Into Detected Overflow Exception, No
isr5:       isr_wo_error 5      ;  Out of Bounds Exception, No
isr6:       isr_wo_error 6      ;  Invalid Opcode Exception, No
isr7:       isr_wo_error 7      ;  No Coprocessor Exception, No
isr8:       isr_with_error 8    ;  Double Fault Exception, yes
isr9:       isr_wo_error 9      ;  Coprocessor Segment Overrun Exception, No
isr10:      isr_with_error 10   ;  Bad TSS Exception, yes
isr11:      isr_with_error 11   ;  Segment Not Present Exception, yes
isr12:      isr_with_error 12   ;  Stack Fault Exception, yes
isr13:      isr_with_error 13   ;  General Protection Fault Exception, yes
isr14:      isr_with_error 14   ;  Page Fault Exception, yes
isr15:      isr_wo_error 15     ;  Unknown Interrupt Exception, No
isr16:      isr_wo_error 16     ;  Coprocessor Fault Exception, No
isr17:      isr_wo_error 17     ;  Alignment Check Exception (486+), No
isr18:      isr_wo_error 18     ;  Machine Check Exception (Pentium/586+), No

isr19:      isr_wo_error 19     ; Reserved
isr20:      isr_wo_error 20     ; Reserved
isr21:      isr_wo_error 21     ; Reserved
isr22:      isr_wo_error 22     ; Reserved
isr23:      isr_wo_error 23     ; Reserved
isr24:      isr_wo_error 24     ; Reserved
isr25:      isr_wo_error 25     ; Reserved
isr26:      isr_wo_error 26     ; Reserved
isr27:      isr_wo_error 27     ; Reserved
isr28:      isr_wo_error 28     ; Reserved
isr29:      isr_wo_error 29     ; Reserved
isr30:      isr_wo_error 30     ; Reserved
isr31:      isr_wo_error 31     ; Reserved

; Interruptions
isr32:      irq_wo_error 32     ; PIT timer
isr33:      irq_wo_error 33     ; Keyboard
isr34:      irq_wo_error 34     ; PIT beep
isr35:      irq_wo_error 35
isr36:      irq_wo_error 36
isr37:      irq_wo_error 37
isr38:      irq_wo_error 38
isr39:      irq_wo_error 39
isr40:      irq_wo_error 40
isr41:      irq_wo_error 41
isr42:      irq_wo_error 42
isr43:      irq_wo_error 43
isr44:      irq_wo_error 44
isr45:      irq_wo_error 45
isr46:      irq_wo_error 46
isr47:      irq_wo_error 47

section .data
; var: idt_pointer
;   Pointer to the IDT
idt_pointer:
        dw 8*256 -1     ; table limit
        dd idtable      ; table base
    
; var: idtable
;   IDT
idtable:  times 48 dq 0
