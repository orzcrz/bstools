#!/usr/bin/env bash

# Created by crzorz on 2022/09/15
# Copyright © 2022 BaldStudio. All rights reserved.

set -e
set -o pipefail

cd ~

root_dir="$HOME/.bstools"
profiles_path=$root_dir/profiles

zshrc=$profiles_path/.zshrc
zprofile=$profiles_path/.zprofile
lldbinit=$profiles_path/lldb/.lldbinit

# logger
# debug:0; info:1; warn:2; error:3
log_level=1
log_detail=0

logging() {
  local log_type
  log_type=$1
  readonly log_type

  local msg
  msg=$2
  readonly msg

  local now
  now=$(date +'%F %H:%M:%S')
  readonly now

  local log_format="[${log_type}]:[${now}] ${msg}"
  if [[ ${log_detail} -eq 1 ]]; then
    log_format="[${log_type}]:[${now}] [${FUNCNAME[2]} - $(caller 0 | awk '{print$1}')] ${msg}"
  fi

  case $log_type in
  DEBUG)
    if [[ $log_level -le 0 ]]; then
      echo -e "\033[37m${log_format}\033[0m"
    fi
    ;;
  INFO)
    if [[ $log_level -le 1 ]]; then
      echo -e "\033[32m${log_format}\033[0m"
    fi
    ;;
  WARNING)
    if [[ $log_level -le 2 ]]; then
      echo -e "\033[33m${log_format}\033[0m"
    fi
    ;;
  ERROR)
    if [[ $log_level -le 3 ]]; then
      echo -e "\033[31m${log_format}\033[0m"
    fi
    ;;
  esac
}

log_debug() {
  logging DEBUG "$*"
}

log_info() {
  logging INFO "$*"
}

log_warning() {
  logging WARNING "$*"
}

log_error() {
  logging ERROR "$*"
}

# 安装bstools
function setup_bstools() {
  log_info "==> 尝试安装 bstools"

  rm -rf "$root_dir"
  local tools_url=git@github.com:orzcrz/bstools.git
  git clone --depth 1 --recurse-submodules $tools_url "$root_dir"
  log_info "已下载最新版本到本地"

#   log_info "导入环境变量"
#   local pattern="## bstools"
#   local env="export BSTOOLS_ROOT=\$HOME/.bstools\nexport PATH=\$BSTOOLS_ROOT/bin:\$PATH"
#   local line="$pattern\n$env"
#   local files=(
#     $zprofile
#   )
#   for i in "${!files[@]}"; do
#     local file="${files[i]}"
#     if [[ -f "$file" ]];then
#       grep -F "$pattern" "$file" 1>/dev/null 2>&1 || echo -e "$line" >> "$file"
#     fi
#   done

  cd "$root_dir"
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
  python -m pip install --upgrade pip
  set -e
  
  rm -rf "$root_dir"/.git

  cd ~
}

