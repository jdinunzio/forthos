; file: ext
; by august0815
; 19.12.2009


%include "kernel_kbd.s"

; TODO clean up 
;
; remove not used code
section .text
ASO     EQU     '['
ASC     EQU     ']'
CW      EQU     4 
D_HOFFSET EQU     1

; function: KEY  NOT_TESTED_NOT_USED
defcode KEY,KEY,0
	call	 _KEY
	push	eax		;// push return value on stack
	NEXT
_KEY:
	mov	ebx, [currkey]
	cmp	ebx, [bufftop]
	jge	.1			;// exhausted the input buffer?
	xor	eax, eax
	mov	al, [ebx]	;	// get next key from input buffer
	inc	ebx
	mov	[currkey], ebx	;// increment currkey
	ret

.1:
	;// Out of input; use [2+read] to fetch more input from stdin.
	xor	ebx, ebx		;// 1st param: stdin
	mov	ecx, buffer	;// 2nd param: buffer
	mov	[currkey], ecx
	call sys_key
	test eax,eax	;	// If eax <= 0, then exit.
	jbe	.2
	add	dword ecx, eax	;	// buffer+eax = bufftop
	mov	[bufftop], ecx
	jmp	 _KEY

.2:
	;// Error or end of input: exit the program.
	;xor	ebx, ebx
	;mov	eax, __NR_exit	// syscall: exit
	;int	0x80
    ret
section .data
align 4
currkey:
 dd buffer		;// Current place in input buffer (next character to read).
bufftop:
 dd buffer	;// Last valid data in input buffer + 1.





; function: TWORD   (rename later to WORD?) NOT_TESTED_NOT_USED
defcode TWORD , TRWORD , 0
	call	 _WORD
	push	edi	;	// push base address
	push	ecx	;	// push length
	NEXT

_WORD:
.1:
	call	 _KEY ;		// get next key, returned in eax
	;cmp	0x92,al	;	// start of a comment?
	cmp al,'\'		; start of a comment?
	je .3			;// if so, skip the comment
	cmp	 al,' '
	jne .1			;// if so, keep looking

	mov	edi, word_buffer	;// pointer to return buffer
.2:
	stosb	;		// add character to return buffer
	call	 _KEY	;	// get next key, returned in al
	cmp	 al,0x32	;	// is blank?
	ja .2			;// if not, keep looping

	sub	edi, word_buffer
	mov	ecx, edi	;	// return length of the word
	mov	edi, word_buffer;	// return address of the word
	ret

.3:
	call _KEY
	cmp	 al,$13	;	// end of line yet?
	jne	.3
	jmp	dword .1

section .data

;	// A static buffer where WORD returns.  Subsequent calls
;	// overwrite this buffer.  Maximum word length is 32 chars.
word_buffer: times 256 db 0


; function: ZEILE  ; einlesen einer Zeile bis CR   TESTED_OK
;
; edi  push base address
; ecx		 push length
;zeile_buffer:  ist 1024 byte lang
defcode ZEILE , ZEILE , 0
	call _ZEILE
	push edi		; push base address
	push ecx		; push length
	NEXT
_ZEILE:
	
.1: mov edi,zeile_buffer	; pointer to return buffer
.2:	call sys_key 
    cmp al,0x08			; if not BS
	jne .3  			;
	call rubout         ;
	jmp .2				; get next
.3	stosb				; add character to return buffer
.4	cmp al,0x13			; is < CR
	ja .2           	;getnext
	dec edi
	mov al,' '
	stosb
	mov al,0x0          ; lastword marker
	stosb
	;/* Return the word (well, the static buffer) and length. */
	sub edi,zeile_buffer
	mov ecx,edi		; return length of the word
	mov edi,zeile_buffer	; return address of the word
	ret

section	.data			; NB: easier to fit in the .data section
	; A static buffer where WORD returns.  Subsequent calls
	; overwrite this buffer.  Maximum word length is 1024 chars.
zeile_buffer: times 1024 db 0

section .text
rubout:
		dec edi
		push    eax
		push    ebx
        push    ecx
        dec dword [var_CURSOR_POS_X]
        mov al,' '
        and     eax,0x000000FF
        or      eax,[var_SCREEN_COLOR]
        mov     ecx,eax
        mov     eax,[var_CURSOR_POS_X]
        mov     ebx,[var_CURSOR_POS_Y]
        push    ebx
        imul    ebx,[video_width]
        add     eax,ebx
        shl     eax,1
        add     eax,[video_base]
        pop     ebx
        mov     [eax],cx
        pop     ecx
        pop     ebx
        pop     eax
	ret	
	
