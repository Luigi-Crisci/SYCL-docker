#!/bin/bash
for file in $(ls *.txt); do  sed 's/llvm-2022-09\/build\/install/usr\/local/g' $file > tmp; mv tmp $file;     echo "$file"; done