# arm版本的Mac上安装Homebrew
function setup_brew_if_needed() {
  log_info "==> 尝试安装 Homebrew"

  local bottles_url=https://mirrors.ustc.edu.cn/homebrew-bottles/bottles/
  local repo_url=https://mirrors.ustc.edu.cn/brew.git
  local core_url=https://mirrors.ustc.edu.cn/homebrew-core.git
  # local bottles_url=https://mirrors.aliyun.com/homebrew/homebrew-bottles
  # local repo_url=https://mirrors.aliyun.com/homebrew/brew.git
  # local core_url=https://mirrors.aliyun.com/homebrew/homebrew-core.git

  local cpu_brand=`sysctl -n machdep.cpu.brand_string`
  local cpu_arch=`uname -m`
  log_info "处理器信息： $cpu_brand | $cpu_arch"
  if [[ "$cpu_brand" =~ "Apple" ]] && [[ "$cpu_arch" =~ "arm" ]]; then
    if command -v brew 1>/dev/null 2>&1; then
      log_info "已存在，跳过安装"
    else
      log_info "安装 arm版 Homebrew"
      local brew_repo=/opt/homebrew
      local remote_url=https://github.com/Homebrew/brew/tarball/master
      sudo mkdir -p $brew_repo
      sudo chown -R $(whoami) $brew_repo
      curl -L $remote_url | tar xz --strip 1 -C $brew_repo
    fi

    # log_info "导入环境变量"    
    # echo -e "\n## homebrew" >> $zprofile
    # echo "export PATH=$brew_repo/bin:\$PATH" >> $zprofile
    # echo "export PATH=$brew_repo/sbin:\$PATH" >> $zprofile
    # echo "export HOMEBREW_BOTTLE_DOMAIN=$bottles_url" >> $zprofile
    # echo "export HOMEBREW_BREW_GIT_REMOTE=$repo_url" >> $zprofile
    # echo "export HOMEBREW_CORE_GIT_REMOTE=$core_url" >> $zprofile
    # echo "export HOMEBREW_NO_INSTALL_FROM_API=1" >> $zprofile

  else
    log_warning "非arm版的没适配，先手动预装吧"
    log_info '手动执行这段 ==> /bin/zsh -c "$(curl -fsSL https://gitee.com/cunkai/HomebrewCN/raw/master/Homebrew.sh)"'

    # 装好了就插入环境变量
    # if command -v brew 1>/dev/null 2>&1; then
    #   echo -e "\n## homebrew" >> $zprofile
    #   echo "export HOMEBREW_BOTTLE_DOMAIN=$bottles_url" >> $zprofile
    #   echo "export HOMEBREW_BREW_GIT_REMOTE=$repo_url" >> $zprofile
    #   echo "export HOMEBREW_CORE_GIT_REMOTE=$core_url" >> $zprofile
    #   echo "export HOMEBREW_NO_INSTALL_FROM_API=1" >> $zprofile
    # fi
  fi

  cd ~
  source ~/.zprofile
  if command -v brew 1>/dev/null 2>&1; then
    log_info "安装成功"
  else
    log_error "安装失败"
    exit 1
  fi
}

## pyenv
function setup_pyenv() {
  log_info "==> 尝试安装 pyenv"
  if command -v pyenv 1>/dev/null 2>&1; then
    log_info "已存在，跳过安装"
  else
    brew install pyenv pyenv-virtualenv && log_info "已安装 pyenv"
  fi

#   log_info "导入环境变量"
#   echo -e "\n## pyenv" >> $zprofile
#   echo 'export PYENV_ROOT=$HOME/.pyenv' >> $zprofile
#   echo 'export PATH=$PYENV_ROOT/shims:$PATH' >> $zprofile
#   echo 'if command -v pyenv 1>/dev/null 2>&1; then' >> $zprofile
#   echo '  eval "$(pyenv init -)"' >> $zprofile
#   echo '  eval "$(pyenv virtualenv-init -)"' >> $zprofile
#   echo 'fi' >> $zprofile

  log_info "pip源已在$HOME/.pip中配置"

  source ~/.zprofile
  if command -v pyenv 1>/dev/null 2>&1; then
    log_info "安装成功"
  else
    log_error "安装失败"
  fi
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
  log_info "==> 尝试安装 rbenv"
  if command -v rbenv 1>/dev/null 2>&1; then
    log_info "已存在，跳过安装"
  else
    brew install rbenv ruby-build rbenv-vars && log_info "已安装 rbenv"
  fi

  log_info "==> 尝试将Ruby换成国内源"
  gem sources | grep 'http' | while read line; do
    gem source -r $line
  done
  gem source -a https://gems.ruby-china.com
  log_info "当前Ruby源为：https://gems.ruby-china.com"

#   log_info "导入环境变量"
#   local mirror_url=https://cache.ruby-china.com
#   echo -e "\n## rbenv" >> $zprofile
#   echo 'export PATH=$HOME/.rbenv/bin:$PATH' >> $zprofile
#   echo "export RUBY_BUILD_MIRROR_URL=$mirror_url" >> $zprofile
#   echo 'if command -v rbenv 1>/dev/null 2>&1; then' >> $zprofile
#   echo '  eval "$(rbenv init -)"' >> $zprofile
#   echo 'fi' >> $zprofile

  source ~/.zprofile
  if command -v rbenv 1>/dev/null 2>&1; then
    log_info "安装成功"
  else
    log_error "安装失败"
  fi
}

