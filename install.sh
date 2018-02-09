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
  sudo pacman -S git libgnome-keyring-dev
  sudo make --directory=/usr/share/doc/git/contrib/credential/gnome-keyring

  git config --global credential.helper /usr/share/doc/git/contrib/credential/gnome-keyring/git-credential-gnome-keyring
  git config --global user.email "guido.fioravantti@gmail.com"
  git config --global user.name "Guido Fioravantti"
fi

if $(prompt "Install vim?");
then
  sudo pacman -S gvim
fi

if $(prompt "Install Google Chrome?");
then
  sudo pacman -S google-chrome
fi

if $(prompt "Install fonts?");
then
  curl -L https://github.com/hbin/top-programming-fonts/raw/master/install.sh | bash
  sudo pacman -S ttf-mscorefonts-installer
  sudo fc-cache -f -v
fi

if $(prompt "Install tmux?");
then
  sudo pacman -S tmux 
fi

if $(prompt "Install Arc themes?");
then
  sudo pacman -S arc-gtk-theme 
fi

if $(prompt "Install Gnome Tweak Tool?");
then
  sudo pacman -S gnome-tweak-tool
fi

if $(prompt "Add GTK-3 modifications?");
then
  ln -is $PWD/src/config/gtk-3.0/gtk.css $HOME/.config/gtk-3.0/gtk.css
fi

if $(prompt "Install Laptop management stuff?");
then
  sudo pacman -S preload tlp thinkfan lm-sensors
  sudo systemctl enable tlp
  sudo systemctl enable preload
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

