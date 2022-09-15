#!/usr/bin/env bash

# debug:0; info:1; warning:2; error:3
loglevel=0
logfile="./$(date +'%F').log"

function log() {
  local logtype=$1
  local msg=$2
  local datetime=$(date +'%F %H:%M:%S')
  local logformat="[${logtype}] ${datetime} [${FUNCNAME[2]} - $(caller 0 | awk '{print$1}')] ${msg}"
  {
  case $logtype in
  DEBUG)
    [[ $loglevel -le 0 ]] && echo -e "\033[34m${logformat}\033[0m" ;;
  INFO)
    [[ $loglevel -le 1 ]] && echo -e "\033[32m${logformat}\033[0m" ;;
  WARNING)
    [[ $loglevel -le 2 ]] && echo -e "\033[33m${logformat}\033[0m" ;;
  ERROR)
    [[ $loglevel -le 3 ]] && echo -e "\033[31m${logformat}\033[0m" ;;
  esac
  } #| tee -a $logfile
}

function log_debug() {
  log DEBUG "$*"
}

function log_info() {
  log INFO "$*"
}

function log_warning() {
  log WARNING "$*"
}

function log_error() {
  log ERROR "$*"
}