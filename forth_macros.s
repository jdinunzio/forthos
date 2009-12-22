; program: forth_macros

; Topic: Forth macros
;
; This file and *forth_core.s* are the base of the forth system
;
; Here are defined the most basic macros of the forth kernel.
;
; This is a translation of jonesforth 
; (http://www.annexia.org/_file/jonesforth.s.txt) for being compiled with nasm

; Bug in defcode macro corrected . august0815 14.12.2009
; autodoc with NaturalDocs 19.12.2009

[BITS 32]
; define: NEXT macro
; NEXT macro
;  * Executes the next forth word.
;  * esi points to the codeword of the next word to be executed. The 
;  * codeword stores the address of the rutine that implements the forth word.
;  * Increments esi to point to the next forth word, and jumps to the rutine.
%macro NEXT 0
            lodsd
            jmp [eax]
%endmacro

; define: PUSHRSP and POPRSP
; 
; PUSHRSP and POPRSP
;   push and pop in the return stack 
%macro PUSHRSP 1
            lea ebp, [ebp-4]
            mov [ebp], %1
%endmacro

%macro POPRSP 1
            mov %1, [ebp]
            lea ebp, [ebp+4]
%endmacro

; define: defcode macro
; defword macro
;  * Define a forth word implemented in forth.
;
;  * A forth word is a serie of pointers to the codewords that implement it.
;  * A forth word must end with the EXIT word.
;
;   ARGS: name, label, flags
%macro defword 3
    section .rodata                 ; Define this word in the rodata
            align 4                 ;   section, aligned and with a 
            GLOBAL label_%2         ;   global name
            %defstr name %1         ; Set the name and length of this
            %strlen name_len name   ;   word
            %undef OLDLINK          ; Updates OLDLINK and LINK to
            %xdefine OLDLINK LINK   ;   link this word with the
            %undef LINK             ;   previous one
            %xdefine LINK name_%2   ;
    name_%2:
            dd  OLDLINK             ; LINK to the previous word
            db %3 + name_len        ; Flags + len(name)
            db name                 ; Name of the word

            align 4                 ; Start the definition in a 4 bytes
            GLOBAL %2               ;   boundary
    %2:
            dd DOCOL                ; codeword of this word
%endmacro

; define:  defcode macro
; defcode macro
;  * Define a forth word implemented in assembler.
;
;  * The body of a code word is an assebler routine. The routine must end
;  * with the NEXT macro to make the forth interpreter execute the next
;  * operation.
;
;   ARGS: name, label, flags
%macro defcode 3
   section .rodata                 ; Define this word in the rodata
            align 4                 ;   section, aligned and with a 
            GLOBAL label_%2         ;   global name
            %defstr name %1         ; Set the name and length of this
            %strlen name_len name   ;   word
            %undef OLDLINK          ; Updates OLDLINK and LINK to
            %xdefine OLDLINK LINK   ;   link this word with the
            %undef LINK             ;   previous one
            %xdefine LINK name_%2   ;
    name_%2:
            dd  OLDLINK                ; Links to the previous word
            db %3 + name_len        ; Flags + len(name)
            db name                 ; Name of the word

            align 4                 ; Start the definition in a 4 bytes
            GLOBAL %2               ;   boundary
    %2:
            dd code_%2              ; codeword of this word
    section .text                   ; Here starts the assembler for this
            align 4                 ;   word
            GLOBAL code_%2          ;
    code_%2:
%endmacro

; define: defvar macro
; defvar macro
;  * Define a variable.
;
;  * A variable word is a code word that pushes in the stack the address of the 
;  * variable.
;
;  * ARGS: name, label, flags, value
%macro defvar 4
            defcode %1, %2, %3
            push var_%2
            NEXT
    section .data
            align 4
    var_%2:
            dd %4
%endmacro

; define: defconst macro
; defconst macro
;  * Define a constant.
;
;  * A constant word is a code word that push in the stack a constant value.
;
;  * ARGS: name, label, flags, value
%macro defconst 4
            defcode %1, %2, %3
            push %4
            NEXT
%endmacro
; define:  LITN  Literal value
; Literal value
%macro LITN 1
            dd LIT
            dd %1
%endmacro

;  convenience macros
; define: branch 1
%macro branch 1
        dd BRANCH 
        dd %1 - $
%endmacro

; define: zbranch 1
%macro zbranch 1
        dd ZBRANCH 
        dd %1 - $
%endmacro

; define: cond IF ... ELSE ... THEN
%macro if 0
        %push if_cond
        zbranch %$ifnot
%endmacro

%macro else 0
        %repl else_cond
        branch %$exit
    %$ifnot:
%endmacro

%macro then 0
        %ifctx if_cond
            %$ifnot:
        %endif
    %$exit:
        %pop 
%endmacro

; define: end ini DO ... LOOP
;  * e.g :	LITN 80*25              ; for i = 0 to 80*25
;  *         LITN 0                  ;
;  *         do
;  *             LITN ' '            ;   emit ' '
;  *             dd EMIT             ;
;  *			loop
%macro do 0
        %push do_loop
    %$loop:
        dd TWODUP
        dd GE
        zbranch %$exit
%endmacro

%macro loop 0
        dd INCR
        branch %$loop
    %$exit:
        dd DROP, DROP
        %pop
%endmacro


; define: BEGIN ... cond UNTIL
%macro begin 0
        %push begin_loop
    %$loop:
%endmacro

%macro until 0
        zbranch %$loop
    %$exit:
        %pop
%endmacro

; define:  BEGIN cond WHILE ... REPEAT
;  * e.g :	 begin
;  *              dd DUP, FETCHBYTE, DUP
;  *         while
;  *              dd EMIT, INCR
;  *         repeat
%macro while 0
        zbranch %$exit
%endmacro

%macro repeat 0
        branch %$loop
    %$exit:
        %pop
%endmacro

; You can always exit from a loop with LEAVE
%macro leave 0
        branch %$exit
        %pop
%endmacro
