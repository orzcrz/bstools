## Themes

ZSH_THEME="ys"


## Plugins

plugins=(git)


## oh-my-zsh

export MY_ZSH=./oh-my-zsh
source $MY_ZSH/oh-my-zsh.sh


## Source

[ -f ~/.bash_profile ] && source ~/.bash_profile
[ -f ~/.zprofile ] && source ~/.zprofile


## Alias
alias vscode="/Applications/Visual\ Studio\ Code.app/Contents/Resources/app/bin/code"