; function:  NUMBER  TESTED_OK
;
; IN : ecx 	 length of string
;
;     edi 	 start address of string
;
; OUT:eax parsed number
;
;     ecx number of unparsed characters (0 = no error)
defcode NUMBER,NUMBER,0
	pop ecx		; length of string
	pop edi		; start address of string
	call _NUMBER
	push eax		; parsed number
	push ecx		; number of unparsed characters (0 = no error)
	NEXT
_NUMBER:
	xor eax,eax
	xor ebx,ebx
	test ecx,ecx		; trying to parse a zero-length string is an error, but will return 0.
	jz .5
	mov edx,[var_BASE]	; get BASE (in %dl)
	; Check if first character is '-'.
	mov bl,[edi]		; %bl = first character in string
	inc edi
	push eax		; push 0 on stack
	cmp bl,'-'		; negative number?
	jnz .2
	pop eax
	push ebx		; push <> 0 on stack, indicating negative
	dec ecx
	jnz .1
	pop ebx		; error: string is only '-'.
	mov ecx, $1
	ret
	; Loop reading digits.
.1:	imul eax,edx		; %eax *= BASE
	mov bl,[edi]		; %bl = next character in string
	inc edi
	; Convert 0-9, A-Z to a number 0-35.
.2:	sub bl,'0'		; < '0'?
	jb .4
	cmp bl,$10		; <= '9'?
	jb .3
	sub bl,$17		; < 'A'? (17 is 'A'-'0')
	jb .4
	add bl,$10
.3:	cmp bl,dl		; >= BASE?
	jge .4
	; OK, so add it to %eax and loop.
	add eax,ebx
	dec ecx
	jnz .1
	; Negate the result if first character was '-' (saved on the stack).
.4:	pop ebx
	test ebx,ebx
	jz .5
	neg eax
.5:	ret


; function: FIND   TESTED_OK
;
; IN: ecx = length
; edi = address
;
;OUT: ; eax = address of dictionary entry (or NULL)
	defcode FIND,FIND,0
	pop ecx		; ecx = length
	pop edi		; edi = address
	call _FIND
	
	push eax		; eax = address of dictionary entry (or NULL)
	NEXT
_FIND:
    push esi		; Save esi so we can use it in string comparison.
	; Now we start searching backwards through the dictionary for this word.
	mov edx,[var_LATEST]	; LATEST points to name header of the latest word in the dictionary
.1:	test edx,edx		; NULL pointer?  (end of the linked list)
	je .4
	; Compare the length expected and the length of the word.
	; Note that if the F_HIDDEN flag is set on the word, then by a bit of trickery
	; this won't pick the word (the length will appear to be wrong).
	xor eax,eax
	mov al,[edx+4]	; %al = flags+length field
	and al,(F_HIDDEN|F_LENMASK) ; %al = name length
	cmp byte al,cl		; Length is the same?
	jne .2
	; Compare the strings in detail.
	push ecx		; Save the length
	push edi		; Save the address (repe cmpsb will move this pointer)
	lea esi,[edx+5]	; Dictionary string we are checking against.
	repe cmpsb		; Compare the strings.
	pop edi
	pop ecx
	jne .2			; Not the same.
	; The strings are the same - return the header pointer in %eax
	pop esi
	mov eax,edx
	ret
.2:	mov edx,[edx]		; Move back through the link field to the previous word
	jmp .1			; .. and loop.
.4:	; Not found.
	pop esi
	xor eax,eax		; Return zero to indicate not found.
	ret



; function: ">CFA"  TESTED_OK
	defcode >CFA,TCFA,0
	pop edi
	call _TCFA
	push edi
	NEXT
_TCFA:
	xor eax,eax
	add edi,4		; Skip link pointer.
	mov al,[edi]		; Load flags+len into %al.
	inc edi		; Skip flags+len byte.
	and al,F_LENMASK	; Just the length, not the flags.
	add edi,eax		; Skip the name.
	add edi,3		; The codeword is 4-byte aligned.
	and edi,~3
	ret



; function: >DFA
defword >DFA,TDFA,0
	dd TCFA		; >CFA		(get code field address)
	dd INCR4		; 4+		(add 4 to it to get to next word)
	dd EXIT		; EXIT		(return from FORTH word)
	
; function: CREATE
defcode CREATE, CREATE, 0
	
    pop ecx		; %ecx = length
	pop ebx		; %ebx = address of name
	; Link pointer.
	mov  edi,[var_HERE]	; %edi is the address of the header
	mov  eax,[var_LATEST]	; Get link pointer
	stosd			; and store it in the header.
	; Length byte and the word itself.
	mov al,cl		; Get the length.
	stosb			; Store the length/flags byte.
	push esi
	mov esi,ebx		; %esi = word
	rep movsb		; Copy the word
	pop esi
	add edi,3		; Align to next 4 byte boundary.
	and edi,~3
	
	; Update LATEST and HERE.
	mov  eax,[var_HERE]
	mov dword [var_LATEST], eax
	mov dword [var_HERE],edi
    NEXT


