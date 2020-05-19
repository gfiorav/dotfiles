#!/bin/bash

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
  sudo apt install git

  git config --global credential.helper store
  git config --global user.email "guido.fioravantti@gmail.com"
  git config --global user.name "Guido Fioravantti"
fi

if $(prompt "Install vim?");
then
  sudo apt install vim-gnome
fi

if $(prompt "Install the fish shell");
then
  sudo apt install fish
  sudo chsh -s /bin/zsh
fi

if $(prompt "Install libs to build vim from source?");
then
  sudo apt install libx11-dev libxtst-dev libxt-dev libsm-dev libxpm-dev libncurses5-dev build-essential
fi

if $(prompt "Install Google Chrome?");
then
  wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
  sudo sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list'
  sudo apt update
  sudo apt install google-chrome-stable
fi

if $(prompt "Install fonts?");
then
  curl -L https://github.com/hbin/top-programming-fonts/raw/master/install.sh | bash
  sudo apt install ttf-mscorefonts-installer
  sudo fc-cache -f -v
fi

if $(prompt "Install tmux?");
then
  sudo apt install tmux
fi

if $(prompt "Install Arc themes?");
then
  sudo apt install arch-theme
fi

if $(prompt "Install Gnome Tweak Tool?");
then
  sudo apt install gnome-tweak-tool
fi

if $(prompt "Add GTK-3 modifications?");
then
  ln -is $PWD/src/config/gtk-3.0/gtk.css $HOME/.config/gtk-3.0/gtk.css
fi

if $(prompt "Install Laptop management stuff?");
then
  sudo apt install preload tlp tlp-rdw lm-sensors acpi-call-dkms acpi-call-dkms
  sudo systemctl enable tlp
  sudo systemctl enable preload
fi

if $(prompt "Install Thinkpad stuff?");
then
  sudo apt install tp-smapi-dkms
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

