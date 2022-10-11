#!/usr/bin/env python
# -*- encoding: utf-8 -*-

"""
Created by crzorz on 2022/09/15
Copyright © 2022 BaldStudio. All rights reserved.
"""

from genericpath import isdir, isfile
import os
import sys

BIN_DIR = os.path.dirname(os.path.abspath(__file__))
sys.path.append(os.path.join(BIN_DIR, '..'))
sys.path.append(os.path.join(BIN_DIR, '..', 'core'))

from core import VERSION
import core.portal

version_file = os.path.join(BIN_DIR, '..', 'version')
if not os.path.exists(version_file):
  with open(version_file, 'w', encoding='utf-8') as f:
    f.write(VERSION)

if __name__ == '__main__':
  core.portal.main()