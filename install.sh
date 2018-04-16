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
# Install ubuntu apps
#

if $(prompt "Install git?");
then
  sudo yum install git

  git config --global credential.helper store
  git config --global user.email "guido.fioravantti@gmail.com"
  git config --global user.name "Guido Fioravantti"
fi

if $(prompt "Install vim?");
then
  sudo yum install gvim
fi

if $(prompt "Install tmux?");
then
  sudo yum install tmux
  git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
fi

if $(prompt "Use prezto?");
then
  sudo yum install zsh
  zsh -c 'git clone --recursive https://github.com/sorin-ionescu/prezto.git "${ZDOTDIR:-$HOME}/.zprezto"'
  zsh -c 'setopt EXTENDED_GLOB;
          for rcfile in "${ZDOTDIR:-$HOME}"/.zprezto/runcoms/^README.md(.N); do
            ln -s "$rcfile" "${ZDOTDIR:-$HOME}/.${rcfile:t}"
          done'
  sudo su - -c 'chsh -s /bin/zsh'
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

