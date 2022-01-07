## Themes

ZSH_THEME="ys"

## Plugins

plugins=(git)

## oh-my-zsh

export ZSH=~/.oh-my-zsh
source $ZSH/oh-my-zsh.sh

## Source

[ -f ~/.bash_profile ] && source ~/.bash_profile
[ -f ~/.zsh_profile ] && source ~/.zsh_profile

## Alias

alias vscode="/Applications/Visual\ Studio\ Code.app/Contents/Resources/app/bin/code"
