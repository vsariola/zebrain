#!/usr/bin/env python
# -*- coding: utf-8 -*-
'''
matmini.py
Minify Matlab code
'''

import re, sys, os.path, os
from itertools import permutations
alphabet = 'abcdefghijklmnopqrstuvwxyz'
alphabet = alphabet + alphabet.upper()
symbols = {"'",'~','.','=','<','>',',','/','+','*','^','(',')',';','[',']','-',':','@','\\','{','}'}
keywords = {'break','case','catch','classdef','continue','else','elseif',
        'end','for','function','global','if','otherwise','parfor',
        'persistent','return','spmd','switch','try','while'}

def extract_strings(code_lines):
    '''
    Replace strings in code_lines with 'i' where i is the string's index.
    Return list of strings found in code_lines.
    '''
    # TODO: be more clever about determining if it's string or transpose
    strings = []
    for i, line in enumerate(code_lines):
        # non-greedily match everything between single quotes
        matches = re.findall(r"'(.*?)'", line)
        for match in matches:
            # try determine if each match really is a string
            if all((m in symbols) for m in match) or match[0] in {' ',','}:
                # either just a bunch of symbols or probably is transpose
                continue
            strings.append(match)
            code_lines[i] = code_lines[i].replace(match,"'{}'".format(len(strings)-1))
    print("Found strings: ", strings)
    return strings

def inject_strings(code_lines, strings):
    '''
    Replace 'i' markers in code_lines with the appropriate string from strings.
    '''
    n = 0
    for i, s in enumerate(strings):
        while "'%d'" % i not in code_lines[n]:
            if n == len(code_lines) - 1: break
            n += 1
        code_lines[n] = code_lines[n].replace("'%d'" % i, strings[i])

def decomment(code_lines):
    '''
    Remove all comments from code_lines, returning (uncommented_lines, comments)
    where uncommented_lines and comments can be zipped together to recover the comments.
    '''
    # split comments (everything after % unless % is in format string)
    split_comments = [l.split(r'%') if 'printf' not in l else [l] for l in code_lines]
    return ([l[0] for l in split_comments],
            ['%'.join(l[1:]) for l in split_comments])

def cleanup(code_lines, comments):
    '''
    Return a cleaned up version of code_lines,
    where each element in the returned list is a statement.
    Each element in comments is inserted before what it corresponds to in code_lines
    as its own line.
    '''
    parsed_lines = []
    for l, c in zip(code_lines, comments):
        # insert the comment first if one exists
        c = c.strip()
        if c:
            parsed_lines.append('% ' + c)
        in_parens = 0
        prev = 0
        for i, s in enumerate(l):
            if s in {'[','('}:
                in_parens += 1
            elif s in {')',']'}:
                in_parens -= 1
            elif (s == ',' and in_parens == 0) or s == ';':
                # split line here
                parsed_lines.append(l[prev:i+1])
                prev = i+1
        parsed_lines.append(l[prev:])
    # strip whitespace and trailing commas
    return [l.strip().rstrip(',') for l in parsed_lines if l.strip()]

def symbols_to_spaces(code):
    '''
    Replace all the symbols in code with spaces.
    '''
    return ''.join([c if c not in symbols else ' ' for c in code])

def find_names(code_lines):
    '''
    Return set of all variable names used in the file.
    '''
    names = set([])
    for line in code_lines:
        if line.startswith('function'):
            # add function name and arguments to names
            line = line.lstrip('function').lstrip()
            if len(line.split('=')) == 2:
                left, right = line.split('=')
                names.update(set(symbols_to_spaces(left).split()))
                names.update(set(symbols_to_spaces(right).split()))
            else:
                names.update(set(symbols_to_spaces(line).split()))
        elif line.startswith('for'):
            line = line.lstrip('for').lstrip()
            if len(line.split('=')) == 2:
                left = line.split('=')[0]
                names.update(set(symbols_to_spaces(left).split()))
        else:
            if len(line.split('=')) == 2:
                left = line.split('=')[0]
                if '(' in left and ')' in left:
                    # take out everything between parens
                    left = ' '.join([left[:left.find('(')],
                        left[left.rfind(')')+1:]])
                names.update(set(symbols_to_spaces(left).split()))
    names = {n for n in names if not (n.isdigit() or n == '%')}.difference(keywords)
    return names

def map_names(names, valid_chars, length = 1):
    '''
    Return a mapping of names -> permutation of valid_chars, where each
    permutation has at least given length.
    '''
    p = length
    m = None
    mapping = {}
    perms = permutations(valid_chars, p)
    for n in names:
        tries = 0
        while (not m) or (m in names) or (m in mapping.values()) or (
                not m[0] in alphabet) or (m in keywords):
            if tries >= 2:
                perms = permutations(alphabet, 1)
                print("Not enough valid characters, continuing with default.")
            try:
                m = ''.join(next(perms))
            except StopIteration:
                tries += 1
                p += 1
                perms = permutations(valid_chars, p)
        mapping[n] = m
        m = not m
    print("Variable mapping:", mapping)
    return mapping

