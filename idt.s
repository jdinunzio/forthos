; Sets:
;   *) The interruption descriptor table
;   *) The 32 CPU exception handlers
;   *) The 16 PIC interrupts

[BITS 32]

%macro idt_entry 3
            ; base, sel, flags
            %xdefine base %1
            dw base & 0xffff          ; dw base_lo
            dw %2                   ; dw sel
            db 0                    ; db always0
            db %3                   ; db flags
            dw base >> 16 & 0xffff    ; dw base_high
%endmacro

%macro set_idt 2
            ; addr, base
            mov ebx, %1
            mov eax, %2
            mov [ebx], ax
            xchg eax, ebx
            add eax, 6
            xchg eax, ebx
            shr eax, 16
            mov [ebx], ax
%endmacro

%macro isr_wo_error 1
            push byte 0
            push byte %1
            jmp isr_routine
%endmacro

%macro isr_with_error 1
            push byte %1
            jmp isr_routine
%endmacro

%macro irq_handler 1
            cli
            push byte 0
            push byte %1
            jmp irq_routine
%endmacro

[GLOBAL idt_load]
idt_load:
            set_idt idtable, isr0
            set_idt idtable + 8, isr1
            set_idt idtable + 8*2, isr2
            set_idt idtable + 8*3, isr3
            set_idt idtable + 8*4, isr4
            set_idt idtable + 8*5, isr5
            set_idt idtable + 8*6, isr6
            set_idt idtable + 8*7, isr7
            set_idt idtable + 8*8, isr8
            set_idt idtable + 8*9, isr9
            set_idt idtable + 8*10, isr10
            set_idt idtable + 8*11, isr11
            set_idt idtable + 8*12, isr12
            set_idt idtable + 8*13, isr13
            set_idt idtable + 8*14, isr14
            set_idt idtable + 8*15, isr15
            set_idt idtable + 8*16, isr16
            set_idt idtable + 8*17, isr17
            set_idt idtable + 8*18, isr18
            set_idt idtable + 8*19, isr19
            set_idt idtable + 8*20, isr20
            set_idt idtable + 8*21, isr21
            set_idt idtable + 8*22, isr22
            set_idt idtable + 8*23, isr23
            set_idt idtable + 8*24, isr24
            set_idt idtable + 8*25, isr25
            set_idt idtable + 8*26, isr26
            set_idt idtable + 8*27, isr27
            set_idt idtable + 8*28, isr28
            set_idt idtable + 8*29, isr29
            set_idt idtable + 8*30, isr30
            set_idt idtable + 8*31, isr31

            ; Interruptions
            set_idt idtable + 8*32, isr32
            set_idt idtable + 8*33, isr33
            set_idt idtable + 8*34, isr34
            set_idt idtable + 8*35, isr35
            set_idt idtable + 8*36, isr36
            set_idt idtable + 8*37, isr37
            set_idt idtable + 8*38, isr38
            set_idt idtable + 8*39, isr39
            set_idt idtable + 8*40, isr40
            set_idt idtable + 8*41, isr41
            set_idt idtable + 8*42, isr42
            set_idt idtable + 8*43, isr43
            set_idt idtable + 8*44, isr44
            set_idt idtable + 8*45, isr45
            set_idt idtable + 8*46, isr46
            set_idt idtable + 8*47, isr47

            sidt [idt_pointer]
            ret


section .data
idt_pointer:
            dw 8*256 -1    ; table limit
            dd idtable      ; table base
    