; defcode; ","
	defcode COMMA ,COMMA ,0
	
	pop eax		; Code pointer to store.
	call _COMMA
	NEXT
_COMMA:
    
	mov edi,[var_HERE]	; HERE
	stosb			; Store it.
	mov dword [var_HERE],edi,	; HERE
	ret

; function: [   TESTED_OK
defcode [ ,LBRAC,F_IMMED ;;F_IMMED,LBRAC,0
	xor eax,eax
	mov dword [var_STATE],eax	; Set STATE to 0.
	NEXT
; defcode ]	   TESTED_OK
	defcode ],RBRAC,0
	mov dword [var_STATE],1	; Set STATE to 1.
	NEXT

; function: ":"   ; bug ,bug ,bug !!
defword COL , COLON  ,0
	dd _tlwd		; Get the name of the new word
	
	;LITN ptr_buff
    ;dd PRINTCSTRING
    dd STOP ; remove later
	dd CREATE		; CREATE the dictionary entry / header
	LITN ngef
    dd PRINTCSTRING
    dd STOP
	dd LIT, DOCOL, COMMA	; Append DOCOL  (the codeword).
	dd LATEST, FETCH, HIDDEN ; Make the word hidden (see below for definition).
	dd RBRAC		; Go into compile mode.
	dd EXIT		; Return from the function.

; function: ;     ; bug , bug !!
defword SK ,SEMICOLON,F_IMMED ;F_IMMED
    ;LITN ngef
    ;dd PRINTCSTRING
    dd STOP ;remove !!!!
	dd LIT, EXIT, COMMA	; Append EXIT (so the word will return).
	dd LATEST, FETCH, HIDDEN ; Toggle hidden flag -- unhide the word (see below for definition).
	dd LBRAC		; Go back to IMMEDIATE mode.
	dd EXIT		; Return from the function.

; function: IMMEDIATE  not tested
	defcode IMMEDIATE , IMMEDIATE , F_IMMED
	mov edi,[var_LATEST]	; LATEST word.
	add edi,4		; Point to name/flags byte.
	xor	byte [edi], F_IMMED	; Toggle the IMMED bit.
	NEXT

; function: HIDDEN
	defword HIDDEN,HIDDEN,0
	pop edi		; Dictionary entry.
	add edi,4		; Point to name/flags byte.
	xor byte [edi],F_HIDDEN	; Toggle the HIDDEN bit.
	dd EXIT ;NEXT
	
; function: HIDE	
	defword HIDE,HIDE,0
	dd TRWORD		; Get the word (after HIDE).
	dd FIND		; Look up in the dictionary.
	dd HIDDEN		; Set F_HIDDEN flag.
	dd EXIT		; Retur




; function: "QUIT",4,,QUIT	not used !! remove
; QUIT must not return (ie. must not call EXIT).
	defword QUIT,QUIT,0
	;dd RZ,RSPSTORE	; R0 RSP!, clear the return stack
	 LITN 10              ; for i = 0 to 80*25
            LITN 0                  ;
            do
            dd IN
            dd EMIT
             LITN 8*3              ; for i = 0 to 80*25
             LITN 0                  ;
             do
 			 LITN '+'
 			 dd EMIT
 			 loop
 			dd CR
 			dd INTERPRET
 			loop
	dd INTERPRET		; interpret the next word
	;branch (-8)		; and loop (indefinitely)	

	

; function: "'"
	defcode TT,TICK,0
	lodsd			; Get the address of the next word and skip it.
	push eax		; Push it on the stack.
	NEXT
	
; TODO Branching??

; function: "LITSTRING",9,,LITSTRING
	defcode LITSTRING,LITSTRING,0
	lodsd			; get the length of the string
	push esi		; push the address of the start of the string
	push eax		; push it on the stack
	add esi,eax		; skip past the string
 	add esi,3		; but round up to next 4 byte boundary
	and esi,~3
	NEXT

; function: TELL   rewrite it !!!! still for linux
defcode TELL ,TELL , 0
	mov ebx,1		; 1st param: stdout
	pop edx		; 3rd param: length of string
	pop ecx		; 2nd param: address of string
	;;;;;;;;;;;;;;;;;;;;;;;;;;,mov eax,__NR_write	; write syscall
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;int $0x80
	NEXT
	

