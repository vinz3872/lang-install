#!/bin/sh

sudo ln -sf $PWD/lang_install /usr/local/bin

echo "Add \". $PWD/config/load_env.sh\" at the end of your .zshrc / .bashrc file"