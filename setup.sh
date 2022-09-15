#!/usr/bin/env bash

# Created by crzorz on 2022/09/15
# Copyright © 2022 BaldStudio. All rights reserved.

. shells/logger.sh
. shells/utils.sh

set -e
set -u
set -o pipefail

cd ~

root_path="$HOME/.bstools"
profiles_path=${root_path}/profiles

zshrc=${profiles_path}/.zshrc
zsh_profile=${profiles_path}/.zsh_profile
zsh_alias=${profiles_path}/.zsh_alias

# 工具路径写到用户配置里
function setup_bstools() {
  log_info "尝试安装bstools"

  rm -rf $root_path
  git clone "git@github.com:orzcrz/bstools.git" $root_path

  local pattern="# bstools"
  local export_path="export PATH=\"\$HOME/.bstools/bin:\$PATH\""
  local line="\n$pattern\n$export_path"
  local files=(
    $profiles_path/zsh_profile
  )
  for i in "${!files[@]}"; do
      local file="${files[i]}"
      if [[ -f "$file" ]];then
        grep -F "$pattern" "$file" 1>>/dev/null 2>>/dev/null || echo -e "$line" >> "$file"
      fi
  done
}

# arm版本的Mac电脑，手动安装Homebrew
function setup_brew_if_needed() {
  log_info "尝试安装Homebrew"
  local cpu=`sysctl -n machdep.cpu.brand_string`
  local cpu_arch=`uname -m`
  log_info "处理器信息： ${cpu}，${cpu_arch}"
  if [[ ${cpu} =~ "Apple" ]] && [[ ${cpu_arch} =~ "arm" ]]; then
    log_info "安装Homebrew"
    local brew_repo=/opt/homebrew
    local remote_url=https://github.com/Homebrew/brew/tarball/master
    sudo mkdir -p ${brew_repo}
    sudo chown -R $(whoami) ${brew_repo}
    curl -L $remote_url | tar xz --strip 1 -C ${brew_repo}

    log_info "导入 Homebrew 环境变量"    
    local bottles_url=https://mirrors.ustc.edu.cn/homebrew-bottles
    echo -e "\n## homebrew" >> ${zsh_profile}
    echo -e '\nexport PATH=/opt/homebrew/bin:$PATH' >> ${zsh_profile}
    echo -e '\nexport PATH=/opt/homebrew/sbin:$PATH' >> ${zsh_profile}
    echo -e "\nHOMEBREW_BOTTLE_DOMAIN=$bottles_url" >> ${zsh_profile}

    log_info "替换 Homebrew 源地址"
    local repo_url=https://mirrors.ustc.edu.cn/brew.git
    local core_url=https://mirrors.ustc.edu.cn/homebrew-core.git
    local cask_url=https://mirrors.ustc.edu.cn/homebrew-cask.git

    cd ${brew_repo}
    git remote set-url origin $repo_url

    cd "${brew_repo}/Library/Taps/homebrew/homebrew-core"
    git remote set-url origin $core_url

    cd "${brew_repo}/Library/Taps/homebrew/homebrew-cask"
    git remote set-url origin $cask_url

    cd ~
  fi
}

echo "$(tput setaf 2)"
echo "################################"
echo "  准备配置环境"
echo "################################"
echo "$(tput sgr0)"

setup_bstools

setup_brew_if_needed

## 删除已有配置
rm -f ~/.zshrc
rm -f ~/.zsh_profile
rm -f ~/.zsh_alias
rm -f ~/.lldbinit

## 软链当前配置
ln -s $zshrc ~/.zshrc
ln -s $zsh_profile ~/.zsh_profile
ln -s $zsh_alias ~/.zsh_alias
ln -s ${profiles_path}/.lldbinit ~/.lldbinit

echo "$(tput setaf 2)"
echo "################################"
echo "  安装完成"
echo "################################"
echo "$(tput sgr0)"

## 切换到zsh
# chsh -s /bin/zsh