#!/bin/sh

. /etc/os-release

if [ "$ID" = "arch" ]; then
	pkgm="pacman"
elif [ "$ID" = "debian" ] || [ "$ID" = "ubuntu" ]; then
	pkgm="apt"
fi

if [ "$pkgm" = "pacman" ]; then
	# check if git is installed
	if [ "$(pacman -Q | grep 'git')" = "" ]; then
		echo "Looks like you haven't installed git yet. Install it and come back."
		exit
	else
		# if git IS installed
		if [ "$1" = "install" ]; then
			if [ "$2" = "starter" ]; then
				read -p "Select terminal: (1) foot [wayland only] (2) alacritty (3) kitty (4) xfce4-terminal (5) gnome-terminal: " term
				if [ "$term" = "1" ]; then
					term="foot"
				elif [ "$term" = "2" ]; then
					term="alacritty"
				elif [ "$term" = "3" ]; then
					term="kitty"
				elif [ "$term" = "4" ]; then
					term="xfce4-terminal"
				elif [ "$term" = "5" ]; then
					term="gnome-terminal"
				else
					echo "Not valid input."
					exit
				fi

				read -p "Select shell: (1) bash (2) fish (3) zsh (4) ksh: " shell

				if [ "$shell" = "1" ]; then
					shell="bash"
				elif [ "$shell" = "2" ]; then
					shell="fish"
				elif [ "$shell" = "3" ]; then
					shell="zsh"
				elif [ "$shell" = "4" ]; then
					shell="ksh"
				else
					echo "Not valid input."
					exit
				fi

				read -p "Select editor: (1) neovim (2) nano (3) VSCodium (4) Sublime Text (5) Don't change: " editor

				if [ "$editor" = "1" ]; then
					editor="neovim"
				elif [ "$editor" = "2" ]; then
					editor="nano"
				elif [ "$editor" = "3" ]; then
					editor="vscodium-bin"
				elif [ "$editor" = "4" ]; then
					editor="sublime-text"
				elif [ "$editor" = "5" ]; then
					editor=""
				else
					echo "Not valid input."
					exit
				fi

				echo "Now installing yay, a AUR helper"

				sleep 0.5

				git clone https://aur.archlinux.org/yay.git

				cd yay

				makepkg -si

				echo "Done installing yay. Version: $(yay --version)"

				cd

				rm -r ./yay/

				sudo pacman -S --needed $term $shell polkit polkit-gnome firefox python python-distro neofetch python-requests gcc g++ tee base-devel

				echo "Checking if any AUR packages need to be installed..."

				if [ "$editor" = "vscodium-bin" ]; then
					echo "VSCodium needs to be installed using yay.."
					sleep 0.4
					yay -S $editor
				elif [ "$editor" = "sublime-text" ]; then
					echo "Sublime Text does not use yay, but needs to be installed seperately"
					sleep 0.6
					curl -O https://download.sublimetext.com/sublimehq-pub.gpg && sudo pacman-key --add sublimehq-pub.gpg && sudo pacman-key --lsign-key 8A8F901A && rm sublimehq-pub.gpg
					echo -e "\n[sublime-text]\nServer = https://download.sublimetext.com/arch/stable/x86_64" | sudo tee -a /etc/pacman.conf
					sudo pacman -Syu sublime-text
				fi
			fi
			if [ "$2" = "polybar" ]; then
				echo "Installing needed fonts.."
				sudo pacman -S --needed ttf-roboto-mono ttf-firacode-nerd
				echo "Now installing polybar (comes with a config file)"
				sudo pacman -S --needed polybar
				mkdir -p ~/.config/polybar
				cp ./config.ini ~/.config/polybar/
				echo "Run polybar with polybar top!"
				exit 
			fi
			if [ "$2" = "waybar" ]; then
				echo "Installing needed fonts.."
				sudo pacman -S --needed cantarell-fonts
				echo "Now installing waybar (comes with a config file)"
				sudo pacman -S --needed waybar
				mkdir -p ~/.config/waybar
				cp ./config ./style-waybar.css ~/.config/waybar/
				cd ~/.config/waybar/
				mv style-waybar.css style.css
				echo "Run waybar with waybar!"
				exit 
			fi
			if [ "$2" = "picom" ]; then
				echo "Now installing picom's dependencies if needed"
				sudo pacman -S --needed libx11 libx11-xcb libXext xproto xcb xcb-damage xcb-xfixes xcb-shape xcb-renderutil xcb-render xcb-randr xcb-composite xcb-image xcb-present xcb-xinerama xcb-glx pixman libGL libpcre libev uthash meson ninja gcc
				git clone https://github.com/pijulius/picom
				cd picom
				git submodule update --init --recursive
                meson --buildtype=release . build
                ninja -C build
				mkdir -p ~/.config/picom
				mv ./picom.sample.conf picom.conf
				cp ./picom.conf ~/.config/picom/
				cd
				echo "Run picom with picom -b!"
				sleep 0.45
				exit 
			fi
			if [ "$2" = "wlogout" ]; then
				echo "Now installing wlogout (comes with a config file)"
				sleep 0.34
				yay -S wlogout
				mkdir -p ~/.config/wlogout
				cp ./style.css ./layout ~/.config/wlogout/
				echo "Finished installing! Run with wlogout"
				sleep 0.2
			fi
		fi
	fi
else
	if [ "$(apt list --installed | grep "git")" != "" ]; then
		echo ""
	else
		echo "Looks like you haven't installed git yet. Install it and come back. apt"
		exit
	fi
fi
