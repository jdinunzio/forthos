; program: kernel_test
; Test for the kernel.

; License: GPL
; José Dinuncio <jdinunci@uc.edu.ve>, 12/2009.

%include "forth.h"
%include "kernel_words.h"
%include "kernel_video.h"
%include "kernel_kbd.h"
%include "irq.h"

[BITS 32]
: print_scancode, print_scancode, 0
    kbd_scancode intprint spc
;

defvar tic_count, tic_count, 0, 0
: print_tic, print_tic, 0
    1 tic_count +!
    tic_count @ 100 mod 0= if
      tic_msg printcstring cr
    then
;

: print_scancodes, print_scancodes, 0
    begin print_scancode 0 until
;

: print_interrupt, print_interrupt, 0
    fault printcstring cr 
;

; prints an idt entry
: print_idtentry, print_idtentry, 0
    dup 4 + @   swap @              ; wh wl
    dup hi hexprint spc             ; sel
        lo hexprint spc             ; base lo
    dup hi hexprint spc             ; base hi
        lo 8 shr hexprint cr        ; flags
;

; test irq
defcode test_irq, test_irq, 0
    int 33
    next

; divide by zero
: div_by_zero, div_by_zero, 0
    2 0 / drop
;

; Print hello word
: print_hello, print_hello, 0
    hello printcstring cr
;

%define _invoke_addr print_hello
: test_invoke, test_invoke, 0
    _invoke_addr execute
;

; function: main
;   The first forth word executed by the kernel.
: main_test, main_test, 0
    clear
    0x101006 print_idtentry
    0x10100E print_idtentry
    0x101016 print_idtentry
    [`] print_scancode 33 register_isr_handler
    [`] print_tic      32 register_isr_handler
;

section .rodata
hello:      db "hello, world", 0
fault:      db "A fault happened", 0
tic_msg:    db "The clock tics", 0
