#!/usr/bin/env bash

# Created by crzorz on 2022/09/15
# Copyright © 2022 BaldStudio. All rights reserved.

. shells/logger.sh

set -e
set -u
set -o pipefail

cd ~

root_dir="$HOME/.bstools"
profiles_path=$root_dir/profiles

zshrc=$profiles_path/.zshrc
zsh_profile=$profiles_path/.zprofile

# 安装bstools
function setup_bstools() {
  log_info "==> 尝试安装 bstools"

  rm -rf $root_path
  local tools_url=git@github.com:orzcrz/bstools.git
  git clone --recurse-submodules $tools_url $root_path
  log_info "已下载最新版本到本地"

  log_info "导入环境变量"
  local pattern="## bstools"
  local env="export PATH=\$HOME/.bstools/bin:\$PATH"
  local line="\n$pattern\n$env"
  local files=(
    $zsh_profile
  )
  for i in "${!files[@]}"; do
    local file="${files[i]}"
    if [[ -f "$file" ]];then
      grep -F "$pattern" "$file" 1>/dev/null 2>&1 || echo -e "$line" >> "$file"
    fi
  done

  cd $root_dir
  local py3=$(which python3)
  log_info "Use python3 path: $py3"
  local py3_v=`$py3 -V`
  log_info "python version: $py3_v"

  log_info "generate new venv."
  local venv_path="venv"
  $py3 -m venv $venv_path

  source $venv_path/bin/activate
  
  set +e
  pip3 install -r requirements.txt -i https://pypi.tuna.tsinghua.edu.cn/simple/
  set -e

  source ~/.zprofile
  if command -v bs 1>/dev/null 2>&1; then
    log_info "安装成功"
  else
    log_error "安装失败"
    exit 1
  fi

  cd ~
}

# arm版本的Mac上安装Homebrew
function setup_brew_if_needed() {
  log_info "==> 尝试安装 Homebrew"
  if command -v brew 1>/dev/null 2>&1; then
    log_info "已存在，跳过安装"
    return
  fi

  local cpu=`sysctl -n machdep.cpu.brand_string`
  local cpu_arch=`uname -m`
  log_info "处理器信息： $cpu，$cpu_arch"
  if [[ $cpu =~ "Apple" ]] && [[ $cpu_arch =~ "arm" ]]; then
    log_info "安装 arm版 Homebrew"
    local brew_repo=/opt/homebrew
    local remote_url=https://github.com/Homebrew/brew/tarball/master
    sudo mkdir -p $brew_repo
    sudo chown -R $(whoami) $brew_repo
    curl -L $remote_url | tar xz --strip 1 -C $brew_repo

    log_info "导入环境变量"    
    local bottles_url=https://mirrors.ustc.edu.cn/homebrew-bottles
    echo -e "\n## homebrew" >> $zsh_profile
    echo "export PATH=$brew_repo/bin:\$PATH" >> $zsh_profile
    echo "export PATH=$brew_repo/sbin:\$PATH" >> $zsh_profile
    echo "HOMEBREW_BOTTLE_DOMAIN=$bottles_url" >> $zsh_profile

    log_info "替换 Homebrew 源地址"
    local repo_url=https://mirrors.ustc.edu.cn/brew.git
    local core_url=https://mirrors.ustc.edu.cn/homebrew-core.git
    local cask_url=https://mirrors.ustc.edu.cn/homebrew-cask.git

    cd $brew_repo
    git remote set-url origin $repo_url

    local tap_dir=$brew_repo/Library/Taps/homebrew
    cd "$tap_dir/homebrew-core"
    git remote set-url origin $core_url
    cd "$tap_dir/homebrew-cask"
    git remote set-url origin $cask_url

    cd ~
    source ~/.zprofile
    if command -v brew 1>/dev/null 2>&1; then
      log_info "安装成功"
    else
      log_error "安装失败"
      exit 1
    fi
  else
    log_error "非arm版的没适配，自己动手吧"
    exit 1
  fi
}

## pyenv
function setup_pyenv() {
  log_info "==> 尝试安装 pyenv"
  if command -v bs 1>/dev/null 2>&1; then
    log_info "已存在，跳过安装"
    return
  fi

  brew install pyenv pyenv-virtualenv && log_info "已安装 pyenv"

  log_info "导入环境变量"
  echo -e "\n## pyenv" >> $zsh_profile
  echo 'export PYENV_ROOT=$HOME/.pyenv' >> $zsh_profile
  echo 'export PATH=$PYENV_ROOT/shims:$PATH' >> $zsh_profile
  echo 'if command -v pyenv 1>/dev/null 2>&1; then'
  echo '  eval "$(pyenv init -)"' >> $zsh_profile
  echo '  eval "$(pyenv virtualenv-init -)"' >> $zsh_profile
  echo 'fi'

  log_info "pip源已在$HOME/.pip中配置"

  source ~/.zprofile
  if command -v pyenv 1>/dev/null 2>&1; then
    log_info "安装成功"
  else
    log_error "安装失败"
    exit 1
  fi

  log_info "将全局python切到3.9.5"
  pyenv global 3.9.5
}