; function: TEILWORT  rename later to WORD ; TESTED_OK 
;
; gibt den pointer des strings aus zeilenbuffer bis zum Leerzeichen
; zurück , PPTR zeigt danach auf das nächste Wort
; edi  		; push base address
; ecx		; push length

defcode TEILWORT , TEILWORT , 0
	call _tlwd
	push edi		; push base address
	push ecx		; push length
	NEXT

_tlwd:
	;/* Search for first non-blank character.  Also skip \ comments. */
    mov ebx,[var_PPTR]
.1:
	mov al,[ebx] ;_KEY		; get next key, returned in %eax
	test al,al
	jnz .5
	mov dword [var_TST1],0xffff
	ret
.5	inc ebx
	cmp al,'\'		; start of a comment?
	je .3			; if so, skip the comment
	cmp al,' '
	jbe .1			; if so, keep looking
	;/* Search for the end of the word, storing chars as we go. */
	mov edi,ptr_buff	; pointer to return buffer
.2:
	stosb			; add character to return buffer
	mov al,[ebx] ;_KEY		; get next key, returned in %eax
	inc ebx; _KEY		; get next key, returned in %al
	cmp al,' '		; is blank?
	ja .2			; if not, keep looping
	
	;/* Return the word (well, the static buffer) and length. */
	sub edi,ptr_buff
	mov ecx,edi		; return length of the word
	mov edi,ptr_buff	; return address of the word
	mov dword [var_PPTR],ebx
	ret
.4:	
	;/* Code to skip \ comments to end of the current line. */
.3:
	mov al,[ebx] ;_KEY		; get next key, returned in %eax
	inc ebx ;_KEY
	cmp al,$13	; end of line yet?
	jne .3
	jmp .1

section .data			; NB: easier to fit in the .data section
	; A static buffer where WORD returns.  Subsequent calls
	; overwrite this buffer.  Maximum word length is 256 chars.
ptr_buff: times 256 db 0
		
section .text
;defcode: INTERPRET   compilinf fails!!
	defcode INTERPRET,INTERPRET,0  
	mov	dword [var_TST],0	
	call _tlwd ; Returns %ecx = length, %edi = pointer to word.
 	
	; Is it in the dictionary?
	xor eax,eax
	mov dword [interpret_is_lit],eax ; Not a literal number (not yet anyway ...)
	call _FIND		; Returns %eax = pointer to header or 0 if not found.
	test eax,eax		; Found?
	jz .1
	
	; In the dictionary.  Is it an IMMEDIATE codeword?
	mov edi,eax		; %edi = dictionary entry
	mov al,[edi+4]	; Get name+flags.
	push ax		; Just save it for now.
	call _TCFA		; Convert dictionary entry (in %edi) to codeword pointer.
	pop ax
	and al,0x80     ;F_IMMED	; Is IMMED flag set?
	mov eax,edi
	
	jz .4 ;jnz .4			; If IMMED, jump straight to executing.
    
	jmp .2

.1:	; Not in the dictionary (not a word) so assume it's a literal number.
    ;
	inc dword [interpret_is_lit]
	call _NUMBER		; Returns the parsed number in %eax, %ecx > 0 if error
	test ecx,ecx
	jnz .6
	mov ebx,eax
	mov eax,LIT		; The word is LIT

.2:	; Are we compiling or executing?
    mov edx,[var_STATE]
	test edx,edx
	jz .4			; Jump if executing.
	; Compiling - just append the word to the current dictionary definition.
	mov edi,[var_HERE]	; HERE
	stosb			; Store it.
	mov dword [var_HERE],edi,	; HERE
	mov ecx,[interpret_is_lit] ; Was it a literal?
	test ecx,ecx
	jz .3
	mov eax,ebx		; Yes, so LIT is followed by a number.
	mov edi,[var_HERE]	; HERE
	stosb			; Store it.
	mov dword [var_HERE],edi,	; HERE
.3:	NEXT

.4:	; Executing - run it!
	mov ecx,[interpret_is_lit] ; Literal?
	test ecx,ecx		; Literal?
	jnz .5
    ; Not a literal, execute it now.  This never returns, but the codeword will
	; eventually call NEXT which will reenter the loop in QUIT.
	jmp [eax]

.5:	; Executing a literal, which means push it on the stack.
	push ebx
	NEXT

.6:	; Parse error (not a known word or a number in the current BASE).
	; Print an error message followed by up to 40 characters of context.
	;mov ebx,2		; 1st param: stderr
	mov	dword [var_TST] ,0xffff
	NEXT

	NEXT
;interpret_is_lit db 0

errmsg: db 'PARSE ERROR: ' ,0
in_len db 0
in_point db 0

;in_buff: resb 256

;%include "ext1.s"
