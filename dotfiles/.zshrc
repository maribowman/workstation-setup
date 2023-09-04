# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="robbyrussell"

zstyle 'omz:update' mode auto    # update automatically w/o asking
zstyle 'omz:update' frequency 3  # auto-update (in days)

ENABLE_CORRECTION="true"
COMPLETION_WAITING_DOTS="true"

plugins=(git docker docker-compose kubectl helm golang sudo)

# User configuration
# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.

# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

# Enable me
source $ZSH/oh-my-zsh.sh
source ~/.profile
