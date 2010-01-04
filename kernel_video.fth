; program: kernel_video
; Words related to screen driver.

; License: GPL
; José Dinuncio <jdinunci@uc.edu.ve>, 12/2009.
; This file is based on Bran's kernel development tutorial file start.asm

%include "forth.h"
%include "kernel_words.h"

[BITS 32]
section .text

; var: screen
;   Address of the begining of the screen.
defconst screen, screen, 0, 0xB8000
; var: cursor_pos_x
;    Position x of the cursor. In which column, form 0 to 79 the cursor is.
defvar cursor_pos_x, cursor_pos_x, 0 , 0
; var: cursor_pos_y
;   Position y of the cursor. In which line, from 0 to 24 the cursor is.
defvar cursor_pos_y, cursor_pos_y, 0 , 0
; var: screen_color
;    The foreground and background colors to use.
defvar screen_color, screen_color, 0, 0x0f00

; function: cursor_pos_rel
;   Returns the cursor relative position respect to the origin of the screen
;
; Stack
;   -- cursor_pos_rel
: cursor_pos_rel, cursor_pos_rel, 0
    cursor_pos_y @ 160 *
    cursor_pos_x @   2 * +
;

; function: cursor_pos
;   Returns the absolute address of the cursor.
;
; Stack
;   -- cursor_pos
: cursor_pos, cursor_pos, 0
    cursor_pos_rel screen +
;

; function: at_hw
;   Moves the cursor to the position indicated by cursor_pos variables.
;
; Stack:
;   --
: at_hw, at_hw, 0
    cursor_pos_rel          ; Get the position of the cursor
    14 0x3D4 outb           ; Say you're going to send the high byte
    dup   1 n_byte          ; ... get the higer byte
    0x3D5 outb              ; ... and send it

    15 0x3D4 outb           ; Say you're going to send the low bye
      0x3D5 outb            ; ... and send it
;

; function: atx
;   Moves the cursor thoe the coordinates indicated. It updates the cursor_pos
;   variables.
; 
; Stack:
;   y x --
: atx, atx, 0
    cursor_pos_x !
    cursor_pos_y !
;

; function: ink
;   Set the ink color.
;
; Stack:
;   color --
defcode ink, ink, 0
        pop eax
        and eax, 0x0f
        shl eax, 8
        mov ebx, [var_screen_color]
        and ebx, 0xf000
        or eax, ebx
        mov [var_screen_color], eax
        next

; function: bg
;   Sets the background color.
;
; Stack:
;   color --
defcode bg, bg, 0
        pop eax
        and eax, 0x0f
        shl eax, 12
        mov ebx, [var_screen_color]
        and ebx, 0x0f00
        or eax, ebx
        mov [var_screen_color], eax
        next

; function:  bright
;   Takes a color and returns its brighter version.
;
; Stack:
;   color -- color
: bright, bright, 0
    8 +
;

; function screen_scroll
;
; Stack
;   --
: screen_scroll, screen_scroll, 0
    screen   dup 160 +   swap   3840 cmove
    ; TODO - Clean last line, move cursor
    _clean_last_line
;

: _clean_last_line, _clean_last_line, 0
    screen  dup 4000 + swap 3840 + do
        screen_color @ over w! 1+
    loop
;

; function: screen_scroll_
;   Scrolls the screen if the cursor goes beyond line 24.
;
; Stack:
;   --
: screen_scroll_, screen_scroll_, 0
    cursor_pos_y @ 24 > if
        screen_scroll
        24 cursor_pos_y !
    then
;

; function: cursor_forward
;   Moves the cursor forward.
;
; Stack:
;   --
: cursor_forward, cursor_forward, 0
    1 cursor_pos_x @ + 80 /mod
    cursor_pos_y +!
    cursor_pos_x !
    screen_scroll_
;

; function: c>cw, char_to_charword
;   Converts a character in a charword.
;
;   A charword is a 16bits word with information about the character to be 
;   printed and its colors.
;
; Stack:
;   char -- charword
defcode c>cw, char_to_charword, 0
        pop eax
        and eax, 0xff
        mov ebx, [var_screen_color]
        or eax, ebx
        push eax
        next


; function: emitcw
;   Prinst a character word
;
; Stack:
;   charword --
: emitcw, emitcw, 0
    cursor_pos w!
    cursor_forward
;

; function: emit
;   Prinst a character.
;
; Stack:
;   char --
: emit, emit, 0
    c>cw emitcw
;

; function: printcstring
;   Prints a C string
;
; Stack:
;   &string --
: printcstring, printcstring, 0
    begin dup c@ dup while emit 1+ repeat
    2drop
;
            
; function: clear 
;   Clear the screen
;
; Stack:
;   char --
: clear, clear, 0
    0 0 atx
    2000 0 do spc loop
    0 0 atx
;

; function: cr            
;   Prints a cr
;
; Stack:
;    --
: cr, cr, 0
    1 cursor_pos_y +!
    0 cursor_pos_x !
    at_hw
    screen_scroll_
;

; function: spc
;   Prints a space
: spc, spc, 0
    32 emit
;
		 	
; function: tab
;   Prints a tab.
;
; Stack:
;   --
: tab, tab, 0
    ; TODO - Move to the next column multiple of 8
    8 cursor_pos_x +! at_hw
;

; function: intprint
;   Prints an integer. TODO - move to another file
;
; stack:
;   n --
: intprint, intprint, 0
    10 /mod
    dup 0<> if  intprint  else  drop  then
    '0' + emit
;

; function: hexprint
;   Prints an integer in hexadecimal.
;   TODO - move to another file
;
; stack:
;   n --
: hexprint, hexprint, 0
    16 /mod
    dup 0<> if hexprint else drop then
    dup 10 < if '0' else 'A' 10 - then
    + emit
;


