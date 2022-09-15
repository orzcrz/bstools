#!/usr/bin/env bash

# Created by crzorz on 2022/09/15
# Copyright © 2022 BaldStudio. All rights reserved.

. shells/logger.sh
. shells/utils.sh

set -e
set -u
set -o pipefail

cd ~

root_dir="$HOME/.bstools"
profiles_path=$root_dir/profiles

zshrc=$profiles_path/.zshrc
zsh_profile=$profiles_path/.zsh_profile
zsh_alias=$profiles_path/.zsh_alias

# 安装工具，导入环境变量
function setup_bstools() {
  log_info "尝试安装bstools"

  rm -rf $root_path
  local tools_url=git@github.com:orzcrz/bstools.git
  git clone --recurse-submodules $tools_url $root_path

  local pattern="## bstools"
  local env="export PATH=\"\$HOME/.bstools/bin:\$PATH\""
  local line="\n$pattern\n$env"
  local files=(
    $zsh_profile
  )
  for i in "${!files[@]}"; do
      local file="${files[i]}"
      if [[ -f "$file" ]];then
        grep -F "$pattern" "$file" 1>>/dev/null 2>>/dev/null || echo -e "$line" >> "$file"
      fi
  done

  source ~/.zsh_profile
  cmd_exists bs
  if [ $? -ne 0 ]; then
    log_error "bs 未找到"
    exit 1
  fi
}

# arm版本的Mac电脑，手动安装Homebrew
function setup_brew_if_needed() {
  log_info "尝试安装Homebrew"
  local cpu=`sysctl -n machdep.cpu.brand_string`
  local cpu_arch=`uname -m`
  log_info "处理器信息： $cpu，$cpu_arch"
  if [[ $cpu =~ "Apple" ]] && [[ $cpu_arch =~ "arm" ]]; then
    log_info "安装Homebrew"
    local brew_repo=/opt/homebrew
    local remote_url=https://github.com/Homebrew/brew/tarball/master
    sudo mkdir -p $brew_repo
    sudo chown -R $(whoami) $brew_repo
    curl -L $remote_url | tar xz --strip 1 -C $brew_repo

    log_info "导入 Homebrew 环境变量"    
    local bottles_url=https://mirrors.ustc.edu.cn/homebrew-bottles
    echo -e "\n## homebrew" >> $zsh_profile
    echo 'export PATH=/opt/homebrew/bin:$PATH' >> $zsh_profile
    echo 'export PATH=/opt/homebrew/sbin:$PATH' >> $zsh_profile
    echo "HOMEBREW_BOTTLE_DOMAIN=$bottles_url" >> $zsh_profile

    log_info "替换 Homebrew 源地址"
    local repo_url=https://mirrors.ustc.edu.cn/brew.git
    local core_url=https://mirrors.ustc.edu.cn/homebrew-core.git
    local cask_url=https://mirrors.ustc.edu.cn/homebrew-cask.git

    cd $brew_repo
    git remote set-url origin $repo_url

    cd "$brew_repo/Library/Taps/homebrew/homebrew-core"
    git remote set-url origin $core_url

    cd "$brew_repo/Library/Taps/homebrew/homebrew-cask"
    git remote set-url origin $cask_url

    cd ~
    source ~/.zsh_profile
  fi
}

## pyenv
function setup_pyenv() {
  log_info "==> 检查 pyenv"
  cmd_exists pyenv
  if [ $? -ne 0 ]; then
    log_info "准备安装 pyenv"
    brew install pyenv pyenv-virtualenv && log_info "已安装 pyenv"

    echo -e "\n## pyenv" >> $zsh_profile
    echo 'export PYENV_ROOT=$HOME/.pyenv' >> $zsh_profile
    echo 'export PATH=$PYENV_ROOT/shims:$PATH' >> $zsh_profile
    echo 'eval "$(pyenv init -)"' >> $zsh_profile
    echo 'eval "$(pyenv virtualenv-init -)"' >> $zsh_profile
    log_info "pip源已在~/.pip中配置"

    source ~/.zsh_profile
    pyenv global 3.9.5
  else
    log_info "已存在，跳过安装"
  fi
}