def find_name(name, line):
    '''
    Return the index of the name in line if it's used there, else -1
    '''
    if name not in line:
        return -1
    if name == line:
        return 0
    ind = line.find(name)
    if ind == 0:
        # at the start of the line
        if line[ind+len(name)] in symbols or line[ind+len(name)] == ' ':
            return ind
        return len(name)+find_name(name, line[ind+len(name):])
    elif ind+len(name) == len(line):
        # at the end of the line
        if line[ind-1] in symbols or line[ind-1] == ' ':
            return ind
    else:
        if ((line[ind+len(name)] in symbols or line[ind+len(name)] == ' ') and
                (line[ind-1] in symbols or line[ind-1] == ' ')):
            return ind
        return ind+len(name)+find_name(name, line[ind+len(name):])

def minify_join(lines):
    '''
    Join the list of lines as a single string with no newlines.
    If we still have comments then they will be on their own lines.
    '''
    # separate statements with commas if they aren't already split by semicolons
    m = [l + ',' if l[-1] != ';' and l[0] != '%' else l for l in lines]
    for i in range(1, len(m)):
        if m[i].startswith('function'):
            # remove the newline from the previous line unless it was a comment
            if not m[i-1].strip().startswith('%'):
                m[i-1] = m[i-1][:-1]
        elif i == len(m)-1:
            m[i] = m[i][:-1]
        elif m[i].startswith('%'):
            # surround a comment line with newlines so it has its own line.
            m[i] = '\n' + m[i] + '\n'
    return ' '.join(m)

def not_minify_join(lines):
    '''
    Join the list of lines with a newline after each semicolon
    '''
    lines = minify_join(lines).replace(';', ';\n').split('\n')
    # strip trailing whitespace and remove empty lines
    return '\n'.join([l.rstrip() for l in lines if l.strip()])

def minify(lines, valid_chars, stages, length = 1):
    '''
    Minify the lines of code using valid_chars for renaming variables.
    '''
    lines, comments = decomment(lines)
    strings = extract_strings(lines)
    # re-insert comments during cleanup on their own lines
    lines = cleanup(lines, comments if 'decomment' not in stages else ['']*len(lines))
    if 'rename_vars' in stages:
        mapping = map_names(find_names(lines), valid_chars, length)
        minified = []
        for line in lines:
            stripped = symbols_to_spaces(line)
            for name in stripped.split():
                if name in mapping:
                    line = ''.join([line[:find_name(name, line)],
                        mapping[name], line[find_name(name, line)+len(name):]])
            minified.append(line)
    else:
        minified = lines[:]
    inject_strings(minified, strings)
    if 'oneline' in stages:
        return minify_join(minified)
    return not_minify_join(minified)

def minify_file(filename, valid_chars, stages, length):
    '''
    Minify the Matlab code in a file and write it to a file in `minified` folder.
    '''
    with open(filename) as f:
        m = minify(f.readlines(), valid_chars, stages, length)
        # name of the file is its first function
        funcname = m[m.find('function')+9:m.find(',')].strip()
        if not funcname:
            # couldn't figure out the name for the file
            funcname = filename.rstrip('.m') + '.min'
        out = os.path.join('minified', funcname+'.m')
        if not os.path.exists('minified'):
            os.makedirs('minified')
        with open(out, 'w') as o:
            o.write(m)
            print("Written to",out)

def main(argv):
    valid_chars = alphabet
    stages = {'decomment', 'rename_vars', 'oneline'}
    # show help
    if len(argv[1:]) == 0 or '-h' in argv[1:]:
        print("matmini.py [files] -l [min. var length] --alpha [valid chars] --skip [stages,to,skip]")
        print("Stages: decomment, rename_vars, oneline")
        return
    # set the length
    length = 1
    if '-l' in argv[1:]:
        length = argv[argv.index('-l')+1]
    length = int(length) if length.isdigit() else 1
    print("Using target variable length:", length)
    # set valid_chars
    if '--alpha' in argv[1:]:
        valid_chars = argv[argv.index('--alpha')+1]*4
    if '--skip' in argv[1:]:
        skipped_stages = set(argv[argv.index('--skip')+1].split(','))
        stages = stages.difference(skipped_stages)
    print("Stages to process:", stages)
    for arg in argv[1:]:
        if os.path.isfile(arg):
            minify_file(arg, valid_chars, stages, length)

if __name__ == '__main__':
    main(sys.argv)
