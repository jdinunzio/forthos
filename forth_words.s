; program: forth_words

; myforth: My own forth system.
; This is a translation of jonesforth 
; [http:;www.annexia.org/_file/jonesforth.s.txt] for being compiled with nasm

%ifndef forth_words
%define forth_words
%include "forth_core.s"

[BITS 32]
; forthword ptrs contains the basic words of a forth interpreter. The escential
; routines and word ptrs are in forthcore.

; defcode: STOP endless loop
defcode STOP, STOP, 0
            jmp $


; defcode: LIT takes the next word (a literal value) in a word definition and stores it in the stack.
defcode LIT, LIT, 0
            lodsd               ; Load the next word in the current definition
            push eax            ; pushes it on the stack
            NEXT                ; and executes the following word
            
;Basic stack word ptrs
; defcode: DROP 
defcode DROP, DROP,0
            pop eax       
            NEXT
; defcode: SWAP
defcode SWAP, SWAP,0
            pop eax       
            pop ebx
            push eax
            push ebx
            NEXT
; defcode: DUP
defcode DUP, DUP, 0
            mov eax, [esp]    
            push eax
            NEXT
; defcode: OVER
defcode OVER, OVER, 0
            mov eax, [esp + 4]   
            push eax      
            NEXT
; defcode: ROT
defcode ROT, ROT, 0
            pop eax
            pop ebx
            pop ecx
            push eax
            push ecx
            push ebx
            NEXT
; defcode: -ROT
defcode -ROT, NROT, 0
            pop eax
            pop ebx
            pop ecx
            push ebx
            push eax
            push ecx
            NEXT
; defcode: 2DROP
defcode 2DROP, TWODROP, 0
            pop eax
            pop eax
            NEXT
; defcode: 2DUP
defcode 2DUP, TWODUP, 0
            mov eax, [esp]
            mov ebx, [esp + 4]
            push ebx
            push eax
            NEXT
; defcode: 2SWAP
defcode 2SWAP, TWOSWAP, 0
            pop eax
            pop ebx
            pop ecx
            pop edx
            push ebx
            push eax
            push edx
            push ecx
            NEXT
; defcode: ?DUP
defcode ?DUP, QDUP, 0
            mov eax, [esp]
            test eax, eax
            jz .1
            push eax
.1: NEXT
; defcode: 1+
defcode 1+, INCR, 0
            ; ( n -- n+1 )
            inc dword [esp]    
            NEXT
; defcode: 1-
defcode 1-, DECR, 0
            dec dword [esp]    
            NEXT
; defcode: 4+
defcode 4+, INCR4, 0
            add dword [esp], 4     
            NEXT
; defcode: 4-
defcode 4-, DECR4, 0
            sub dword [esp], 4     
            NEXT
; defcode: +
defcode +, ADD, 0
            pop eax       
            add [esp], eax   
            NEXT
; defcode: -                                                                   
defcode -, SUB, 0
            pop eax       
            sub [esp], eax   
            NEXT
; defcode: *
defcode *, MUL, 0
            pop eax
            pop ebx
            imul eax, ebx
            push eax      
            NEXT


;            In this FORTH, only /MOD is primitive.  Later we will define the / and MOD word ptrs in
;            terms of the primitive /MOD.  The design of the i386 assembly instruction idiv which
;            leaves both quotient and remainder makes this the obvious choice.

; defcode: /MOD
defcode /MOD, DIVMOD, 0
            xor edx, edx
            pop ebx
            pop eax
            idiv ebx
            push edx      
            push eax      
            NEXT
; defcode: /
defword /, DIV, 0
            dd DIVMOD
            dd SWAP
            dd DROP
            dd EXIT
; defcode: MOD
defword MOD, MOD, 0
            dd DIVMOD
            dd DROP
            dd EXIT

; Comparisons
; defcode: =
defcode =, EQU, 0
            pop eax
            pop ebx
            cmp eax, ebx
            sete al
            movzx eax, al
            push eax
            NEXT
; defcode: <>
defcode <>, NEQU, 0
            pop eax
            pop ebx
            cmp eax, ebx
            setne al
            movzx eax, al
            push eax
            NEXT
; defcode: <
defcode <, LT, 0
            pop eax
            pop ebx
            cmp ebx, eax
            setl al
            movzx eax, al
            push eax
            NEXT
; defcode: >
defcode >, GT, 0
            pop eax
            pop ebx
            cmp ebx, eax
            setg al
            movzx eax, al
            push eax
            NEXT
; defcode: <=
defcode <=, LE, 0
            pop eax
            pop ebx
            cmp ebx, eax
            setle al
            movzx eax, al
            push eax
            NEXT
; defcode: >=
defcode >=, GE, 0
            pop eax
            pop ebx
            cmp ebx, eax
            setge al
            movzx eax, al
            push eax
            NEXT
; defcode: 0=
defcode 0=, ZEQU, 0
            pop eax
            test eax, eax
            setz al
            movzx eax, al
            push eax
            NEXT
