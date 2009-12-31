; program: kernel_video
; Words related to screen driver.

; License: GPL
; José Dinuncio <jdinunci@uc.edu.ve>, 12/2009.
; This file is based on Bran's kernel development tutorial file start.asm

%include "forth.h"
%include "kernel_words.h"
%define SPC ' '

[BITS 32]
section .text

; var: SCREEN
;   Address of the begining of the screen.
defconst SCREEN, SCREEN, 0, 0xB8000
; var: CURSOR_POS_X
;    Position x of the cursor. In which column, form 0 to 79 the cursor is.
defvar CURSOR_POS_X, CURSOR_POS_X, 0 , 0
; var: CURSOR_POS_Y
;   Position y of the cursor. In which line, from 0 to 24 the cursor is.
defvar CURSOR_POS_Y, CURSOR_POS_Y, 0 , 0
; var: SCREEN_COLOR
;    The foreground and background colors to use.
defvar SCREEN_COLOR, SCREEN_COLOR, 0, 0x0f00

; function: CURSOR_POS_REL
;   Returns the cursor relative position respect to the origin of the screen
;
; Stack
;   -- cursor_pos_rel
defword CURSOR_POS_REL, CURSOR_POS_REL, 0
            dd CURSOR_POS_Y, FETCH
            LITN 160
            dd MUL
            dd CURSOR_POS_X, FETCH
            LITN 2
            dd MUL
            dd ADD
            dd EXIT

; function: CURSOR_POS
;   Returns the absolute address of the cursor.
;
; Stack
;   -- cursor_pos
: CURSOR_POS, CURSOR_POS, 0
    CURSOR_POS_REL SCREEN +
;

; function: AT_HW
;   Moves the cursor to the position indicated by CURSOR_POS variables.
;
; Stack:
;   --
: AT_HW, AT_HW, 0
    CURSOR_POS_REL          # Get the position of the cursor
    14 0x3D4 OUTB           # Say you're going to send the high byte
    DUP   1 N_BYTE          # ... get the higer byte
    0x3D5 OUTB              # ... and send it

    15 0x3D4 OUTB           # Say you're going to send the low bye
      0x3D5 OUTB            # ... and send it
;

; function: atx
;   Moves the cursor thoe the coordinates indicated. It updates the CURSOR_POS
;   variables.
; 
; Stack:
;   y x --
: atx, atx, 0
    CURSOR_POS_X !
    CURSOR_POS_Y !
;

; function: INK
;   Set the ink color.
;
; Stack:
;   color --
defcode INK, INK, 0
            pop eax
            and eax, 0x0f
            shl eax, 8
            mov ebx, [var_SCREEN_COLOR]
            and ebx, 0xf000
            or eax, ebx
            mov [var_SCREEN_COLOR], eax
            NEXT

; function: BG
;   Sets the background color.
;
; Stack:
;   color --
defcode BG, BG, 0
            pop eax
            and eax, 0x0f
            shl eax, 12
            mov ebx, [var_SCREEN_COLOR]
            and ebx, 0x0f00
            or eax, ebx
            mov [var_SCREEN_COLOR], eax
            NEXT

; function:  BRIGHT
;   Takes a color and returns its brighter version.
;
; Stack:
;   color -- color
: BRIGHT, BRIGHT, 0
    8 +
;

; function SCREEN_SCROLL
;
; Stack
;   --
: SCREEN_SCROLL, SCREEN_SCROLL, 0
    SCREEN   DUP 160 +   SWAP   3840 CMOVE
    # TODO - Clean last line, move cursor
    _CLEAN_LAST_LINE
;

: _CLEAN_LAST_LINE, _CLEAN_LAST_LINE, 0
    SCREEN  DUP 4000 + SWAP 3840 + do
        SCREEN_COLOR @ OVER W! 1+
    loop
;

; function: SCREEN_SCROLL_
;   Scrolls the screen if the cursor goes beyond line 24.
;
; Stack:
;   --
: SCREEN_SCROLL_, SCREEN_SCROLL_, 0
    CURSOR_POS_Y @ 24 > if
        SCREEN_SCROLL
        24 CURSOR_POS_Y !
    then
;

; function: CURSOR_FORWARD
;   Moves the cursor forward.
;
; Stack:
;   --
: CURSOR_FORWARD, CURSOR_FORWARD, 0
    1 CURSOR_POS_X @ + 80 /MOD
    CURSOR_POS_Y +!
    CURSOR_POS_X !
    SCREEN_SCROLL_
;

; function: C>CW, CHAR_TO_CHARWORD
;   Converts a character in a charword.
;
;   A charword is a 16bits word with information about the character to be 
;   printed and its colors.
;
; Stack:
;   char -- charword
defcode C>CW, CHAR_TO_CHARWORD, 0
            pop eax
            and eax, 0xff
            mov ebx, [var_SCREEN_COLOR]
            ;shl ebx, 8
            or eax, ebx
            push eax
            NEXT


; function: EMITCW
;   Prinst a character word
;
; Stack:
;   charword --
: EMITCW, EMITCW, 0
    CURSOR_POS W!
    CURSOR_FORWARD
;

; function: EMIT
;   Prinst a character.
;
; Stack:
;   char --
: EMIT, EMIT, 0
    C>CW EMITCW
;

; function: PRINTCSTRING
;   Prints a C string
;
; Stack:
;   &string --
: PRINTCSTRING, PRINTCSTRING, 0
    begin DUP C@ DUP while EMIT 1+ repeat
    2DROP
;
            
; function: CLEAR 
;   Clear the screen
;
; Stack:
;   char --
: CLEAR, CLEAR, 0
    0 0 atx
    2000 0 do SPC EMIT loop
    0 0 atx
;

; function: CR            
;   Prints a CR
;
; Stack:
;    --
: CR, CR, 0
    1 CURSOR_POS_Y +!
    0 CURSOR_POS_X !
    AT_HW
    SCREEN_SCROLL_
;
		 	
; function: TAB
;   Prints a TAB.
;
; Stack:
;   --
: TAB, TAB, 0
    # TODO - Move to the next column multiple of 8
    8 CURSOR_POS_X +! AT_HW
;

