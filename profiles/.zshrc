## Themes

ZSH_THEME="ys"


## Plugins

plugins=(git)


## oh-my-zsh

export MY_ZSH=./oh-my-zsh
source $MY_ZSH/oh-my-zsh.sh


## Source

[ -f ~/.bash_profile ] && source ~/.bash_profile
[ -f ~/.zsh_profile ] && source ~/.zsh_profile
[ -f ~/.zsh_alias ] && source ~/.zsh_alias


