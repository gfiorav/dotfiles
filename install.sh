#!/bin/sh

for dotfile in src/*;
do
  echo "Processing $dotfile"
  ln -is $PWD/$dotfile $HOME/.$(basename $dotfile)
done;

