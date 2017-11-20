#!/bin/sh

for dotfile in $(find . -name ".[^.]*" -type f -maxdepth 1);
do
  echo "Processing $dotfile"
  ln -is $dotfile ~/
done;

