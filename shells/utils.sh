#!/usr/bin/env bash

cmd_exists() {
	command -v "$1" >/dev/null 2>&1
	if [ $? -ne 0 ]; then
		log_warn "命令$1不存在"
		return 1
	fi

	return 0
}