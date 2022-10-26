#!/usr/bin/env bash

# Created by crzorz on 2022/09/16
# Copyright © 2022 BaldStudio. All rights reserved.

## ./plugin_gen.sh YOUR_NAME 

set -e
set -u
set -o pipefail

plugin_dir=$CGTOOLS_ROOT/cgtools/plugins/$1
mkdir -p $plugin_dir

cd $plugin_dir
touch __init__.py

touch $1.py