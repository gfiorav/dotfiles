#!/bin/sh

for dotfile in $(find . -name ".[^.]*" -type f -maxdepth 1);
do
  echo "Linking $dotfile.."  
  ln -s $dotfile ~/
done;

