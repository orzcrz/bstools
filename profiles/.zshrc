## Themes

ZSH_THEME="ys"


## Plugins

plugins=(
  git, 
  zsh-syntax-highlighting
)


## oh-my-zsh

### 关闭oh-my-zsh自动更新
export DISABLE_AUTO_UPDATE=true

export MY_ZSH=$BSTOOLS_ROOT/profiles/oh-my-zsh
source $MY_ZSH/oh-my-zsh.sh


## Source

[ -f ~/.bash_profile ] && source ~/.bash_profile


## Alias
alias vscode="/Applications/Visual\ Studio\ Code.app/Contents/Resources/app/bin/code"


## zsh语法高亮
[ -f $BSTOOLS_ROOT/profiles/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ] && source $BSTOOLS_ROOT/profiles/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh