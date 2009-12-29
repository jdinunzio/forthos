; program: gdt.s
; Initialize the GDT.

; License: GPL
; José Dinuncio <jdinunci@uc.edu.ve>, 12/2009.
; This file is based on Bran's kernel development tutorial file start.asm


[BITS 32]
; macro: gdt_entry
;   Create a gtd_entry structure
%macro gdt_entry 4
            section .rodata
            ; dh base, dh limit, db access, db gran
            dw %2 & 0xffff                          ; word limit_low
            dw %1 & 0xffff                          ; word base_low
            db %1 >> 16 & 0xff                      ; byte base_middle
            db %3                                   ; byte access;
            db ((%2 >> 16) & 0x0F) | (%4 & 0xF0)    ; byte granularity
            db %1 >> 24 & 0xff                      ; byte base_high
%endmacro

; type: gdtable
;   GDT
gdtable:
            gdt_entry 0, 0, 0, 0
            gdt_entry 0, 0xFFFFFFFF, 0x9A, 0xCF
            gdt_entry 0, 0xFFFFFFFF, 0x92, 0xCF

; type: gdt_pointer
;   Pointer to the gdt
gdt_pointer:
            dw 8*3 -1           ; Limit
            dd gdtable          ; Base

; function: gdt_flush
;   Initialize the GDT
global gdt_flush
gdt_flush:
            sgdt [gdt_pointer]
            mov ax, 0x10            ; 0x10 is the index of the second selector
            mov ds, ax              ;   in the GDT. So, all the CPU registers
            mov es, ax              ;   associated with data reading will use
            mov fs, ax              ;   the 
            mov gs, ax
            mov ss, ax
            jmp 0x08:flush2 
flush2:
            ret