idtable:
             idt_entry 0, 0x08, 0x8E            
             idt_entry 0, 0x08, 0x8E            
             idt_entry 0, 0x08, 0x8E            
             idt_entry 0, 0x08, 0x8E            
             idt_entry 0, 0x08, 0x8E            
             idt_entry 0, 0x08, 0x8E            
             idt_entry 0, 0x08, 0x8E            
             idt_entry 0, 0x08, 0x8E            
             idt_entry 0, 0x08, 0x8E            
             idt_entry 0, 0x08, 0x8E            
             idt_entry 0, 0x08, 0x8E            
             idt_entry 0, 0x08, 0x8E            
             idt_entry 0, 0x08, 0x8E            
             idt_entry 0, 0x08, 0x8E            
             idt_entry 0, 0x08, 0x8E            
             idt_entry 0, 0x08, 0x8E            
             idt_entry 0, 0x08, 0x8E            
             idt_entry 0, 0x08, 0x8E            
             idt_entry 0, 0x08, 0x8E            
             idt_entry 0, 0x08, 0x8E            
             idt_entry 0, 0x08, 0x8E            
             idt_entry 0, 0x08, 0x8E            
             idt_entry 0, 0x08, 0x8E            
             idt_entry 0, 0x08, 0x8E            
             idt_entry 0, 0x08, 0x8E            
             idt_entry 0, 0x08, 0x8E            
             idt_entry 0, 0x08, 0x8E            
             idt_entry 0, 0x08, 0x8E            
             idt_entry 0, 0x08, 0x8E            
             idt_entry 0, 0x08, 0x8E            
             idt_entry 0, 0x08, 0x8E            
             idt_entry 0, 0x08, 0x8E            

             idt_entry 0, 0x08, 0x8E            
             idt_entry 0, 0x08, 0x8E            
             idt_entry 0, 0x08, 0x8E            
             idt_entry 0, 0x08, 0x8E            
             idt_entry 0, 0x08, 0x8E            
             idt_entry 0, 0x08, 0x8E            
             idt_entry 0, 0x08, 0x8E            
             idt_entry 0, 0x08, 0x8E            
             idt_entry 0, 0x08, 0x8E            
             idt_entry 0, 0x08, 0x8E            
             idt_entry 0, 0x08, 0x8E            
             idt_entry 0, 0x08, 0x8E            
             idt_entry 0, 0x08, 0x8E            
             idt_entry 0, 0x08, 0x8E            
             idt_entry 0, 0x08, 0x8E            
             idt_entry 0, 0x08, 0x8E            
section .text

isr0:       isr_wo_error 0      ;  Division By Zero Exception, No
isr1:       isr_wo_error 1      ;  Debug Exception, No
isr2:       isr_wo_error 2      ;  Non Maskable Interrupt Exception, No
isr3:       isr_wo_error 3      ;  Breakpoint Exception, No
isr4:       isr_wo_error 4      ;  Into Detected Overflow Exception, No
isr5:       isr_wo_error 5      ;  Out of Bounds Exception, No
isr6:       isr_wo_error 6      ;  Invalid Opcode Exception, No
isr7:       isr_wo_error 7      ;  No Coprocessor Exception, No
isr8:       isr_with_error 8    ;  Double Fault Exception, Yes
isr9:       isr_wo_error 9      ;  Coprocessor Segment Overrun Exception, No
isr10:      isr_with_error 10   ;  Bad TSS Exception, Yes
isr11:      isr_with_error 11   ;  Segment Not Present Exception, Yes
isr12:      isr_with_error 12   ;  Stack Fault Exception, Yes
isr13:      isr_with_error 13   ;  General Protection Fault Exception, Yes
isr14:      isr_with_error 14   ;  Page Fault Exception, Yes
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
isr32:      irq_handler 32      
isr33:      irq_handler 33      
isr34:      irq_handler 34      
isr35:      irq_handler 35      
isr36:      irq_handler 36      
isr37:      irq_handler 37      
isr38:      irq_handler 38      
isr39:      irq_handler 39      
isr40:      irq_handler 40      
isr41:      irq_handler 41      
isr42:      irq_handler 42      
isr43:      irq_handler 43      
isr44:      irq_handler 44      
isr45:      irq_handler 45      
isr46:      irq_handler 46      
isr47:      irq_handler 47      

isr_routine:
    pusha
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

        ; mov eax, _fault_handler
        ; call eax       ; A special call, preserves the 'eip' register

    pop eax
    pop gs
    pop fs
    pop es
    pop ds
    popa
    add esp, 8     ; Cleans up the pushed error code and pushed ISR number
    iret 

irq_routine:
    pusha
    push ds
    push es
    push fs
    push gs
    mov ax, 0x10
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov eax, esp
    push eax
    
        ; mov eax, _irq_handler
        ; call eax

    pop eax
    pop gs
    pop fs
    pop es
    pop ds
    popa
    add esp, 8
    iret

