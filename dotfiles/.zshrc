export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="robbyrussell"

zstyle 'omz:update' mode auto    # Update automatically w/o asking
zstyle 'omz:update' frequency 3  # Auto-update (in days)

COMPLETION_WAITING_DOTS="true"

plugins=(git docker docker-compose kubectl helm golang sudo)

# Enable it
source $ZSH/oh-my-zsh.sh
source ~/.profile

# Export go system settings
export GOROOT=/usr/local/go
export GOPATH=$HOME/go
export PATH=$PATH:$GOROOT/bin:$GOPATH/bin
export GOPRIVATE=github.com/fomo-labs
# Add pulumi to path
export PATH="$PATH:/home/mari/.pulumi/bin"

autoload -U +X bashcompinit && bashcompinit
complete -o nospace -C /usr/bin/terraform terraform
