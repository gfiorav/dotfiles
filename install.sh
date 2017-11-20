#!/bin/sh

for dotfile in $(find . -name ".[^.]*" -type f -maxdepth 1);
do
  echo "Processing $dotfile\c"

  if [ -e $HOME/$dotfile ];
  then
    read -p " overwrite? (y/N) " -n 1 -r

    if [[ ! $REPLY =~ ^[Yy]$ ]];
    then
      echo " ..skip"
      continue
    else
      rm $HOME/$dotfile
    fi;
  fi;

  echo " ..ok"
  #ln -s $dotfile ~/
done;

