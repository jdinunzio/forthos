
; file: ext3
; by august0815
; 01.12.2009

%include "ext2.s"

section .text
;;;;;;;;;;;;;; SOME WORDS

; function: CONSTANT NOT TESTED_OK
; : CONSTANT
;	WORD		( get the name (the name follows CONSTANT) )
;	CREATE		( make the dictionary entry )
;	DOCOL ,		( append DOCOL (the codeword field of this word) )
;	' LIT ,		( append the codeword LIT )
;	,		( append the value on the top of the stack )
;	' EXIT ,	( append the codeword EXIT )
defword CONSTANT,CONSTANT,0
	dd TEILWORT
	dd CREATE
	dd DOCOL ,COMMA
	dd TICK ,LIT , COMMA ,COMMA
    dd TICK , EXIT
	dd EXIT		; EXIT		(return from FORTH word

; function: ALLOT NOT TESTED_OK
;	First ALLOT, where n ALLOT allocates n bytes of memory.  (Note when calling this that
;	it's a very good idea to make sure that n is a multiple of 4, or at least that next time
;	a word is compiled that HERE has been left as a multiple of 4).
; ALLOT		( n -- addr )
;	HERE @ SWAP	( here n )
;	HERE +!		( adds n to HERE, after this the old value of HERE is still on the stack )
defword ALLOT,ALLOT,0
	dd HERE ,FETCH ,SWAP
	dd HERE ,ADDSTORE
	dd EXIT		; EXIT		(return from FORTH word
; function: CELLS : CELLS ( n -- n ) 4 * ; NOT TESTED_OK
;	Second, CELLS.  In FORTH the phrase 'n CELLS ALLOT' means allocate n integers of whatever size
;	is the natural size for integers on this machine architecture.  On this 32 bit machine therefore
;	CELLS just multiplies the top of stack by 4.
defword CELLS,CELLS,0,
    dd 4 , MUL
	dd EXIT		; EXIT		(return from FORTH word

; function: VARIABLE NOT TESTED_OK
;	So now we can define VARIABLE easily in much the same way as CONSTANT above.  Refer to the
;	diagram above to see what the word that this creates will look like.
;: VARIABLE
;	1 CELLS ALLOT	( allocate 1 cell of memory, push the pointer to this memory )
;	WORD CREATE	( make the dictionary entry (the name follows VARIABLE) )
;	DOCOL ,		( append DOCOL (the codeword field of this word) )
;	' LIT ,		( append the codeword LIT )
;	,		( append the pointer to the new memory )
;	' EXIT ,	( append the codeword EXIT )
;
defword VARIABLE,VARIABLE,0
	LITN 1 
	dd  CELLS , ALLOT
    dd TEILWORT ,CREATE
    dd DOCOL , COMMA
    dd TICK , LIT , COMMA,COMMA
    dd TICK , EXIT
	dd EXIT		; EXIT		(return from FORTH word
	
  

;defword DEPTH	  NOT TESTED_OK
;( DEPTH returns the depth of the stack. )
;: DEPTH		( -- n )
;	S0 @ DSP@ -
;	4-			( adjust because S0 was on the stack when we pushed DSP )
defword DEPTH,DEPTH	,0	
		dd S0 , FETCH
		dd DSPFETCH , SUB
		dd DECR4
		dd EXIT		; EXIT		(return from FORTH word

;defword CLSSTACK		noch nicht ok
defword CLSSTACK,CLSSTACK	,0	
;: cls  ( x0 .. xn -- ) \ clear stack
;  depth 0= IF ( noop) ELSE  depth 0 do drop loop THEN ;
;DEPTH IF  .S  DEPTH 0 DO DROP LOOP  THEN
		dd DEPTH 
		LITN 0
		dd GT
		 if 
		 ;dd DOTS
		 dd DEPTH
		 LITN 0
		 do
		  ;dd UDOT
		  dd DROP
		  loop
		 then
		dd EXIT		; EXIT		(return from FORTH word
		

	
;%include "rest.s"
