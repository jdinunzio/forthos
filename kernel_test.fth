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
: intprint intprint 0
    10 /MOD
    DUP 0<> if  intprint  else  DROP  then
    '0' + EMIT
;

; function: MAIN
; The first forth word invoked by the kernel.
: MAIN MAIN 0
    CLEAR
    begin
        5 10 atx
        
        # print the KBD_FLAGS
        KBD_FLAGS intprint   SPC EMIT
        
        # print the scan code
        KBD_SCANCODE 0xFF AND
        DUP 
        intprint
        SPC EMIT

        # print the key flags
        _UPDATE_KBD_FLAGS
        KEY_STATUS @ intprint

        # clean the next characters
        SPC EMIT  SPC EMIT  SPC EMIT
    0 until
;

section .rodata
hello:  db "hello, world", 0
