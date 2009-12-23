%include "rest.s"

defword test , test ,0
      ;--------TESTING words------------------
      ;********WITHIN****OK*******************
      ;( c a b WITHIN returns true if a <= c and c < b )
      LITN 5    ; b
      LITN 10   ; a
      LITN 30   ; b
      dd DOTS   ; ( c a b )
      dd WITHIN 
       dd DOTS  ; TRUE ?
       dd DROP
      dd CR
      LITN 05   ; c   ------OK TRUE
      LITN 30   ; a
      LITN 10   ; b
      dd DOTS   ; ( c a b )
      dd WITHIN 
       dd DOTS  ; TRUE ?
      dd DROP 
      dd CR
      LITN 30   ; c
      LITN 10   ; a
      LITN  5   ; b
      dd DOTS   ; ( c a b )
      dd WITHIN 
      dd DOTS
      dd DROP 
      dd CR
dd EXIT		; EXIT		(return from FORTH word)


defword within_test , within_test ,0
      ;--------TESTING words------------------
      ;********WITHIN****OK*******************
      ;( c a b WITHIN returns true if a <= c and c < b )
      LITN 5    ; b
      LITN 10   ; a
      LITN 30   ; b
      dd DOTS   ; ( c a b )
      dd WITHIN 
      dd DOTS  ; TRUE ? NO
      dd DROP
      dd CR
      LITN 05   ; c   ------OK TRUE
      LITN 30   ; a
      LITN 10   ; b
      dd DOTS   ; ( c a b )
      dd WITHIN 
      dd DOTS  ; TRUE ? YES
      dd DROP 
      dd CR
      LITN 30   ; c
      LITN 10   ; a
      LITN  5   ; b
      dd DOTS   ; ( c a b )
      dd WITHIN 
      dd DOTS  ; TRUE ? NO
      dd DROP 
      dd CR
dd EXIT		; EXIT		(return from FORTH word)

;%include "kernel.s"
