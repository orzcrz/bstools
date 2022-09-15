#!/usr/bin/env bash

# Created by crzorz on 2022/09/16
# Copyright © 2022 BaldStudio. All rights reserved.

set -e
set -u
set -o pipefail

module_dir=core/$1
mkdir -p $module_dir

cd $module_dir
touch __init__.py

touch $1.py
