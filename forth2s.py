#! /usr/bin/python
# program: forth2s.py
# Compile a .forth file to a .s file.

# License: GPL
# Jose Dinuncio <jdinunci@uc.edu.ve>, 12/2009
import re
import commands


# Option parser
from optparse import OptionParser
parser = OptionParser()
parser.add_option('-i', dest='finname', default='/dev/stdin',
                  help='Name of the input file')
parser.add_option('-o', dest='foutname', default='/dev/stdout',
                  help='Name of the output file')


# ============================================================================
#   States of the translator
# ============================================================================
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
            fout.write('        dd exit\n')
            return

        for assembly in translate(line):
            fout.write('        %s\n' % assembly)



# ============================================================================
#   Scanner for the translate_lines state
# ============================================================================
def forth_comment(scanner, token):
    '''
    function: forth_comment
       Translate a forth comment into an assembly comment.

       A forth comment starts with the '(' token  and end with the ')' token.
       It must end in the same line it started.
    '''
    return ['; %s' % token[1:-1]]

def line_comment(scanner, token): 
    '''
    function: line_comment
       Translate a forth line comment into an assembly comment.

       In this forth, a line comment starts with ';' and ends with the line.
    '''
    return ['; %s' % token[1:]]

def asm_literal(scanner, token):
    '''
    function: asm_literal
       Insert assembly code in a forth word.

       The assembly code is limited by '{' and '}'. Each line of nasm assembly
       is separated by ';'. The assembly literal must end in the same line.
    '''
    asm = token[1:-1].split(';')
    return asm

def literal(scanner, token):
    '''
    function: literal
       Translate a literal word to assembly.
    '''
    return ['litn %s' % token]

def word_literal(scanner, token):
    '''
    function: word_literal
       Translate a ['] forth expression to assembly.

       In this forth we use [`] instead, for the syntax highlighting.
    '''
    return ['litn %s' % token.split()[1]]

def word(scanner, token):
    '''
    function: word
       Translate a forth word.

       The forth word can be a translate to a literal, a macro or a forth word.
    '''
    if token in MACROS:
        return [token]
    elif token in LITERALS:
        return ['litn %s' % token]
    elif token in SYMBOLS:
        return ['dd %s' % SYMBOLS[token]]
    else:
        return ['dd %s' % token]

scanner = re.Scanner([
    (r'\(\s.*\s\)',             forth_comment),
    (r';.*',                    line_comment),
    (r'\{\s.*\}',               asm_literal),
    (r"'.'",                    literal),
    (r'0[xX][0-9A-Fa-f]+',      literal),
    (r'\d+\s',                  literal),
    (r"\[`\]\s+\S+",            word_literal),
    (r'\S+',                    word),
    (r'\s+',                    None),
])

def translate(line):
    trans, remainder = scanner.scan(line)
    return sum([ts for ts in trans], [])


# ============================================================================
#   Support functions
# ============================================================================
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


def get_symbols():
    '''
    function: get_symbols
      Returns a dict wich associate forth words with its assembly labels. It 
      is used to translate forth words with symbols in it.
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
      Return a list with the names of the %defines and labels found in assembly
      or forth files. It is used to translate literals words.
    '''
    # Get 'define' literals
    defs = commands.getoutput("grep '^%define ' *.s *.fth").splitlines()
    defs = [x.split()[1] for x in defs]
    # Get labels
    labels = commands.getoutput(
            "grep '^[:space:]*[A-Za-z0-9_]\+:' *.s *.fth").splitlines()
    labels = [x.split(':')[1] for x in labels]
    return defs + labels

def get_macros():
    '''
    function: get_macros
       Returns a list with the name of all the macros found in assembly or
       forth files. It is used to translate macro words.
    '''
    return commands.getoutput(
            "grep -r '%macro' *.s *.fth| awk '{print $2}'").split()

MACROS = get_macros()
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