## wget
function setup_wget() {
  ## wget
  log_info "==> 检查 wget"
  cmd_exists wget
  if [ $? -ne 0 ]; then
    log_info "准备安装 wget"
    brew install wget && log_info "已安装 wget"
  else
    log_info "已存在，跳过安装"
  fi
}

## cookiecutter
function setup_cookiecutter() {
  log_info "==> 检查 cookiecutter"
  cmd_exists cookiecutter
  if [ $? -ne 0 ]; then
    log_info "准备安装 cookiecutter"
    brew install cookiecutter && log_info "已安装 cookiecutter"
  else
    log_info "已存在，跳过安装"
  fi
}

## tree
function setup_tree() {
  log_info "==> 检查 tree"
  cmd_exists tree
  if [ $? -ne 0 ]; then
    log_info "准备安装 tree"
    brew install tree && log_info "已安装 tree"
  else
    log_info "已存在，跳过安装"
  fi
}

## rbenv
function setup_rbenv() {
  log_info "==> 将Ruby换成国内源"
  gem sources | grep 'http' | while read line; do
    gem source -r $line
  done
  gem source -a https://gems.ruby-china.com/

  log_info "==> 检查 rbenv"
  cmd_exists rbenv
  if [ $? -ne 0 ]; then
    log_info "准备安装 rbenv"
    brew install rbenv ruby-build rbenv-vars && log_info "已安装 rbenv"

    log_info "导入 rbenv 环境变量"
    local mirror_url=https://cache.ruby-china.com
    echo -e "\n## rbenv" >> $zsh_profile
    echo 'export PATH="~/.rbenv/bin:$PATH"' >> $zsh_profile
    echo 'eval "$(rbenv init -)"' >> $zsh_profile
    echo "export RUBY_BUILD_MIRROR_URL=$mirror_url" >> $zsh_profile

    source ~/.zsh_profile

    cmd_exists rbenv
    if [ $? -ne 0 ]; then
      log_error "rbenv 未找到"
      exit 1
    fi

  else
    log_info "已存在，跳过安装"
  fi
}

## cocoapods
function setup_cocoapods() {
  log_info "==> 检查 cocoapods"
  cmd_exists cocoapods
  if [ $? -ne 0 ]; then
    log_info "准备安装 cocoapods"
    ## 安装到 ~/.gem/目录
    gem install cocoapods --user && log_info "已安装 cocoapods"

    ## 环境设置
    local install_dir=`gem env | grep "USER INSTALLATION DIRECTORY" | awk -F":" '{ print  $2 }' | tr -d '[:space:]'`
    local bin_dir="$install_dir/bin"
    echo -e "\n## gem" >> $zsh_profile
    echo 'export GEM_HOME=~/.gem' >> $zsh_profile
    echo "export PATH=\"$bin_dir:\$PATH\"" >> $zsh_profile

  else
    log_info "已存在，跳过安装"
  fi
}

echo "$(tput setaf 2)"
echo "################################"
echo "  准备配置环境"
echo "################################"
echo "$(tput sgr0)"

log_warning "即将删除以下配置，请确认是否需要备份"
echo "~/.zshrc"
echo "~/.zsh_profile"
echo "~/.zsh_alias"
echo "~/.zsh_alias"
echo "~/.lldbinit"
echo "~/.pip"

while true; do
  read -p "确认继续执行? (y/n) " yn
  case $yn in
    [Yy]* ) break;;
    [Nn]* ) exit;;
    * ) echo "Please answer Yy or Nn.";;
  esac
done

## 删除已有配置
rm -f ~/.zshrc
rm -f ~/.zsh_profile
rm -f ~/.zsh_alias
rm -f ~/.lldbinit
rm -rf ~/.pip

## 软链当前配置
ln -s $zshrc ~/.zshrc
ln -s $zsh_profile ~/.zsh_profile
ln -s $zsh_alias ~/.zsh_alias
ln -s ${profiles_path}/.lldbinit ~/.lldbinit
ln -s ${profiles_path}/.pip ~/.pip

setup_bstools

setup_brew_if_needed

echo "$(tput setaf 2)"
echo "################################"
echo "  安装完成"
echo "################################"
echo "$(tput sgr0)"

## 切换到zsh
# chsh -s /bin/zsh