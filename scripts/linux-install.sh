#!/bin/zsh

for folder in ~/.dotfiles/*/; do
  if [ -d "$folder" ]; then
    folder_name=$(basename "$folder")
    echo "Running stow for $folder_name"
    stow "$folder_name"
  fi
done
