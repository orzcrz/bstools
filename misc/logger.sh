#!/usr/bin/env bash

# Created by crzorz on 2022/09/16
# Copyright © 2022 BaldStudio. All rights reserved.

# debug:0; info:1; warning:2; error:3
loglevel=0
log_detail=
logfile="./$(date +'%F').log"

log() {
  local msg
  local logtype
  logtype=$1
  msg=$2
  datetime=$(date +'%F %H:%M:%S')
  logformat="[${logtype}] ${msg}"
  if [[ ${log_detail} == 1 ]]; then
    logformat="[${logtype}] ${datetime} [${FUNCNAME[2]} - $(caller 0 | awk '{print$1}')] ${msg}"
  fi
  {
    case $logtype in
      DEBUG)
        [[ $loglevel -le 0 ]] && echo -e "\033[37m${logformat}\033[0m" ;;
      INFO)
        [[ $loglevel -le 1 ]] && echo -e "\033[32m${logformat}\033[0m" ;;
      WARNING)
        [[ $loglevel -le 2 ]] && echo -e "\033[33m${logformat}\033[0m" ;;
      ERROR)
        [[ $loglevel -le 3 ]] && echo -e "\033[31m${logformat}\033[0m" ;;
    esac
  } #| tee -a $logfile
}

log_debug() {
  log DEBUG "$*"
}

log_info() {
  log INFO "$*"
}

log_warning() {
  log WARNING "$*"
}

log_error() {
  log ERROR "$*"
}