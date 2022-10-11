## Themes

ZSH_THEME="ys"


## Plugins

plugins=(git)


## oh-my-zsh

### 关闭oh-my-zsh自动更新
export DISABLE_AUTO_UPDATE=true

export MY_ZSH=$BSTOOLS_ROOT/profiles/oh-my-zsh
source $MY_ZSH/oh-my-zsh.sh


## Source

[ -f ~/.bash_profile ] && source ~/.bash_profile


## Alias
alias vscode="/Applications/Visual\ Studio\ Code.app/Contents/Resources/app/bin/code"