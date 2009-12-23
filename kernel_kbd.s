; file: kernel_kbd

; Topic: kernel_kbd
; This file defines the words to manipulate the keyboard

%include "kernel_video.s"

[BITS 32]
;THIS IS CODE FORM retro8 by crc
;			
; function: IN
; Returns the key pressed
;
; Stack:
; -- char
;
; Parameters:
; key - ASCII char of the key pressed.
defcode IN ,IN ,0 ; TESTED_OK
		call sys_key
		NEXT

;THIS IS CODE FORM retro8 by crc
;	rewrite it? some day?		
sys_key:
 	xor   ebx,ebx  		; Show the coursor
	mov   bl,[var_CURSOR_POS_X]				     
	mov   ecx,ebx
	mov   bl,[var_CURSOR_POS_Y]				      
	mov   eax,80
	mul   bx
	add   eax,ecx				       
    mov   edx,0x3d4 
	mov   ecx,eax
	mov   al,15
	out   dx,al
	mov   eax,ecx
	inc   edx
	out   dx,al
	mov   al,14
	dec   edx
	out   dx,al
	mov   eax,ecx
	mov   al,ah
	inc   edx
	out   dx,al			; Show the coursor end
	xor eax,eax	        ;  clear eax
.1:	in al,64h		;  Is any data waiting?
	test al,1	        ;  Is character = ASCII 0?
	jz .1		        ;  Yes? Try again
	in al,60h	        ;  Otherwise, read scancode
	xor edx,edx	        ;  edx: 0=make, 1=break
	test al,80h	        ;  Is character = HEX 80h?
	jz .2		        ;  Skip the next line
	inc edx 	        ;  Update edx
.2:	 and al,7Fh		;  Filters to handle
	cmp al,39h	        ;  the ignored keys
	  ja .1 	        ;  We just try another key
	mov ecx,[board]         ;  Load the keymap
	mov al,[ecx+eax]        ;  Get the key ASCII char
	  or al,al		        ;  Is is = 0?
	js .shift		        ;  No, use CAPITALS
	jz .1		        ;  Ignore 0's
	or dl,dl		        ;  Filter for break code
	jnz .1		        ;  Ignore break code
	;THIS IS CODE FORM retro8 by crc  END
	mov dword [var_KEYBUFF],eax
	   ; echo
        push    eax
        push    ebx
        push    ecx
        cmp		al,0x08 ;don't display BS
        jbe .3
        cmp		al,0x0D ;don't display CR
        jbe .3
        and     eax,0x000000FF
        or      eax,[var_SCREEN_COLOR]
        mov     ecx,eax
        mov     eax,[var_CURSOR_POS_X]
        inc dword [var_CURSOR_POS_X]
        mov     ebx,[var_CURSOR_POS_Y]
     	push    ebx
        imul    ebx,[video_width]
        add     eax,ebx
        shl     eax,1
        add     eax,[video_base]
        pop     ebx
        mov     [eax],cx
.3:
       
        pop     ecx
        pop     ebx
        pop     eax
	ret

;THIS IS CODE FORM retro8 by crc	
.shift:  mov ecx,[edx*4 + .shifts]	 ;  Load the CAPITAL keymap
	mov [board],ecx 	        ;  Store into BOARD pointer
	jmp .1			  ;  And try again
.shifts dd shift,alpha
board dd alpha
alpha:
  db 0,27,"1234567890-=",8	        ;00-0E
  db 9,"qwertyuiop[]",10	        ;0F-1C
  db 0,"asdfghjkl;'`"		        ;1D-29
  db -1,"\zxcvbnm,./",-1,"+",0,32,-2    ;2A-3A
shift:
  db 0,27,"!@#$%^&*()_+",8	        ;00-0E
  db 9,"QWERTYUIOP{}",10	        ;0F-1C
  db 0,'ASDFGHJKL:"~'		        ;1D-29
  db -1,"|ZXCVBNM<>?",-1,"=",0,32,-2    ;2A-3A

;%include "ext.s"
