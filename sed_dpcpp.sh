#!/bin/bash
for file in $(ls *.txt); do  sed 's/llvm-2021-12\/build\/install/usr\/local/g' $file > tmp; mv tmp $file;     echo "$file"; done