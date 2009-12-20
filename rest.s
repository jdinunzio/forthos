
; file: rest
; must be the last file
; by august0815
; 01.12.2009


; defword: MES1   TESTED_OK
defword MES1,MES1,0
			dd CR
            LITN 79             ; for i = 0 to 80*25
            LITN 0                  
            do
 			LITN '*'
 			dd EMIT
 			loop
 			dd CR
            LITN  outputmes
            dd PRINTCSTRING
            dd CR
            dd EXIT		; EXIT		(return from FORTH word)           
; defword: MES2   TESTED_OK
defword MES2,MES2,0   
			dd CR
            LITN 79             ; for i = 0 to 80*25
            LITN 0                  
            do
 			LITN '*'
 			dd EMIT
 			loop
 			dd CR
            LITN  inputloop
            dd PRINTCSTRING
            dd CR
            
            
dd EXIT		; EXIT		(return from FORTH word) 
          

; defword: ZEILEMIT    TESTED_OK
defword ZEILEMIT,ZEILEMIT,0
            dd CR
            LITN 10             
            LITN 0                  
            do
 			LITN '-'
 			dd EMIT
 			loop
 			dd CR
 			LITN '>'
 			dd EMIT
 			LITN zeile_buffer
            ;dd KEYBUFF
            dd PRINTCSTRING
            LITN '<'
 			dd EMIT
 			
 			;dd DOTS
dd EXIT		; EXIT		(return from FORTH word)  

; defword: TEILEMIT   TESTED_OK
defword TEILEMIT,TEILEMIT,0
			;dd CR
			;dd DOTS
			;dd CR
            LITN 10             
            LITN 0                  
            do
 			LITN '*'
 			dd EMIT
 			loop
 			dd CR
 			LITN '>'
 			dd EMIT
 			LITN ptr_buff
            dd PRINTCSTRING
            LITN '<'
 			dd EMIT
 			
 			;dd DOTS
dd EXIT		; EXIT		(return from FORTH word)			



; defword: TEST   DUMMY

defword TEST , TEST ,0
      
            
            

dd EXIT		; EXIT		(return from FORTH word)	

; defword: PRESSKEY   TESTED_OK
defword PRESSKEY , PRESSKEY ,0
      		LITN key_press
            dd PRINTCSTRING
            dd TAB
            LITN '!'
            dd EMIT
            dd IN
            dd CLEAR
            dd EXIT		; EXIT		(return from FORTH word)	


; defword: ZEIL   TESTED_OK
defword ZEIL , ZEIL ,0

			LITN 0
			dd TST , STORE
			dd ZEILE ;, TWODROP
			dd CR
			;dd ZEILEMIT 
inter:	    dd INTERPRET
			;dd DOTS ,CR     ; for debug
			
			dd TST1,FETCH    ; endof line Interprt was OK
 			dd ZNEQU
			if  	
			 dd CR
			 LITN ok
			 dd PRINTCSTRING
			 dd CR
			 branch next
			then	 
			
			
		    dd TST,FETCH      ; error in einput stream
 			dd ZNEQU
			if  	
			 LITN errmsg
			 dd PRINTCSTRING
			 branch next
			then	 
			branch inter
next:		dd CR
 			dd CR
            dd PRESSKEY
            LITN 0
            dd DUP
			dd TST , STORE  ;clear Error_flag
            dd TST1 , STORE ;clear End_of_Line flag
            LITN zeile_buffer
            
			dd PPTR , STORE
            dd CLEAR
            dd CLSSTACK
            dd DROP
 			dd EXIT		; EXIT		(return from FORTH word)

; defword: DUMP   NOT TESTED_OK
defword DUMP , DUMP ,0
;: DUMP		( addr len -- )
;	BASE @ -ROT		( save the current BASE at the bottom of the stack )
;	HEX			( and switch to hexadecimal mode )
;	BEGIN
;		?DUP		( while len > 0 )
;	WHILE
;		OVER 8 U.R	( print the address )
;		SPACE		( print up to 16 words on this line )
;		2DUP		( addr len addr len )
;		1- 15 AND 1+	( addr len addr linelen )
;		BEGIN
;			?DUP		( while linelen > 0 )
;		WHILE
;			SWAP		( addr len linelen addr )
;			DUP C@		( addr len linelen addr byte )
;			2 .R SPACE	( print the byte )
;			1+ SWAP 1-	( addr len linelen addr -- addr len addr+1 linelen-1 )
;		REPEAT
;		DROP		( addr len )
;		( print the ASCII equivalents )
;		2DUP 1- 15 AND 1+ ( addr len addr linelen )
;		BEGIN
;			?DUP		( while linelen > 0)
	;	WHILE
;			SWAP		( addr len linelen addr )
;			DUP C@		( addr len linelen addr byte )
;			DUP 32 128 WITHIN IF	( 32 <= c < 128? )
;				EMIT
;			ELSE
;				DROP '.' EMIT
;			THEN
;			1+ SWAP 1-	( addr len linelen addr -- addr len addr+1 linelen-1 )
;		REPEAT
;		DROP		( addr len )
;		CR
;		DUP 1- 15 AND 1+ ( addr len linelen )
;		TUCK		( addr linelen len linelen )
;		-		( addr linelen len-linelen )
;		>R + R>		( addr+linelen len-linelen )
;	REPEAT
;	DROP			( restore stack )
;	BASE !			( restore saved BASE )
	dd BASE ,FETCH, NROT , HEX
	begin
		dd QDUP
	while
		dd OVER 
		LITN 8 
		dd UDOTR ,SPACE , TWODUP , DECR
		LITN 15 
		dd AND ,INCR
		begin
			dd QDUP
		while
			dd SWAP ,DUP ,FETCHBYTE
			LITN 2 
			dd DOTR ,SPACE ,INCR ,SWAP , DECR
		repeat
		dd DROP , TWODUP , INCR 
		LITN 15 
		dd AND ,INCR
		begin
			dd QDUP
		while
			dd SWAP ,DUP 
			LITN 32 
			LITN 128
			dd WITHIN
			if 
				dd EMIT
			else
				LITN '.'
				dd EMIT
			then
			dd INCR,SWAP ,DECR
		repeat
		dd DROP ,CR ,DUP ,DECR 
		LITN 15 
		dd AND , INCR ,TUCK , SUB ,TOR ,ADD , FROMR
	repeat
	dd DROP
	dd BASE ,STORE
dd EXIT		; EXIT		(return from FORTH word)

; defword: WELCOME must be the LAST WORD !! LATEST points here <==
wel:
defword WELCOM , WELCOM ,0  
			
			LITN zeile_buffer
			dd PPTR , STORE
			dd CLEAR
            dd CR
			dd CR
            LITN 15
            dd INK
            LITN osname
            dd PRINTCSTRING
            LITN 10              ; for i = 10 to 0
            LITN 0                  ;
            do
             dd CR
            loop
            LITN colofon
            dd PRINTCSTRING
            LITN 10              ; for i = 10 to 0
            LITN 0                  ;
            do
             dd CR
            loop
            dd PRESSKEY
 			dd EXIT		; EXIT		(return from FORTH word)  
 			 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; no defcode or defword afther this line
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
