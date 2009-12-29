#! /usr/bin/python
# program: forth2s.py
# Compile a .forth file to a .s file.

# License: GPL
# Jose Dinuncio <jdinunci@uc.edu.ve>, 12/2009
import commands


# Option parser
from optparse import OptionParser
parser = OptionParser()
parser.add_option('-i', dest='finname', default='/dev/stdin',
                  help='Name of the input file')
parser.add_option('-o', dest='foutname', default='/dev/stdout',
                  help='Name of the output file')

def copy_lines(fin, fout):
    '''
    function: copy_lines
    Copy lines from fin to fout.

    If the line starts with ':' then start to translate the lines from forth 
    to nasm.

    Params:
        fin - file to read.
        fout - file to write.
    '''
    for line in fin:
        if line.startswith(':'):
            defword = translate_forth_def(line)
            fout.write(defword)
            fout.write('\n')
            translate_lines(fin, fout)
        else:
            fout.write(line)

def translate_forth_def(line):
    '''
    function: translate_forth_def
    Translate the definition of a forth word to nasm assembly.

    The forth definition must start at the begining of line, and must have the
    following structure:

        : name, label, flags

    Where:
        name - The name of the forth word, as seen for other forth words.
        label - The name of the forth word, as seen by assembly code.
        flags - Flags of this forth word. See forth_core.s and forth_macros.s
                for more details.

    Params:
        line - The first line of a forth word definition

    Returns:
        string - A line of text with the defword of the forth word being defined.
    '''
    defword = 'defword ' + line[1:-1]
    return defword

def translate_lines(fin, fout):
    '''
    function: translate_lines
    Translate lines of forth code to nasm assembler.

    The forth code must end in a line beginning with a semicolon. 
    
    The only comments accepted are line comments. They start with a '#'.
    
    Params:
        fin - file to read.
        fout - file to write.
    '''
    for line in fin:
        if line.startswith(';'):
            fout.write('        dd EXIT\n')
            return

        code, comment = (line.split('#') + [None])[:2]

        parts = code.split()
        if not parts and not comment:
            fout.write('\n')
            continue
            
        words = [translate_word(word) for word in parts]
        for word in words:
            fout.write('        %s\n' % word)

        if comment:
            fout.write('        ; %s' % comment)
            continue



def translate_word(word):
    '''
    function: translate_word
    Translate a forth word to an nasm assembly line.

    Parameters:
        word - Forth forth to translate.

    Return:
        string - Assembly
    '''
    for fn in TRANSLATIONS:
        translation = fn(word)
        if translation:
            return translation
    raise RuntimeError, "Word '%s' couldn't be translated" % word

def tr_lit_n(word):
    '''
    function: tr_lit_n
    Translate a literal integer.
    '''
    if word.startswith('0x') or word.startswith('0X'):
        return 'LITN %s' % word
    try:
        int(word)
        return 'LITN %s' % word
    except:
        return ''

def tr_lit_s(word):
    '''
    function: tr_lit_s
    Translate a literal character.
    '''
    if word.startswith("'"):
        return 'LITN %s' % word
    else:
        return ''

def tr_lit_lit(word):
    '''
    function: tr_lit_lit
    Translate a literal defined by a %define macro.
    '''
    if word in LITERALS:
        return 'LITN %s' % word
    else:
        return ''

def tr_macro(word):
    '''
    function: tr_macro
    Translate a macro.
    '''
    if word in MACROS:
        return word
    else: 
        return ''

def tr_symbol(word):
    '''
    function: tr_symbol
    Translate the forth word to its assembly name
    '''
    if word in SYMBOLS:
        return 'dd %s' % SYMBOLS[word]
    else:
        return ''

def tr_id(word):
    '''
    function: tr_id
    Default translator.
    '''
    return 'dd %s' % word

def get_symbols():
    '''
    function: get_symbols
      Returns a dict wich associate forth words with its assembly labels.

    It is used to translate forth words with symbols in it.
    '''
    dct = {}
    lines = commands.getoutput("grep '^def[vcw]' *.s *.fth").splitlines()
    lines.extend(commands.getoutput("grep '^: ' *.fth").splitlines())
    for line in lines:
        parts = line.split()
        parts = ''.join(parts[1:]).split(',')
        key = parts[0]
        val = parts[1]
        dct[key] = val
    return dct

def get_literals():
    '''
    function: get_literals
    Return a list with the names of the %defines found in assembly labels.
    
    It is used to translate literals.
    '''
    defs = commands.getoutput("grep '^%define ' *.s *.fth").splitlines()
    lits = [x.split()[1] for x in defs]
    return lits

# Use this version for compile recursive definitions
TRANSLATIONS = [tr_lit_n, tr_lit_s, tr_lit_lit, tr_macro, tr_symbol, tr_id]
# Use this version to detect bogus words
# TRANSLATIONS = [tr_lit_n, tr_lit_s, tr_lit_lit, tr_macro, tr_symbol]
MACROS = commands.getoutput("grep -r '%macro' *s | awk '{print $2}'").split()
SYMBOLS = get_symbols()
LITERALS = get_literals()

def main():
    '''
    function: main
    Translate forth code in a file to nasm assembler and stores in other
    file.
    '''
    opts, args = parser.parse_args()
    fin = open(opts.finname)
    fout = open(opts.foutname, 'w')
    copy_lines(fin, fout)


if __name__ == '__main__' :
    main()
