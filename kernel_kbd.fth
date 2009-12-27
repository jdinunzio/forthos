; program: kernel_kbd
; Words related to the keyboard driver

; License: GPL
; José Dinuncio <jdinunci@uc.edu.ve>, 12/2009.

%include "forth.h"
%include "kernel_words.h"
%include "kernel_video.h"

extern keymap
%define KEYMAP keymap

[BITS 32]
%define _KEY_STAT_CAPS 0x01
%define _KEY_STAT_SHIFT 0x02

; variable: KEY_STATUS
;   Store the status of CAPS, SHIFT and CONTROL keys.
defvar KEY_STATUS, KEY_STATUS, 0, 0

; function: KBD_FLAGS
;   Returns the keyboard status code.
;
; Stack:
;   -- kbd_status
: KBD_FLAGS, KBD_FLAGS, 0
    0x64 INB
;

; function: KBD_BUFFER_FULL
;   true if there is a scancode waiting to be readed
;
; Stack:
;   -- bool
: KBD_BUFFER_FULL, KBD_BUFFER_FULL, 0
    KBD_FLAGS 1 AND
;

; function: KBD_SCANCODE_NOW
;   Returns the scancode readed on the keyboard at this moment.
;
; Stack:
;   -- scancode
: KBD_SCANCODE_NOW, KBD_SCANCODE_NOW, 0
    0x60 INB
;

; function: KBD_SCANCODE
; Waits for a key pressed and returns its sacancode.
;
; Stack:
; -- scancode
: KBD_SCANCODE, KBD_SCANCODE, 0
    begin KBD_BUFFER_FULL until
    KBD_SCANCODE_NOW 0xFF AND
;


; function _TX_KEY_STATUS
;   Test and XOR the KEY_STATUS variable.
;
;   If the scancode is equal to the given test, makes an XOR
;   between KEY_STATUS and flags.
;
; stack:
;   scancode test flag --
: _TX_KEY_STATUS, _TX_KEY_STATUS, 0
    -ROT =
    if
        KEY_STATUS @ XOR  KEY_STATUS !
    else
        DROP
    then
;

; function: _UPDATE_KEY_STATUS
;   Updates the KBD_FLAGS variable according with the scancode given.
;
; Stack:
;   scancode --
: _UPDATE_KEY_STATUS, _UPDATE_KEY_STATUS, 0
    # TODO - XOR could fail in some cases. Set o clear the bit.
    DUP 58    _KEY_STAT_CAPS  _TX_KEY_STATUS      # CAPS   down
    DUP 42    _KEY_STAT_SHIFT _TX_KEY_STATUS      # LSHIFT down
    DUP 170   _KEY_STAT_SHIFT _TX_KEY_STATUS      # LSHIFT up
    DUP 54    _KEY_STAT_SHIFT _TX_KEY_STATUS      # RSHIFT down
    DUP 182   _KEY_STAT_SHIFT _TX_KEY_STATUS      # RSHIFT up

    DROP
;

; stack:
;   scancode -- bool
: _KEY_DOWN?, _KEY_DOWN, 0
    0x80 AND 0=
;

; function: SC>C (SCANCODE2CHAR)
;   Converts a scancode to an ASCII character.
; 
;   If the scancode correspond to keyup or to a non-character
;   it returns 0
;
; stack:
;   scancode -- char
: SC>C, SCANCODE2CHAR, 0
    DUP _KEY_DOWN? if
        4 *   KEY_STATUS @  +  KEYMAP + C@
    else 0 then
;

; function: GETCHAR
;   Waits for a key to be pressed and then returns its ASCII code.
;
; Stack:
;   -- c
: GETCHAR, GETCHAR, 0
    0
    begin
        DROP
        KBD_SCANCODE 
        DUP _UPDATE_KEY_STATUS
        SC>C DUP
    until
;