## cocoapods
function setup_cocoapods() {
  log_info "==> 尝试安装 cocoapods"
  if command -v pod 1>/dev/null 2>&1; then
    log_info "已存在，跳过安装"
  else
    log_info "安装路径为：$HOME/.gem/"
    
    ## M1
    gem install cocoapods --user-install && log_info "已安装 cocoapods"

    ## intel
    # gem install -n /usr/local/bin cocoapods && log_info "已安装 cocoapods"
  fi

#   log_info "导入环境变量"
#   local install_dir=`gem env | grep "USER INSTALLATION DIRECTORY" | awk -F":" '{ print  $2 }' | tr -d '[:space:]'`
#   local bin_dir="$install_dir/bin"
#   echo -e "\n## gem" >> $zprofile
#   echo 'export GEM_HOME="$(ruby -e 'puts Gem.user_dir')"' >> $zprofile
#   echo 'export PATH="$PATH:$GEM_HOME/bin"' >> $zprofile

  source ~/.zprofile
  if command -v pod 1>/dev/null 2>&1; then
    log_info "安装成功"
  else
    log_error "安装失败"
  fi
}

# 安装lldb工具
# https://github.com/facebook/chisel
function setup_lldb_chisel() {
  brew install chisel && log_info "已安装 chisel"
#   echo -e "\n## chisel" >> $lldbinit
#   echo 'command script import /opt/homebrew/opt/chisel/libexec/fblldb.py' >> $lldbinit
}

function setup_node() {
  brew install node && log_info "已安装 Node.js"
  ## 查看当前的镜像
  ## 原 https://registry.npmjs.org
  log_info "原镜像：$(npm get registry)"
  ## 将地址设置为淘宝镜像
  npm config set registry https://registry.npm.taobao.org/
  log_info "修改镜像为：$(npm get registry)"
}

echo "$(tput setaf 2)"
echo "################################"
echo "  准备配置环境"
echo "################################"
echo "$(tput sgr0)"

setup_bstools

log_warning "更新以下配置"
log_warning "~/.zshrc"
log_warning "~/.zprofile"
log_warning "~/.lldbinit"
log_warning "~/.pip"
log_warning "~/.gitignore_global"

zsh_plugin_path=${profiles_path}/oh-my-zsh/custom/plugins
log_warning "${zsh_plugin_path}/zsh-syntax-highlighting"
log_warning "${zsh_plugin_path}/zsh-autosuggestions"

## 软链当前配置
ln -sf $zshrc ~/.zshrc
ln -sf $zprofile ~/.zprofile
ln -sf $lldbinit ~/.lldbinit
ln -sf ${profiles_path}/.pip ~/.pip
ln -sf ${profiles_path}/.gitignore_global ~/.gitignore_global
ln -sf ${profiles_path}/zsh-syntax-highlighting ${zsh_plugin_path}/zsh-syntax-highlighting
ln -sf ${profiles_path}/zsh-autosuggestions ${zsh_plugin_path}/zsh-autosuggestions

setup_brew_if_needed
setup_pyenv
setup_wget
setup_cookiecutter
setup_tree
setup_rbenv
setup_cocoapods
setup_lldb_chisel
setup_node

# brew tap homebrew/cask
# 安装vscode
# brew install --cask visual-studio-code

echo "$(tput setaf 2)"
echo "################################"
echo "  安装完成"
echo "################################"
echo "$(tput sgr0)"

## 切换到zsh
# chsh -s /bin/zsh
