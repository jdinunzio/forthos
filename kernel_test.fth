; program: kernel_test
; Test for the kernel.

; License: GPL
; José Dinuncio <jdinunci@uc.edu.ve>, 12/2009.

%include "forth.h"
%include "kernel_words.h"
%include "kernel_video.h"
%include "kernel_kbd.h"
%define SPC ' '

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

: print_scancodes, print_scan_codes, 0
    begin KBD_SCANCODE intprint SPC EMIT 0 until
;

; function: MAIN
; The first forth word invoked by the kernel.
%define s_hello hello
: MAIN, MAIN, 0
    CLEAR
     print_scancodes
    CR s_hello PRINTCSTRING
    begin
        5 10 atx
        # Print key_status 
        #KBD_SCANCODE 
        #   DUP _UPDATE_KEY_STATUS 
        #   KEY_STATUS @ intprint SPC EMIT

        # Print scancode
        #DUP intprint SPC EMIT

        # Print if key is down
        #DUP _KEY_DOWN? if '1' EMIT else '0' EMIT then
        #SPC EMIT
        
        # Our own implementation of GETCHAR
        #DUP SC>C intprint
        #SPC EMIT

        # print the key char
         GETCHAR EMIT 



        # Limpiar siguientes caracteres
        SPC EMIT SPC EMIT SPC EMIT
    0 until
;

section .rodata
hello:  db "hello, world", 0
