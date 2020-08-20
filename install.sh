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
  sudo dnf install git

  git config --global credential.helper store
  git config --global user.email "guido.fioravantti@gmail.com"
  git config --global user.name "Guido Fioravantti"
fi

if $(prompt "Install vim?");
then
  sudo dnf install vim
fi

if $(prompt "Install the fish shell?");
then
  ln -is $PWD/src/config/fish/* $HOME/.config/fish/
  sudo dnf install fish
  chsh -s /usr/bin/fish
fi

if $(prompt "Install fzf?");
then
  mkdir -p ~/Documents/workspace
  git clone https://github.com/junegunn/fzf.git $HOME/Documents/workspace/fzf
  cd $HOME/Documents/workspace/fzf
  ./install
  cd -
fi

if $(prompt "Install libs to build vim from source?");
then
  sudo dnf install libx11-dev libxtst-dev libxt-dev libsm-dev libxpm-dev libncurses5-dev build-essential
fi

if $(prompt "Install libs to compile python from source?");
then
    sudo dnf install libssl-dev libncurses5-dev libffi-dev libreadline-dev zlib1g-dev
fi

if $(prompt "Install Google Chrome?");
then
  wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo dnf-key add -
  sudo sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/dnf/sources.list.d/google.list'
  sudo dnf update
  sudo dnf install google-chrome-stable
fi

if $(prompt "Install fonts?");
then
  curl -L https://github.com/hbin/top-programming-fonts/raw/master/install.sh | bash
  sudo dnf install ttf-mscorefonts-installer
  sudo fc-cache -f -v
fi

if $(prompt "Install tmux?");
then
  sudo dnf install tmux
fi

if $(prompt "Install Arc themes?");
then
  sudo dnf install arch-theme
fi

if $(prompt "Install Gnome Tweak Tool?");
then
  sudo dnf install gnome-tweak-tool
fi

if $(prompt "Add GTK-3 modifications?");
then
  ln -is $PWD/src/config/gtk-3.0/gtk.css $HOME/.config/gtk-3.0/gtk.css
fi

if $(prompt "Install Laptop management stuff?");
then
  sudo dnf install preload tlp tlp-rdw lm-sensors acpi-call-dkms acpi-call-dkms
  sudo systemctl enable tlp
  sudo systemctl enable preload
fi

if $(prompt "Install Thinkpad stuff?");
then
  sudo dnf install tp-smapi-dkms
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

