#!/usr/bin/env python
# -*- encoding: utf-8 -*-

"""
Created by crzorz on 2022/09/15
Copyright © 2022 BaldStudio. All rights reserved.
"""

import os

VERSION = '1.0.0'

GIT = '/usr/bin/git'

BSTOOLS_ROOT = os.environ['BSTOOLS_ROOT']

BSTOOLS_SRC = os.path.join(BSTOOLS_ROOT, 'bstools')
os.environ['BSTOOLS_SRC'] = BSTOOLS_SRC

BSTOOLS_BIN = os.path.join(BSTOOLS_ROOT, 'bin')
os.environ['BSTOOLS_BIN'] = BSTOOLS_BIN

BSTOOLS_MISC = os.path.join(BSTOOLS_ROOT, 'misc')
os.environ['BSTOOLS_MISC'] = BSTOOLS_MISC