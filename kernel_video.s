; program: kernel_video
; Words related to screen driver.

; License: GPL
; José Dinuncio <jdinunci@uc.edu.ve>, 12/2009.
; This file is based on Bran's kernel development tutorial file start.asm

%include "forth.h"
%include "kernel_words.h"

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

; function: AT_HW
;   Moves the cursor to the position indicated by CURSOR_POS variables.
;
; Stack:
;   --
defword: AT_HW, AT_HW, 0
            dd CURSOR_POS_REL
            LITN 14             ; Tell we'll send high byte of position
            LITN 0x3D4          ;
            dd OUTB             ;

            dd DUP, FETCH       ; Send high byte
            LITN 1              ;
            dd N_BYTE           ;
            LITN 0x3D5          ;
            dd OUTB             ;

            LITN 15             ; Tell we'll send low byte of position
            LITN 0x3D4          ;
            dd OUTB             ;

            dd FETCH            ; Send low byte
            LITN 0x3D5          ;
            dd OUTB             ;
            dd EXIT

; function: atx
;   Moves the cursor thoe the coordinates indicated. It updates the CURSOR_POS
;   variables.
; 
; Stack:
;   y x --
defword atx, atx, 0
            dd CURSOR_POS_X, STORE
            dd CURSOR_POS_Y, STORE
            dd AT_HW
            dd EXIT

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

; function:  BRIGHT
;   Takes a color and returns its brighter version.
;
; Stack:
;   color -- color
defword BRIGHT, BRIGHT, 0
            dd LIT
            dd 8
            dd ADD
            dd EXIT

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
defword CURSOR_POS, CURSOR_POS, 0
            dd CURSOR_POS_REL
            dd SCREEN   ; constante
            dd ADD
            dd EXIT

; function SCREEN_SCROLL
;
; Stack
;   --
defcode SCREEN_SCROLL, SCREEN_SCROLL, 0
            ;call vScrollUp
            dd NEXT

; function: SCREEN_SCROLL_
;   Scrolls the screen if the cursor goes beyond line 25.
;
; Stack:
;   --
defword SCREEN_SCROLL_, SCREEN_SCROLL_, 0
            dd CURSOR_POS_Y, FETCH
            LITN 25
            dd GT
            if
                LITN 25
                dd CURSOR_POS_Y, STORE
                dd SCREEN_SCROLL
            then
            dd EXIT

; function: CURSOR_FORWARD
;   Moves the cursor forward.
;
; Stack:
;   --
defword CURSOR_FORWARD, CURSOR_FORWARD, 0
            LITN 1
            dd CURSOR_POS_X, ADDSTORE
            dd CURSOR_POS_X, FETCH
            LITN 80
            dd DIVMOD
            dd CURSOR_POS_Y, ADDSTORE
            dd CURSOR_POS_X, STORE
            dd SCREEN_SCROLL_
            dd AT_HW
            dd EXIT

; function: EMITCW
;   Prinst a character word
;
; Stack:
;   charword --
defword EMITCW, EMITCW, 0
            dd CURSOR_POS
            dd STOREWORD
            dd CURSOR_FORWARD
            dd EXIT

; function: EMIT
;   Prinst a character.
;
; Stack:
;   char --
defword EMIT , EMIT , 0
            dd CHAR_TO_CHARWORD
            dd EMITCW
            dd EXIT

; function: PRINTCSTRING
;   Prints a C string
;
; Stack:
;   &string --
defword PRINTCSTRING, PRINTCSTRING, 0
            ; ( &cstring -- )
            begin
                dd DUP, FETCHBYTE, DUP
            while
                dd EMIT, INCR
            repeat
            dd DROP, DROP
            dd EXIT
            
; function: CLEAR 
;   Clear the screen
;
; Stack:
;   char --
defword CLEAR, CLEAR, 0
            LITN 0                  ; Cursor at 0,0
            LITN 0                  ;
            dd atx                  ;
            LITN 80*25              ; for i = 0 to 80*25
            LITN 0                  ;
            do
                LITN ' '            ;   emit ' '
                dd EMIT             ;
            loop
            LITN 0                  ; Cursor at 0,0
            LITN 0                  ;
            dd atx                  ;
            dd EXIT

; function: CR            
;   Prints a CR
;
; Stack:
;    --
defword CR, CR , 0 ; TESTED_OK
			LITN 1
            dd CURSOR_POS_Y, ADDSTORE
            LITN 0
            dd CURSOR_POS_X, STORE
			dd AT_HW
		 	dd EXIT
		 	
; function: TAB
;   Prints a TAB.
;
; Stack:
;   --
defword TAB , TAB, 0	
			LITN 8
            dd CURSOR_POS_X, ADDSTORE
			dd AT_HW
			dd EXIT		

