#!/usr/bin/env bash

. scripts/logger.sh
. scripts/utils.sh

set -e
set -u
# set -x

echo "$(tput setaf 2)"
echo "################################"
echo "  准备配置环境"
echo "################################"
echo "$(tput sgr0)"

cd ~

root_path=~/.mac-config
config_path=${root_path}/configs
rm -rf "${root_path}"
git clone git@github.com:orzcrz/mac-config.git ${root_path}

log_info "已拉取远程配置"

profile=${config_path}/.zshrc

## 感知CPU类型，针对 Apple Silicon 做特殊处理
cpu=`sysctl -n machdep.cpu.brand_string`
cpu_arch=`uname -m`
log_info "处理器信息： ${cpu}，${cpu_arch}"

if [[ ${cpu} =~ "Apple" ]] && [[ ${cpu_arch} =~ "arm" ]]
then
  log_info "安装homebrew"
  local brew_path=/opt/homebrew
  sudo mkdir -p ${brew_path}
  sudo chown -R $(whoami) ${brew_path}
  curl -L https://github.com/Homebrew/brew/tarball/master | tar xz --strip 1 -C ${brew_path}

  log_info "导入 homebrew 环境变量"
  echo "" >> ${profile}
  echo "## homebrew" >> ${profile}
  echo 'export PATH=/opt/homebrew/bin:$PATH' >> ${profile}

  log_info "替换 homebrew 源地址"
  
  local brew_repo="$(brew --repo)"

  cd ${brew_repo}
  git remote set-url origin https://mirrors.ustc.edu.cn/brew.git

  cd "${brew_repo}/Library/Taps/homebrew/homebrew-core"
  git remote set-url origin https://mirrors.ustc.edu.cn/homebrew-core.git

  cd "${brew_repo}/Library/Taps/homebrew/homebrew-cask"
  git remote set-url origin https://mirrors.ustc.edu.cn/homebrew-cask.git

  cd ~
fi

cmd_exists brew
if [ $? -ne 0 ]; then
	log_error "homebrew 未找到"
	exit 1
fi

## oh-my-zsh
log_debug "==> 检查 oh-my-zsh..."
if [ ! -d "~/.oh-my-zsh" ]; then
	log_info "准备安装 oh-my-zsh"
	git clone https://github.com/robbyrussell/oh-my-zsh.git ~/.oh-my-zsh && log_info "已安装 oh-my-zsh"
else
  log_debug "已存在，跳过安装"
fi

## wget
log_debug "==> 检查 wget"
cmd_exists cookiecutter
if [ $? -ne 0 ]; then
	log_info "准备安装 wget"
	brew install wget && log_info "已安装 wget"
else
  log_debug "已存在，跳过安装"
fi

## cookiecutter
log_debug "==> 检查 cookiecutter"
cmd_exists cookiecutter
if [ $? -ne 0 ]; then
	log_info "准备安装 cookiecutter"
	brew install cookiecutter && log_info "已安装 cookiecutter"
else
  log_debug "已存在，跳过安装"
fi

## tree
log_debug "==> 检查 tree"
cmd_exists tree
if [ $? -ne 0 ]; then
	log_info "准备安装 tree"
	brew install tree && log_info "已安装 tree"
else
  log_debug "已存在，跳过安装"
fi

## ruby
log_debug "==> 检查 ruby"
gem sources | grep 'http' | while read line; do
  gem source -r $line
done
gem source -a https://gems.ruby-china.com/

## rbenv
log_debug "==> 检查 rbenv"
cmd_exists rbenv
if [ $? -ne 0 ]; then
	log_info "准备安装 rbenv"
	brew install rbenv ruby-build rbenv-vars && log_info "已安装 rbenv"
  log_info "导入 rbenv 环境变量"
  echo "" >> ${profile}
  echo "## rbenv" >> ${profile}
  echo 'export PATH="~/.rbenv/bin:$PATH"' >> ${profile}
  echo 'eval "$(rbenv init -)"' >> ${profile}
  echo "export RUBY_BUILD_MIRROR_URL=https://cache.ruby-china.com" >> ${profile}
else
  log_debug "已存在，跳过安装"
fi

## cocoapods
log_debug "==> 检查 cocoapods"
cmd_exists pod
if [ $? -ne 0 ]; then
	log_info "准备安装 cocoapods"
  ## 安装到 ~/.gem/目录
	gem install cocoapods --user && log_info "已安装 cocoapods"

  ## 环境设置
  local gem_user_install_dir=`gem env | grep "USER INSTALLATION DIRECTORY" | awk -F":" '{ print  $2 }' | tr -d '[:space:]'`
  local gem_user_bin_dir="${gem_user_install_dir}/bin"
  echo "" >> ${profile}
  echo "## gem" >> ${profile}
  echo 'export GEM_HOME=~/.gem' >> ${profile}
  echo "export PATH=\"$gem_user_bin_dir:\$PATH\"" >> ${profile}
else
  log_debug "已存在，跳过安装"
fi

## pyenv
log_debug "==> 检查 pyenv"
cmd_exists pyenv
if [ $? -ne 0 ]; then
	log_info "准备安装 pyenv"
	brew install pyenv pyenv-virtualenv && log_info "已安装 pyenv"

  echo "" >> ${profile}
  echo "## pyenv" >> ${profile}
  echo 'export PYENV_ROOT="~/.pyenv"' >> ${profile}
  echo 'export PATH=$PYENV_ROOT/shims:$PATH' >> ${profile}
  echo 'eval "$(pyenv init -)"' >> ${profile}
  echo 'eval "$(pyenv virtualenv-init -)"' >> ${profile}
else
  log_debug "已存在，跳过安装"
fi

## 删除已有配置
rm -rf ~/.zshrc
rm -rf ~/.lldbinit

## 软链当前配置
ln -s ${config_path}/.zshrc ~/.zshrc
ln -s ${config_path}/.lldbinit ~/.lldbinit

echo "$(tput setaf 2)"
echo "################################"
echo "  安装完成"
echo "################################"
echo "$(tput sgr0)"
