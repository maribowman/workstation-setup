export ZSH="$HOME/.oh-my-zsh"

# export go system settings
export GOROOT=/usr/local/go
export GOPATH=$HOME/go/bin
export PATH=$PATH:$GOPATH/bin
export GOPRIVATE=github.com/fomo-labs

ZSH_THEME="robbyrussell"

zstyle 'omz:update' mode auto    # update automatically w/o asking
zstyle 'omz:update' frequency 3  # auto-update (in days)

ENABLE_CORRECTION="true"
COMPLETION_WAITING_DOTS="true"

plugins=(git docker docker-compose kubectl helm golang sudo)

# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.

# Enable me
source $ZSH/oh-my-zsh.sh
source ~/.profile
