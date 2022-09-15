#!/usr/bin/env python
# -*- encoding: utf-8 -*-

"""
Created by crzorz on 2022/09/15
Copyright © 2022 BaldStudio. All rights reserved.
"""

import os
import sys

BIN_DIR = os.path.dirname(os.path.abspath(__file__))
sys.path.append(os.path.join(BIN_DIR, '..'))
sys.path.append(os.path.join(BIN_DIR, '..', 'core'))

import core.portal

if __name__ == '__main__':
  core.portal.main()