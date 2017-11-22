#!/bin/sh

function prompt() {
  read -p "$1 [y/N]" -r
  echo
  if [[ $REPLY =~ ^[Yy]$ ]];
  then
    return 0;
  else
    return 1;
  fi
}

if $(prompt "Install and link brew's vim version for shared clipboard? (requires brew)");
then
  if [ ! $(command -v brew) ];
  then
    if $(prompt "brew is not installed, install it now?");
    then
      echo "Installing brew..."
      /usr/bin/ruby \
        -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    fi
  fi

  echo "Installing brew's vim..."
  brew install vim
  echo "alias vim=/usr/local/Cellar/vim/*/bin/vim" >> $HOME/.bashrc
  echo "alias vim=/usr/local/Cellar/vim/*/bin/vim" >> $HOME/.zshrc
fi

if [ ! -d $HOME/.vim/bundle/Vundle.vim ];
then
  if $(prompt "Vundle is required for this vim setup, install it now?");
  then
    git clone https://github.com/VundleVim/Vundle.vim.git $HOME/.vim/bundle/Vundle.vim
  fi
fi

for dotfile in src/*;
do
  echo "Processing $dotfile..."
  ln -is $PWD/$dotfile $HOME/.$(basename $dotfile)
done;

echo "Installing vim plugins..."
vim +PluginInstall +qall

echo "Installation complete!"

