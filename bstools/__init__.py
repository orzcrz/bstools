#!/usr/bin/env python
# -*- encoding: utf-8 -*-

"""
Created by crzorz on 2022/09/15
Copyright © 2022 BaldStudio. All rights reserved.
"""

import os

VERSION = '1.0.0' 

GIT = '/usr/bin/git'

ROOT_DIR = os.environ['BSTOOLS_ROOT']

SRC_DIR = os.path.join(ROOT_DIR, 'bstools')
os.environ['BSTOOLS_SRC'] = SRC_DIR

BIN_DIR = os.path.join(ROOT_DIR, 'bin')
os.environ['BSTOOLS_BIN'] = BIN_DIR

MISC_DIR = os.path.join(ROOT_DIR, 'misc')
os.environ['BSTOOLS_MISC'] = MISC_DIR
