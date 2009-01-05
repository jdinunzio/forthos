%ifndef kernel_vide
%define kernel_video
%include "forth_words.s"

[BITS 32]

defcode OUTB, OUTB, 0
            ; ( val addr -- )
            pop edx
            pop eax
            out dx, al
            NEXT

; Screen words
; XXX: Durante las pruebas SCREEN sera definido en test.s y en kernel.s
;defconst SCREEN, SCREEN, 0, 0xB8000

defvar CURSOR_POS_X, CURSOR_POS_X, 0 , 0
defvar CURSOR_POS_Y, CURSOR_POS_Y, 0 , 0
defvar SCREEN_COLOR, SCREEN_COLOR, 0, 0x0f00

section .text
defword AT_HW, AT_HW, 0
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

defword atx, atx, 0
            ; ( y:line x:col -- )
            dd CURSOR_POS_X, STORE
            dd CURSOR_POS_Y, STORE
            dd AT_HW
            dd EXIT

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

defword BRIGHT, BRIGHT, 0
            dd LIT
            dd 8
            dd ADD
            dd EXIT

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

defword CURSOR_POS, CURSOR_POS, 0
            dd CURSOR_POS_REL
            dd SCREEN
            dd ADD
            dd EXIT

defword SCREEN_SCROLL, SCREEN_SCROLL, 0
            ;
            dd EXIT

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

defword EMITCW, EMITCW, 0
            ; prints a charword (attributes+character)
            ; ( charword -- )
            dd CURSOR_POS
            dd STOREWORD
            dd CURSOR_FORWARD
            dd EXIT

defword EMIT, EMIT, 0
            ; ( char -- )
            dd CHAR_TO_CHARWORD
            dd EMITCW
            dd EXIT

defword PRINTCSTRING, PRINTCSTRING, 0
            ; ( &cstring -- )
            begin
                dd DUP, FETCHBYTE, DUP
            while
                dd EMIT, INCR
            repeat
            dd DROP, DROP
            dd EXIT

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

%endif
