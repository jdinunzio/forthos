;  program: kernel
;**   ___________________________________________________________________________

; func:   Version 0.01

; section:   Copyright (C) 2009 august0815

 
  
%include "forth_words.s"
;%include "kernel_video.s"

[BITS 32]

; XXX: Mientras se hagan pruebas en kernel_video
; definimos esta variable aca
defconst SCREEN, SCREEN, 0, 0xB8000
defvar PPTR, PPTR, 0 , 0
defvar ISLIT, ISLIT, 0 , 0
defvar TST, TST, 0 , 0
defvar TST1, TST1, 0 , 0
defvar TFFA , TFFA , 0, 0
defvar TNFA , TNFA , 0, 0
defvar RR , RR , 0, 0
defvar ONLYBODY , ONLYBODY , 0, 0
defvar CONTEXT , CONTEXT , 0, 0


; Assembly Entry point
section .text
GLOBAL main
main:
			mov [var_S0],esp 			;Save the initial data stack pointer in FORTH variable S0.
            mov ebp, return_stack_top   ; init the return stack
            mov	dword [var_TST],0
            mov dword [var_STATE],0
            ;mov eax,[label_ENDE]
            ;mov dword[var_LATEST],eax
            mov	dword [currkey], buffer
			mov  dword [bufftop] ,buffer
            mov eax,point_HERE
            mov dword [var_HERE],eax
            mov esi, cold_start         ; fist foth word to exec
            NEXT
            ret

; Forth Entry point
section .rodata
cold_start: 
			dd WELCOM
			dd CLEAR 
mes:        dd MES1
				
 	
			dd DECIMAL
			dd CLEAR
			dd WORDS
 			dd CR
 			dd CR
 			dd PRESSKEY
 			dd test ; do some tests
 			dd PRESSKEY
 			
 			
 			
int: 		dd MES2
 	 	 
			dd ZEIL
     
        	branch int
  
  		    dd STOP
   
interpret_is_lit db 0     
pptr: dw 0            

section .data
bienvenida:     db 'Bienvenido a ', 0
osname          db 'Goyo-OS-FORTH-0.0.1', 0
colofon         db 'Espere cosas grandes de Goyo-OS en el futuro...', 0
ok: 			db '  OK ... ' ,0
key_press: 		db '   PRESS ANY KEY  .... ' , 0
outputmes 		db 'Words of forth' , 0
inputloop		db 'Enter  words' , 0
gef: 			db 'GEFUNDEN' , 0
ngef: 			db 'NICHT IN TABELLE' , 0
stackmes:		db 'STACK> ', 0
in_key:         times 256 db 0

; stacks
section   .bss
align 4096
            RETURN_STACK_SIZE equ 8192
return_stack:
            resb RETURN_STACK_SIZE
return_stack_top:

align 4096
BUFFER_SIZE equ 4096
buffer:
	resb BUFFER_SIZE



point_HERE:

