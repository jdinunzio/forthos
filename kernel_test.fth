; program: kernel_test
; Test for the kernel.

; License: GPL
; José Dinuncio <jdinunci@uc.edu.ve>, 12/2009.

%include "forth.h"
%include "kernel_words.h"
%include "kernel_video.h"
%include "kernel_kbd.h"
%define SPC ' '
%define Fault fault

[BITS 32]
; function: intprint
;   Prints an integer. TODO - move to another file
;
; stack:
;   n --
: intprint, intprint, 0
    10 /MOD
    DUP 0<> if  intprint  else  DROP  then
    '0' + EMIT
;

: hexprint, hexprint, 0
    16 /MOD
    DUP 0<> if hexprint else DROP then
    DUP 10 < if '0' else 'A' 10 - then
    + EMIT
;

global print_scancodes
: print_scancodes, print_scancodes, 0
    begin KBD_SCANCODE intprint SPC EMIT 0 until
;

global print_interrupt
%define _fault fault
: print_interrupt, print_interrupt, 0
    _fault PRINTCSTRING CR 
;

; b3b2b1b0 -- 0000b1b0
: lo, lo, 0
    0xFFFF AND
;

; b3b2b1b0 -- 0000b1b0
: hi, hi, 0
    16 SHR 0xFFFF AND
;

: print_idtentry, print_idtentry, 0
    DUP 4 + @   SWAP @              # wh wl
    DUP hi hexprint SPC EMIT        # sel
        lo hexprint SPC EMIT        # base lo
    DUP hi hexprint SPC EMIT        # base hi
        lo 8 SHR hexprint CR        # flags
;

defcode test_irq, test_irq, 0
    int 33
    NEXT

: div_by_zero, div_by_zero, 0
    2 0 / DROP
;

; function: MAIN
; The first forth word invoked by the kernel.
%define s_hello hello
: MAIN, MAIN, 0
    CLEAR
    0x101006 print_idtentry
    0x10100E print_idtentry
    0x101016 print_idtentry
    #test_irq
    #test_irq
    s_hello PRINTCSTRING CR
    #div_by_zero
    print_scancodes
;

section .rodata
hello:  db "hello, world", 0
fault:  db "A fault happened", 0
