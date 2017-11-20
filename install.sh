#!/bin/sh

for dotfile in $(find . -type f -maxdepth 1 | grep -e ".*");
do
  echo "Linking $dotfile.."
  ln -s $dotfile ~/
done

