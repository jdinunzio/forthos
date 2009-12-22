
; file: ext1
; by august0815
; 19.12.2009

section .text
;;;;;;;;;;;;;; SOME WORDS

;: BL   32 ; \ BL (BLank) is a standard FORTH word for space.


; function: SPACE ; SPACE prints a space ;: SPACE BL EMIT ; ; TESTED_OK
defword SPACE,SPACE,0
	LITN $20
	dd EMIT
	dd EXIT		; EXIT		(return from FORTH word)
; function: NEGATE ; NEGATE leaves the negative of a number on the stack.
;: NEGATE 0 SWAP - ;
defword NEGATE,NEGATE,0
	LITN 0
	dd SWAP
	dd SUB
	dd EXIT		; EXIT		(return from FORTH word)
	
;\ Standard words for booleans.	
; function: TRUE : TRUE  1 ; ; TESTED_OK
defword TRUE,TRUE,0
	LITN 1
	dd EXIT		; EXIT		(return from FORTH word)
; function: FALSE : FALSE 0 ;
defword FALSE,FALSE,0 
	LITN 0
	dd EXIT		; EXIT		(return from FORTH word)
; function: NOT : NOT   0= ;
defword NOT,NOT,0
	dd ZEQU
	dd EXIT		; EXIT		(return from FORTH word)

; function: LITERAL  LITERAL takes whatever is on the stack and compiles LIT <foo>
; not tested
defword LITERAL,LITERAL,0
	dd IMMEDIATE 
	dd TICK		; compile LIT
	dd LIT
	dd COMMA
    dd COMMA	; compile the literal itself (from the stack)
	dd EXIT		; EXIT		(return from FORTH word)

; function:  RECURSE makes a recursive call to the current word that is being compiled.
; not tested
defword RECURSE,RECURSE,0
	dd IMMEDIATE
	dd LATEST , FETCH		;LATEST points to the word being compiled at the moment
	dd TCFA		;get the codeword
	dd COMMA	;compile it
	
	dd EXIT		; EXIT		(return from FORTH word)

;( Some more complicated stack examples, showing the stack notation. )
; function: NIP  : NIP ( x y -- y ) SWAP DROP ;
; not tested
defword NIP,NIP,0
	dd SWAP
	dd DROP
	dd EXIT		; EXIT		(return from FORTH word)
	
; function: TUCK 	: TUCK ( x y -- y x y ) SWAP OVER ;
; not tested
defword TUCK,TUCK,0
	dd SWAP
	dd OVER
	dd EXIT		; EXIT		(return from FORTH word)
	
; function: PICK  : PICK ( x_u ... x_1 x_0 u -- x_u ... x_1 x_0 x_u )
; not tested
defword PICK,PICK,0
	dd INCR ,4 			;( add one because of 'u' on the stack )
	dd MUL 				;( multiply by the word size )
	dd DSPFETCH , ADD 	; add to the stack pointer )
	dd FETCH			;( and fetch )
	dd EXIT		; EXIT		(return from FORTH word)

;( With the looping constructs, we can now write SPACES, which writes n spaces to stdout. )
; function:  SPACES	( n -- ) ; TESTED_OK
defword SPACES,SPACES,0
	begin
	dd DUP , ZGT		;( while n > 0 )
	while
	dd	SPACE		;( print a space )
	dd	DECR		;( until we count down to 0 )
	repeat
    dd DROP
    dd EXIT		; EXIT		(return from FORTH word)
    
;
;( Standard words for manipulating BASE. )
; function:  DECIMAL ( -- ) 10 BASE ! ; TESTED_OK
defword DECIMAL,DECIMAL,0
	LITN 10
	dd BASE ,STORE
	dd EXIT		; EXIT		(return from FORTH word)
;
; function: : HEX ( -- ) 16 BASE ! ;; TESTED_OK
defword HEX,HEX,0
	LITN 16
	dd BASE ,STORE
	dd EXIT		; EXIT		(return from FORTH word)
	
; function: IF 
; not tested
defword IF,IF,0
	dd IMMEDIATE
	dd TICK
	dd ZBRANCH
	dd COMMA
	dd HERE , FETCH
	LITN 0 
	dd COMMA	
	dd EXIT		; EXIT		(return from FORTH word)	

; function: THEN
; not tested
defword THEN,THEN,0
	dd IMMEDIATE
	dd DUP
	dd HERE , FETCH 
	dd SWAP , SUB
	dd SWAP , STORE
	dd EXIT		; EXIT		(return from FORTH word)


; function: ELSE
; not tested
defword ELSE,ELSE,0
	dd TICK 
	dd BRANCH
	dd COMMA
	dd HERE , FETCH
	LITN 0 
	dd COMMA
	dd SWAP
	dd DUP
	dd HERE , FETCH
	dd SWAP ,SUB
	dd SWAP , STORE
	dd EXIT		; EXIT		(return from FORTH word)
	
	
; function: BEGIN
; not tested
defword BEGIN,BEGIN,0
;: BEGIN IMMEDIATE
;	HERE @		\ save location on the stack
	dd IMMEDIATE
	dd HERE , FETCH
	dd EXIT		; EXIT		(return from FORTH word)


; function: UNTIL
; not tested
defword UNTIL,UNTIL,0
;: UNTIL IMMEDIATE
;	' 0BRANCH ,	\ compile 0BRANCH
;	HERE @ -	\ calculate the offset from the address saved on the stack
;	,		\ compile the offset here
	dd IMMEDIATE
	dd TICK
	dd ZBRANCH
	dd HERE , FETCH , SUB
	dd COMMA
dd EXIT		; EXIT		(return from FORTH word)

%include "ext2.s"
