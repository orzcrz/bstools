## bstools
export BSTOOLS_ROOT=$HOME/.bstools
export PATH=$BSTOOLS_ROOT/bin:$PATH

## homebrew
export PATH=/opt/homebrew/bin:$PATH
export PATH=/opt/homebrew/sbin:$PATH
export HOMEBREW_BOTTLE_DOMAIN=https://mirrors.ustc.edu.cn/homebrew-bottles/bottles/
export HOMEBREW_BREW_GIT_REMOTE=https://mirrors.ustc.edu.cn/brew.git
export HOMEBREW_CORE_GIT_REMOTE=https://mirrors.ustc.edu.cn/homebrew-core.git
export HOMEBREW_NO_INSTALL_FROM_API=1

## pyenv
export PYENV_ROOT=$HOME/.pyenv
export PATH=$PYENV_ROOT/shims:$PATH
if command -v pyenv 1>/dev/null 2>&1; then
  eval "$(pyenv init -)"
  eval "$(pyenv virtualenv-init -)"
fi

## rbenv
export PATH=$HOME/.rbenv/bin:$PATH
export RUBY_BUILD_MIRROR_URL=https://cache.ruby-china.com
if command -v rbenv 1>/dev/null 2>&1; then
  eval "$(rbenv init -)"
fi

## gem
export GEM_HOME="$(ruby -e 'puts Gem.user_dir')"
export PATH="$PATH:$GEM_HOME/bin"

## Java
export JAVA_HOME="$(/usr/libexec/java_home)"