; Sets the global descritor table

[BITS 32]

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

gdtable:
            gdt_entry 0, 0, 0, 0
            gdt_entry 0, 0xFFFFFFFF, 0x9A, 0xCF
            gdt_entry 0, 0xFFFFFFFF, 0x92, 0xCF

gdt_pointer:
            dw 8*3 -1           ; Limit
            dd gdtable          ; Base


[GLOBAL gdt_flush]
gdt_flush:
            sgdt [gdt_pointer]
            mov ax, 0x10      
            mov ds, ax
            mov es, ax
            mov fs, ax
            mov gs, ax
            mov ss, ax
            jmp 0x08:flush2 
flush2:
            ret
 
