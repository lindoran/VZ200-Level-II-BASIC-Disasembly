#!/usr/bin/env python3
import sys
import re

def load_symbols(symbol_file):
    """Load symbols from symbol table file into a dictionary."""
    symbols = {}
    with open(symbol_file, 'r') as f:
        for line in f:
            line = line.strip()
            if not line or line.startswith('#'):
                continue

            # Remove inline comments
            if '#' in line:
                line = line.split('#')[0].strip()

            # Parse "NAME : ADDR" format
            if ':' in line:
                parts = line.split(':')
                if len(parts) == 2:
                    name = parts[0].strip()
                    addr = parts[1].strip().upper()
                    if len(addr) == 4:
                        symbols[addr] = name

    return symbols

def replace_subs(input_file, symbols):
    """Replace sub_XXXXh patterns with their symbol names."""
    # Pattern matches sub_XXXXh where XXXX is 4 hex digits
    pattern = re.compile(r'\bsub_([0-9a-fA-F]{4})h\b')

    with open(input_file, 'r') as f:
        for line in f:
            def replacer(match):
                addr = match.group(1).upper()
                if addr in symbols:
                    return symbols[addr]
                return match.group(0)  # Keep original if no symbol found

            modified_line = pattern.sub(replacer, line)
            print(modified_line, end='')

if __name__ == '__main__':
    if len(sys.argv) != 3:
        print("Usage: replace_subs.py <symbols.txt> <input.asm>")
        print("Output goes to stdout, redirect with > output.asm")
        sys.exit(1)

    symbol_file = sys.argv[1]
    input_file = sys.argv[2]

    symbols = load_symbols(symbol_file)
    replace_subs(input_file, symbols)
