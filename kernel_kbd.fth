; program: kernel_kbd
; Words related to the keyboard driver

; License: GPL
; José Dinuncio <jdinunci@uc.edu.ve>, 12/2009.

%include "forth.h"
%include "kernel_words.h"
%include "kernel_video.h"

extern keymap
%define keymap keymap

[BITS 32]
%define _key_stat_caps 0x01
%define _key_stat_shift 0x02

; variable: key_status
;   Store the status of caps, shift and CONTROL keys.
defvar key_status, key_status, 0, 0

; function: kbd_flags
;   Returns the keyboard status code.
;
; Stack:
;   -- kbd_status
: kbd_flags, kbd_flags, 0
    0x64 inb
;

; function: kbd_buffer_full
;   true if there is a scancode waiting to be readed
;
; Stack:
;   -- bool
: kbd_buffer_full, kbd_buffer_full, 0
    kbd_flags 1 and
;

; function: kbd_scancode_now
;   Returns the scancode readed on the keyboard at this moment.
;
; Stack:
;   -- scancode
: kbd_scancode_now, kbd_scancode_now, 0
    0x60 inb
;

; function: kbd_scancode
;   Waits for a key pressed and returns its sacancode.
;
; Stack:
;   -- scancode
: kbd_scancode, kbd_scancode, 0
    begin kbd_buffer_full until
    kbd_scancode_now 0xFF and
;


; function _tx_key_status
;   Test and xor the key_status variable.
;
;   If the scancode is equal to the given test, makes an xor
;   between key_status and flags.
;
; stack:
;   scancode test flag --
: _tx_key_status, _tx_key_status, 0
    -rot =
    if
        key_status @ xor  key_status !
    else
        drop
    then
;

; function: _update_key_status
;   Updates the kbd_flags variable according with the scancode given.
;
; Stack:
;   scancode --
: _update_key_status, _update_key_status, 0
    ; TODO - xor could fail in some cases. Set o clear the bit.
    dup 58    _key_stat_caps  _tx_key_status      ; caps   down
    dup 42    _key_stat_shift _tx_key_status      ; lshift down
    dup 170   _key_stat_shift _tx_key_status      ; lshift up
    dup 54    _key_stat_shift _tx_key_status      ; rshift down
    dup 182   _key_stat_shift _tx_key_status      ; rshift up

    drop
;

; stack:
;   scancode -- bool
: _key_down?, _key_down, 0
    0x80 and 0=
;

; function: sc>c (SCANCODE2CHAR)
;   Converts a scancode to an ASCII character.
; 
;   If the scancode correspond to keyup or to a non-character
;   it returns 0
;
; stack:
;   scancode -- char
: sc>c, scancode2char, 0
    dup _key_down? if
        4 *   key_status @  +  keymap + c@
    else 0 then
;

; function: getchar
;   Waits for a key to be pressed and then returns its ASCII code.
;
; Stack:
;   -- c
: getchar, getchar, 0
    0
    begin
        drop
        kbd_scancode 
        dup _update_key_status
        sc>c dup
    until
;

