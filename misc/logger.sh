#!/usr/bin/env bash

# Created by crzorz on 2022/09/16
# Copyright © 2022 BaldStudio. All rights reserved.

# debug:0; info:1; warn:2; error:3
log_level=2
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