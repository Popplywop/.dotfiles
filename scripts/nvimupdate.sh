#!/bin/bash

cd ~/neovim
git pull --rebase
make CMAKE_BUILD_TYPE=RelWithDebInfo
sudo make install
