
; file: ext2
; by august0815
; 19.12.2009

;;;;;;;;;;;;;; SOME WORDS

; defword: U. ; TESTED_OK
;PRINTING NUMBERS ---
; ( This is the underlying recursive definition of U. )
;: U.		( u -- )
;	BASE @ /MOD	( width rem quot )
;	?DUP IF			( if quotient <> 0 then )
;		RECURSE		( print the quotient )
;	THEN
;
;	( print the remainder )
;	DUP 10 < IF
;		'0'		( decimal digits 0..9 )
;	ELSE
;		10 -		( hex and beyond digits A..Z )
;		'A'
;	THEN
;	+
;	EMIT
defword U.,UDOT,0
	;
	dd BASE, FETCH 	;( width rem quot )
	;
	dd DIVMOD		
	dd QDUP
	if 				;( if quotient <> 0 then )
	 	dd UDOT
	else
	then
		dd DUP		;( print the remainder )
		LITN 10 
		dd LT
		if
	 		LITN '0'  ;(decimal digits 0..9 )
		else
		LITN 10 
	 	dd  SUB		;( hex and beyond digits A..Z )
	 	LITN 'A'
	 	then
	 dd ADD
	 dd EMIT	
	 dd EXIT		; EXIT		(return from FORTH word)
; defword: .S  ( -- ) FORTH word .S prints the contents of the stack.  It doesn't alter the stack.
;	Very useful for debugging. ; TESTED_OK
;: .S		( -- )
;	DSP@		( get current stack pointer )
;	BEGIN
;		DUP S0 @ <
;	WHILE
;		DUP @ U.	( print the stack element )
;		SPACE
;		4+		( move up )
;	REPEAT
;	DROP
defword .S,DOTS,0
	LITN '>'
	dd EMIT
	dd DSPFETCH ;( get current stack pointer )
	begin
		dd DUP 
		dd S0 ,FETCH , LT
	while
		dd DUP ,FETCH 
		dd UDOT ;( print the stack element )
		dd SPACE
		dd INCR4			 ;(move up )
	repeat
	dd DROP
	LITN '<'
	dd EMIT
	dd EXIT		; EXIT		(return from FORTH word)


defword ID.,IDDOT,0
; defword: ID. ; TESTED_OK
;: ID.
;	4+		( skip over the link pointer )
;	DUP C@		( get the flags/length byte )
;	F_LENMASK AND	( mask out the flags - just want the length )
;
;	BEGIN
;		DUP 0>		( length > 0? )
;	WHILE
;		SWAP 1+		( addr len -- len addr+1 )
;		DUP C@		( len addr -- len addr char | get the next character)
;		EMIT		( len addr char -- len addr | and print it)
;		SWAP 1-		( len addr -- addr len-1    | subtract one from length )
;	REPEAT
;	2DROP		( len addr -- )
	dd INCR4
	dd DUP 
	dd  FETCHBYTE 
	LITN 0x1F  ;  F_LENMASK( mask out the flags - just want the length )
	dd AND
	begin	
		dd DUP , ZGT
	while
	  	dd SWAP , INCR
		dd DUP , FETCH
		dd EMIT
		dd SWAP , DECR
	repeat
    dd TWODROP
	dd EXIT		; EXIT		(return from FORTH word)
	
defword ?HIDDEN ,?HIDDEN ,0
; defword: ?HIDDEN	 NOT TESTED_OK
;: ?HIDDEN
;	4+		( skip over the link pointer )
;	C@		( get the flags/length byte )
;	F_HIDDEN AND	( mask the F_HIDDEN flag and return it (as a truth value) )
	dd INCR4 , FETCHBYTE
	LITN 0x20
	dd AND
	dd EXIT		; EXIT		(return from FORTH word)
	
defword ?IMMEDIATE ,?IMMEDIATE ,0
; defword: ?IMMEDIATE NOT TESTED_OK
;: ?IMMEDIATE
;	4+		( skip over the link pointer )
;	C@		( get the flags/length byte )
;	F_IMMED AND	( mask the F_IMMED flag and return it (as a truth value) )
	dd INCR4 , FETCHBYTE
	dd F_IMMED , FETCH , AND
	dd EXIT		; EXIT		(return from FORTH word)


; defword: WORDS ; TESTED_OK
; All words of forthos
defword WORDS,WORDS,0
; WORDS
;	LATEST @	( start at LATEST dictionary entry )
;	BEGIN
;		?DUP		( while link pointer is not null )
;	WHILE
;		DUP ?HIDDEN NOT IF	( ignore hidden words )
;			DUP ID.		( but if not hidden, print the word )
;			SPACE
;		THEN
;		@		( dereference the link pointer - go to previous word )
;	REPEAT
;	CR
	dd LATEST , FETCH
	begin 
		dd QDUP
	while
		dd DUP 
		dd ?HIDDEN ,NOT
		if 
		;dd DUP
		;dd UDOT	
		
			dd DUP , IDDOT
			dd SPACE
		then
		dd FETCH
	repeat
	dd CR
	dd EXIT		; EXIT		(return from FORTH word)


%include "ext3.s"