; defcode: 0<>
defcode 0<>, ZNEQU, 0
            pop eax
            test eax, eax
            setnz al
            movzx eax, al
            push eax
            NEXT
; defcode: 0<
defcode 0<, ZLT, 0
            pop eax
            test eax, eax
            setl al
            movzx eax, al
            push eax
            NEXT

defcode 0>, ZGT, 0
            pop eax
            test eax, eax
            setg al
            movzx eax, al
            push eax
            NEXT
; defcode: 0<=
defcode 0<=, ZLE, 0
            pop eax
            test eax, eax
            setle al
            movzx eax, al
            push eax
            NEXT
; defcode: 0>=
defcode 0>=, ZGE, 0
            pop eax
            test eax, eax
            setge al
            movzx eax, al
            push eax
            NEXT
; defcode: AND
defcode AND, AND, 0   
            pop eax
            and [esp], eax
            NEXT
; defcode: OR
defcode OR, OR, 0 
            pop eax
            or [esp], eax
            NEXT
; defcode: XOR
defcode XOR, XOR, 0   
            pop eax
            xor [esp], eax
            NEXT
; defcode: INVERT
defcode INVERT, INVERT, 0
            not dword [esp]
            NEXT

; Memory
; defcode: !
defcode !, STORE, 0
            ; ( n addr -- )
            pop ebx       
            pop eax       
            mov [ebx], eax    
            NEXT
; defcode: @
defcode @, FETCH, 0
            pop ebx       
            mov eax, [ebx]    
            push eax      
            NEXT
; defcode: +!
defcode +!, ADDSTORE, 0
            pop ebx       
            pop eax       
            add [ebx], eax   
            NEXT
; defcode: -!
defcode -!, SUBSTORE, 0
            pop ebx       
            pop eax       
            sub [ebx], eax   
            NEXT
; defcode: C!
defcode C!, STOREBYTE, 0
            pop ebx       
            pop eax       
            mov [ebx], al    
            NEXT
; defcode: C@
defcode C@, FETCHBYTE, 0
            pop ebx       
            xor eax, eax
            mov al, [ebx]    
            push eax      
            NEXT
; defcode: W!
defcode W!, STOREWORD, 0
            pop ebx       
            pop eax       
            mov [ebx], ax    
            NEXT
; defcode: W@
defcode W@, FETCHWORD, 0
            pop ebx       
            xor eax, eax
            mov ax, [ebx]    
            push eax      
            NEXT

; C@C! is a useful byte copy primitive. */
; defcode: C@C!
defcode C@C!, CCOPY, 0
            mov ebx, [esp + 4]  	;movl 4(%esp),%ebx	// source address
            mov al, [ebx]    		;movb (%ebx),%al		// get source character
            pop edi       			;pop %edi		// destination address
            stosb          			;stosb			// copy to destination
            push edi    			;push %edi		// increment destination address
            inc dword [esp + 4]     ;incl 4(%esp)		// increment source address  
            NEXT
; defcode: CMOVE
; and CMOVE is a block copy operation. */
defcode CMOVE, CMOVE, 0
            mov edx, esi      
            pop ecx       
            pop edi       
            pop esi       
            rep movsb      
            mov esi, edx      
            NEXT

; defcode:  >R  Return Stack
 defcode >R, TOR, 0
            pop eax       
            PUSHRSP eax       
            NEXT
; defcode: R>
defcode R>, FROMR, 0
            POPRSP eax    
            push eax      
            NEXT
; defcode: RSP@
defcode RSP@, RSPFETCH, 0
            push ebp
            NEXT
; defcode: RSP!
defcode RSP!, RSPSTORE, 0
            pop ebp
            NEXT
; defcode: RDROP
defcode RDROP, RDROP, 0
            add ebp, 4       
            NEXT

; Branching
; defcode: BRANCH
defcode BRANCH, BRANCH, 0
            add esi, [esi]
            NEXT
; defcode: 0BRANCH
defcode 0BRANCH, ZBRANCH, 0
            pop eax
            test eax, eax
            jz code_BRANCH 
            lodsd           
            NEXT

; Data stack manipulation
; defcode: DSP@
defcode DSP@, DSPFETCH, 0
    mov eax, esp
    push eax
    NEXT
; defcode: DSP!
defcode DSP!, DSPSTORE, 0
    pop esp
    NEXT

; Shift and Rotate
; defcode: SHL
defcode SHL, SHL, 0
    ; ( n1 n2 -- n1 << n2)
    pop ecx
    pop eax
    shl eax, cl
    push eax
    NEXT
; defcode: SHR
defcode SHR, SHR, 0
    ; ( n1 n2 -- n1 >> n2)
    pop ecx
    pop eax
    shr eax, cl
    push eax
    NEXT
; defcode: N_BYTE
defword N_BYTE, N_BYTE, 0
    ; Gives the n-th byte of a cell
    ; ( b3b2b1b0 n -- bn)
    LITN 8
    dd MUL
    dd SHR
    LITN 0xff
    dd AND
    dd EXIT

%include "kernel_video.s"

	
%endif

