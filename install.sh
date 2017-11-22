#!/bin/sh

#
# Helper functions
#

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

#
# Install brew and mac apps if mac
#

if [ "$(uname)" == "Darwin" ];
then
  if $(prompt "Install mac apps? (brew is required)");
  then
    if [ ! $(command -v brew) ];
    then
      echo "Installing brew..."
      /usr/bin/ruby \
        -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    fi

    if $(prompt "Install and link brew's vim version (enables shared clipboard)?");
    then
      brew install vim
      echo "alias vim=/usr/local/Cellar/vim/*/bin/vim" >> $HOME/.bashrc
      echo "alias vim=/usr/local/Cellar/vim/*/bin/vim" >> $HOME/.zshrc
    fi

    if $(prompt "Install iTerm2?");
    then
      brew cask install iterm2
    fi
  fi
else
  echo "Platform $(uname) not expected, skipping app installation..."
fi

#
# Install Vundle if not installed
#

if [ ! -d $HOME/.vim/bundle/Vundle.vim ];
then
  if $(prompt "Vundle is required for this vim setup, install it now?");
  then
    git clone https://github.com/VundleVim/Vundle.vim.git $HOME/.vim/bundle/Vundle.vim
  fi
fi

#
# Install dotfiles
#

for dotfile in src/*;
do
  echo "Processing $dotfile..."
  ln -is $PWD/$dotfile $HOME/.$(basename $dotfile)
done;

#
# Install vim plugins
#

echo "Installing vim plugins..."
vim +PluginInstall +qall

echo "Installation complete!"

