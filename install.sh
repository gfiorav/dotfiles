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
  sudo apt install git libgnome-keyring-dev
  sudo make --directory=/usr/share/doc/git/contrib/credential/gnome-keyring

  git config --global credential.helper /usr/share/doc/git/contrib/credential/gnome-keyring/git-credential-gnome-keyring
  git config --global user.email "guido.fioravantti@gmail.com"
  git config --global user.name "Guido Fioravantti"
fi

if $(prompt "Install vim?");
then
  sudo apt install vim-gnome
fi

if $(prompt "Install Google Chrome?");
then
  wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
  sudo sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list'
  sudo apt update
  sudo apt install google-chrome-stable
fi

if $(prompt "Install Menlo Regular?");
then
  curl -L https://github.com/hbin/top-programming-fonts/raw/master/install.sh | bash
  sudo fc-cache -f -v
fi

if $(prompt "Install Terminator?");
then
  sudo apt install terminator
  mkdir -p $HOME/.config/terminator
  ln -is $PWD/src/config/terminator/config $HOME/.config/terminator/config
fi

if $(prompt "Install Terminator?");
then
  sudo apt install arch-theme
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

