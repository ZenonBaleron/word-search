#!/usr/bin/env bash

# count occurences of each letter in a file

awk -vFS="" '{for(i=1;i<=NF;i++)w[tolower($i)]++}END{for(i in w) print i,w[i]}' $1
