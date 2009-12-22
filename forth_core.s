; program: forth_core
;
; myforth: My own forth system.
;
; This file is a translation of jonesforth 
; (http://www.annexia.org/_file/jonesforth.s.txt) for being compiled with nasm.

%ifndef forth_core
%define forth_core
%include "forth_macros.s"

[BITS 32]
; Topic: Introduction
; Forth is an extensible, powerfull concatenative language/environment. This
; file contains the core routines needed for a minimal functional forth
; environment.
;
; Forth code is based in 'words'. A word can be implemented in assembly or 
; using exclusively predefined words. We will call the formers defcode words 
; and the laters defword words.
;
; This is the word structure in this implementation
;
; | +---------------+
; | |     LINK      |  Link to the previous word
; | +---------------+
; | |  FLAGS + LEN  |  Several flags + length of the word name
; | +---------------+
; | |     NAME      |  Word name (4 bytes aligned)
; | +---------------+
; | |   CODEWORD    |  Pointer to the routine that executes this word
; | +---------------+
; | |     BODY      |  Optionally, if this is a defword, a serie of
; | +---------------+    pointers to the codewors of each word that
; | |     ...       |    define the current word.
; | +---------------+
;
; The next word to be executed is pointed by the esi register. The NEXT macro
; is the responsable for its execution and the esi update.
;
; If the word to be executed is a defcode, its implementation is in assembly.
; In this case, CODEWORD points directly to the assembly routine. The assembly
; routine must end with the NEXT macro, to execute the next word.
;
; If the word to be executed is a defword, its codeword must point to DOCOL.
; DOCOL executes the word body. The word body is a serie of pointer to the
; codewords of each one of the words in this definition. DOCOL pushes on the
; *return stack* the address of the next word to execute and then executes
; one by one the words on the current word body. The word body must end with
; the EXIT word to restore the address of the next word to execute.



; ============================================================================
;    Virtual Machine
; ============================================================================

; word flags
            F_IMMED    equ  0x80    ; Word is inmediate
            F_HIDDEN   equ  0x20    ; Word is hidden
            F_LENMASK  equ  0x1f    ;
            %define LINK 0          ; Address of the last header word

;  Virtual Machine variables

; var: STATE       Is the interpreter executing code (0) or compiling (non-zero)?

; var LATEST       Points to the newset  word in the dictionary.

; var: HERE        Points to the next free byte of memory.

; var: S0          Stores the address of the top of the parameter stack.

; var: BASE        The current base for printing and reading numbers.

            defvar STATE, STATE, 0, 0
            defvar HERE, HERE, 0, 0
            defvar LATEST, LATEST, 0, wel ; SYSCALL0 must be last in built-in dictionary
            defvar S0, S0, 0, 0
            defvar BASE, BASE, 0, 10

;  Virtual Machine constants
; const: VERSION     Is the current version of this FORTH.

; const: R0          The address of the top of the return stack.

; const: DOCOL       Pointer to DOCOL.

; const: F_IMMED     The IMMEDIATE flag's actual value.

; const: F_HIDDEN    The HIDDEN flag's actual value.

; const: F_LENMASK   The length mask in the flags/len byte.

            defconst VERSION, VERSION, 0, 1
            defconst R0, R0, 0, 2
            defconst DOCOL, __DOCOL, 0, DOCOL
            defconst F_IMMED, __F_IMMED, 0, 0x80
            defconst F_HIDDEN, __F_HIDDEN, 0, 0x20
            defconst F_LENMASK, __F_LENMASK, 0, 0x1f


section .text
align 4

; function: DOCOL
;   This is the core of the forth virtual machine. This routine executes the
;   non-native words. A non-native word is formed by a serie of pointers to the 
;   codewords of other forth words. DOCOL executes each one of these codewords.
DOCOL:
            PUSHRSP esi         ; Saves the return point
            add eax, 4          ; eax pointed to the codeword of this word,
            mov esi, eax        ;   now esi points to the first word
            NEXT

; function: EXIT
;   EXIT is the last word of a forth word (a non-defcode word). It restores the 
;   value of esi, stored in the return stack by DOCOL when this word started.
defcode EXIT, EXIT, 0
            POPRSP esi          ; Pops the address of the word to return to
            NEXT                ; and executes it

%endif
