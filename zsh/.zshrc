# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000
unsetopt beep notify
bindkey -v
# End of lines configured by zsh-newuser-install
# The following lines were added by compinstall
zstyle :compinstall filename '/home/jpopple/.zshrc'

autoload -Uz compinit
compinit
# End of lines added by compinstall

# ALIASES
alias ls="ls -la"
alias src="exec zsh"
alias srvunlock="ssh -i ~/.ssh/dropbear -p 4748 -o 'HostKeyAlgorithms ssh-rsa' root@192.168.51.65"

# DOTNET ROOT
DOTNET_ROOT="/usr/share/dotnet"

# PATH ASSIGNMENT
PATH="$PATH:/home/jpopple/.local/bin:$DOTNET_ROOT:$DOTNET_ROOT/tools"

# START SSH-AGENT
eval $(keychain --agents ssh --eval ~/.ssh/id_ed25519 --noask)

# OHMYPOSH INIT
eval "$(oh-my-posh init zsh --config "~/.dotfiles/ohmyposh/catppuccin-latte-custom.omp.json")"
