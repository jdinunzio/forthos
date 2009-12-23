; file: kernel_words

; Topicc: kernel_words
; This file defines the main words used by the kernel OS.

%include "forth_words.s"

[BITS 32]
; function: OUTB
; Executes an out assembly instruction
;
; Stack:
; val port --
;
; Parameters:
; val - The value to out. Byte.
; port - The port to output the value. int16.
defcode OUTB, OUTB, 0
            ; ( val addr -- )
            pop edx
            pop eax
            out dx, al
            NEXT

;%include "kernel_video.s"
