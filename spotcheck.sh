#!/bin/bash

# Just check to see if it matches
rm -f export.bin
z88dk-z80asm -b export.asm && md5sum export.bin VZ200.bin