## wget
function setup_wget() {
  ## wget
  log_info "==> 尝试安装 wget"
  if command -v wget 1>/dev/null 2>&1; then
    log_info "已存在，跳过安装"
    return
  fi

  brew install wget && log_info "已安装 wget"
}

## cookiecutter
function setup_cookiecutter() {
  log_info "==> 尝试安装 cookiecutter"
  if command -v cookiecutter 1>/dev/null 2>&1; then
    log_info "已存在，跳过安装"
    return
  fi

  brew install cookiecutter && log_info "已安装 cookiecutter"
}

## tree
function setup_tree() {
  log_info "==> 尝试安装 cookiecutter"
  if command -v tree 1>/dev/null 2>&1; then
    log_info "已存在，跳过安装"
    return
  fi

  brew install tree && log_info "已安装 tree"
}

## rbenv
function setup_rbenv() {
  log_info "==> 尝试将Ruby换成国内源"
  gem sources | grep 'http' | while read line; do
    gem source -r $line
  done
  gem source -a https://gems.ruby-china.com/
  log_info "当前Ruby源为：https://gems.ruby-china.com/"

  log_info "==> 尝试安装 rbenv"
  if command -v rbenv 1>/dev/null 2>&1; then
    log_info "已存在，跳过安装"
    return
  fi

  brew install rbenv ruby-build rbenv-vars && log_info "已安装 rbenv"

  log_info "导入环境变量"
  local mirror_url=https://cache.ruby-china.com
  echo -e "\n## rbenv" >> $zsh_profile
  echo 'export PATH=$HOME/.rbenv/bin:$PATH' >> $zsh_profile
  echo "export RUBY_BUILD_MIRROR_URL=$mirror_url" >> $zsh_profile
  echo 'if command -v rbenv 1>/dev/null 2>&1; then'
  echo '  eval "$(rbenv init -)"' >> $zsh_profile
  echo 'fi'

  source ~/.zprofile
  if command -v rbenv 1>/dev/null 2>&1; then
    log_info "安装成功"
  else
    log_error "安装失败"
    exit 1
  fi
}

## cocoapods
function setup_cocoapods() {
  log_info "==> 尝试安装 cocoapods"
  if command -v pod 1>/dev/null 2>&1; then
    log_info "已存在，跳过安装"
    return
  fi

  log_info "安装路径为：$HOME/.gem/"
  gem install cocoapods --user && log_info "已安装 cocoapods"

  log_info "导入环境变量"
  local install_dir=`gem env | grep "USER INSTALLATION DIRECTORY" | awk -F":" '{ print  $2 }' | tr -d '[:space:]'`
  local bin_dir="$install_dir/bin"
  echo -e "\n## gem" >> $zsh_profile
  echo 'export GEM_HOME=$HOME/.gem' >> $zsh_profile
  echo "export PATH=$bin_dir:\$PATH" >> $zsh_profile

  source ~/.zprofile
  if command -v pod 1>/dev/null 2>&1; then
    log_info "安装成功"
  else
    log_error "安装失败"
    exit 1
  fi
}

echo "$(tput setaf 2)"
echo "################################"
echo "  准备配置环境"
echo "################################"
echo "$(tput sgr0)"

log_warning "即将删除以下配置，请确认是否需要备份"
echo "~/.zshrc"
echo "~/.zprofile"
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
rm -f ~/.zprofile
rm -f ~/.lldbinit
rm -rf ~/.pip

## 软链当前配置
ln -s $zshrc ~/.zshrc
ln -s $zsh_profile ~/.zprofile
ln -s ${profiles_path}/lldb/.lldbinit ~/.lldbinit
ln -s ${profiles_path}/.pip ~/.pip

setup_bstools
setup_brew_if_needed
setup_pyenv
setup_wget
setup_cookiecutter
setup_tree
setup_rbenv
setup_cocoapods

# 安装lldb工具
# https://github.com/facebook/chisel
function setup_lldb_chisel() {
  brew install chisel
  echo -e "\n## chisel"
  echo 'command script import /opt/homebrew/opt/chisel/libexec/fblldb.py' >> $zsh_profile
}

setup_lldb_chisel


echo "$(tput setaf 2)"
echo "################################"
echo "  安装完成"
echo "################################"
echo "$(tput sgr0)"

## 切换到zsh
# chsh -s /bin/zsh