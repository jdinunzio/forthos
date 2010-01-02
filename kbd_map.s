; program: kbd_map
;   Define a keyword map

; License: GPL
; Author: José Dinuncio

; topic: Keyboard Maps
;
; A keyboard map is defined as a table for the scancodes of the keyboard.
; Each scancode has associated 4 characters:
;
;   char, caps+char, shift+char, caps+shift+char
;
; If a scancode must not be translated to a char, use 0
;%define keymap keymap

section .rodata
global keymap
keymap:

# Scancode 0
    db      0,0,0,0,         0,0,0,0,        "11!!",        "22@@",  ; -- ESC
    db      "33##",          "44$$",         "55%%",        "66^^" 
    db      "77&&",          "88**",         "99((",        "00))" 
    db      "--__",          "==++",         0,0,0,0,       0,0,0,0  ; BCK  tab
    db      "qQQq",          "wWWw",         "eEEe",        "rRRr" 
    db      "tTTt",          "yyyy",         "uUUu",        "iIIi" 
    db      "oOOo",          "pPPp",         "[[{{",        "]]}}" 
    db      0,0,0,0,         0,0,0,0,        "aAAa",        "sSSs"   ; ENTER CTL
# Scancode 32
    db      "dDDd",          "fFFf",         "gGGg",        "hHHh" 
    db      "jJJj",          "kKKk",         "lLLl",        ";;::" 
    db    "''",'"','"',      "``~~",         0,0,0,0,     '\','\',"||"  ; lshift
    db      "zZZz",          "xxxx",         "cCCc",        "vVVv" 
    db      "bBBb",          "nNNn",         "mMMm",        ",,<<" 
    db      "..>>",          "//??",         0,0,0,0,       0,0,0,0  ; rshift PtScr
    db      0,0,0,0,         "    ",         0,0,0,0,       0,0,0,0  ; ALt CpsLck F1
    db      0,0,0,0,         0,0,0,0,        0,0,0,0,       0,0,0,0  ; F2 F3 F4 F5
# Scancode 64
    db      0,0,0,0,         0,0,0,0,        0,0,0,0,       0,0,0,0  ; F6 F7 F8 F9
    db      0,0,0,0,         0,0,0,0,        0,0,0,0,       '7777'   ; F10 NumLck ScrLck Home
    db      '8888',          '9999',         "----",        "4444"   ; up pgUp
    db      "5555",          "6666",         "++++",        "1111" 
    db      "2222",          "3333",         "0000",        0,0,0,0  ; DEL
    db      0,0,0,0,         0,0,0,0,        0,0,0,0,       0,0,0,0
    db      0,0,0,0,         0,0,0,0,        0,0,0,0,       0,0,0,0
    db      0,0,0,0,         0,0,0,0,        0,0,0,0,       0,0,0,0
# Scancode 96
    db      0,0,0,0,         0,0,0,0,        0,0,0,0,       0,0,0,0
    db      0,0,0,0,         0,0,0,0,        0,0,0,0,       0,0,0,0
    db      0,0,0,0,         0,0,0,0,        0,0,0,0,       0,0,0,0
    db      0,0,0,0,         0,0,0,0,        0,0,0,0,       0,0,0,0
    db      0,0,0,0,         0,0,0,0,        0,0,0,0,       0,0,0,0
    db      0,0,0,0,         0,0,0,0,        0,0,0,0,       0,0,0,0
    db      0,0,0,0,         0,0,0,0,        0,0,0,0,       0,0,0,0
    db      0,0,0,0,         0,0,0,0,        0,0,0,0,       0,0,0,0

