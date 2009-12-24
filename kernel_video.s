; file: kernel_video

%include "forth.h"
%include "kernel_words.h"

[BITS 32]
; var: SCREEN
defconst SCREEN, SCREEN, 0, 0xB8000
; var: CURSOR_POS_X
defvar CURSOR_POS_X, CURSOR_POS_X, 0 , 0
; var: CURSOR_POS_Y
defvar CURSOR_POS_Y, CURSOR_POS_Y, 0 , 0
; var: SCREEN_COLOR
defvar SCREEN_COLOR, SCREEN_COLOR, 0, 0x0f00
; var: KEYBUFF
defvar KEYBUFF , KEYBUFF , 0 , 0

section .text
;defword AT_HW
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

;defword: atx
defword atx, atx, 0
            ; ( y:line x:col -- )
            dd CURSOR_POS_X, STORE
            dd CURSOR_POS_Y, STORE
            dd AT_HW
            dd EXIT

;defcode: INK
defcode INK, INK, 0
            ; ( ink -- )
            pop eax
            and eax, 0x0f
            shl eax, 8
            mov ebx, [var_SCREEN_COLOR]
            and ebx, 0xf000
            or eax, ebx
            mov [var_SCREEN_COLOR], eax
            NEXT

;defcode: BG
defcode BG, BG, 0
            ; ( ink -- )
            pop eax
            and eax, 0x0f
            shl eax, 12
            mov ebx, [var_SCREEN_COLOR]
            and ebx, 0x0f00
            or eax, ebx
            mov [var_SCREEN_COLOR], eax
            NEXT

;defcode: C>CW, CHAR_TO_CHARWORD
defcode C>CW, CHAR_TO_CHARWORD, 0
            ; Converts a character in a charword (attributes+character)
            ; ( char -- charword )
            pop eax
            and eax, 0xff
            mov ebx, [var_SCREEN_COLOR]
            ;shl ebx, 8
            or eax, ebx
            push eax
            NEXT

;defword:  BRIGHT
defword BRIGHT, BRIGHT, 0
            dd LIT
            dd 8
            dd ADD
            dd EXIT

;defword: CURSOR_POS_REL
defword CURSOR_POS_REL, CURSOR_POS_REL, 0
            ; ( -- cursorpos)
            dd CURSOR_POS_Y, FETCH
            LITN 160
            dd MUL
            dd CURSOR_POS_X, FETCH
            LITN 2
            dd MUL
            dd ADD
            dd EXIT

;defword: CURSOR_POS
defword CURSOR_POS, CURSOR_POS, 0
            dd CURSOR_POS_REL
            dd SCREEN   ; constante
            dd ADD
            dd EXIT

;defcode: SCREEN_SCROLL
defcode SCREEN_SCROLL, SCREEN_SCROLL, 0
            ;call vScrollUp
            dd NEXT

;defword: SCREEN_SCROLL_
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

;defword: CURSOR_FORWARD
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

;defword: EMITCW
defword EMITCW, EMITCW, 0
            ; prints a charword (attributes+character)
            ; ( charword -- )
            dd CURSOR_POS
            dd STOREWORD
            dd CURSOR_FORWARD
            dd EXIT

;defword: EMIT
defword EMIT , EMIT , 0
            ; ( char -- )
            dd CHAR_TO_CHARWORD
            dd EMITCW
            dd EXIT

;defword: PRINTCSTRING
defword PRINTCSTRING, PRINTCSTRING, 0
            ; ( &cstring -- )
            begin
                dd DUP, FETCHBYTE, DUP
            while
                dd EMIT, INCR
            repeat
            dd DROP, DROP
            dd EXIT
            
;defword: CLEAR            
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

;defword: CR            
defword CR, CR , 0 ; TESTED_OK
			LITN 1
            dd CURSOR_POS_Y, ADDSTORE
            LITN 0
            dd CURSOR_POS_X, STORE
			dd AT_HW
		 	dd EXIT
		 	

;defword: TAB
defword TAB , TAB ,0	
			LITN 8
            dd CURSOR_POS_X, ADDSTORE
			dd AT_HW
			dd EXIT		

; TODO: TEST, removeme
defword MAIN, MAIN, 0
            LITN hello
            dd PRINTCSTRING
always:     branch always

section .rodata
hello:  db "hello, world", 0
