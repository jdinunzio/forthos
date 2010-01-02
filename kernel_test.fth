; program: kernel_test
; Test for the kernel.

; License: GPL
; José Dinuncio <jdinunci@uc.edu.ve>, 12/2009.

%include "forth.h"
%include "kernel_words.h"
%include "kernel_video.h"
%include "kernel_kbd.h"

[BITS 32]
: print_scancodes, print_scancodes, 0
    begin KBD_SCANCODE intprint SPC 0 until
;

: print_interrupt, print_interrupt, 0
    fault PRINTCSTRING CR 
;

; prints an idt entry
: print_idtentry, print_idtentry, 0
    DUP 4 + @   SWAP @              # wh wl
    DUP hi hexprint SPC             # sel
        lo hexprint SPC             # base lo
    DUP hi hexprint SPC             # base hi
        lo 8 SHR hexprint CR        # flags
;

; test irq
defcode test_irq, test_irq, 0
    int 33
    NEXT

; divide by zero
: div_by_zero, div_by_zero, 0
    2 0 / DROP
;

; Print hello word
: print_hello, print_hello, 0
    hello PRINTCSTRING CR
;

%define _invoke_addr print_hello
: test_invoke, test_invoke, 0
    _invoke_addr EXECUTE
;

; function: MAIN
;   The first forth word iexecuted by the kernel.
: MAIN_TEST, MAIN_TEST, 0
    CLEAR
    0x101006 print_idtentry
    0x10100E print_idtentry
    0x101016 print_idtentry
    # print_hello
    #test_invoke
    print_scancodes
;

section .rodata
hello:  db "hello, world", 0
fault:  db "A fault happened", 0

