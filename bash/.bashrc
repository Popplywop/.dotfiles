#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'
PS1='[\u@\h \W]\$ '

export DOTNET_ROOT=$HOME/.dotnet
export PATH=$PATH:$DOTNET_ROOT:$DOTNET_ROOT/tools:/home/jpopple/.local/bin:$HOME/bin

eval "$(oh-my-posh init bash --config ~/popply.omp.yml)"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion


if [ -z "$TMUX" ] && [[ ! "$TERM" =~ ^(tmux|screen) ]] && command -v tmux &>/dev/null; then
  tmux attach -t main || tmux new -s main
fi

if command -v wt >/dev/null 2>&1; then eval "$(command wt config shell init bash)"; fi

# yazi — shell wrapper: cd to last dir on quit
function yy() {
    local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
    yazi "$@" --cwd-file="$tmp"
    if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
        builtin cd -- "$cwd"
    fi
    rm -f -- "$tmp"
}

eval "$(zoxide init bash --cmd cd)"
