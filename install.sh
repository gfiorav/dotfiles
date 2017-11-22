#!/bin/sh

function install_brew_vim {
  read -p "Install and link brew's vim version? (allows for clipboard sharing) [y/N]" -n 1 -r
  echo
  if [[ $REPLY =~ ^[Yy]$ ]];
  then
    brew install vim
    echo "alias vim=/usr/local/Cellar/vim/*/bin/vim" >> $HOME/.bashrc
    echo "alias vim=/usr/local/Cellar/vim/*/bin/vim" >> $HOME/.zshrc
  fi
}

if [ ! $(command -v brew) ];
then
  read -p "brew is not installed, install it now? [y/N]" -n 1 -r
  echo
  if [[ $REPLY =~ ^[Yy]$ ]];
  then
    /usr/bin/ruby \
      -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

    install_brew_vim
  else
    return;
  fi
else
  install_brew_vim
fi

if [ ! -d $HOME/.vim/bundle/Vundle.vim ];
then
  read -p "Vundle is required for this vim setup, install it now? [y/N]" -n 1 -r
  echo
  if [[ $REPLY =~ ^[Yy]$ ]];
  then
    git clone https://github.com/VundleVim/Vundle.vim.git $HOME/.vim/bundle/Vundle.vim
  fi
fi

for dotfile in src/*;
do
  echo "Processing $dotfile"
  ln -is $PWD/$dotfile $HOME/.$(basename $dotfile)
done;

echo "Installing vim plugins..."
vim +PluginInstall +qall

echo "Installation complete!"

