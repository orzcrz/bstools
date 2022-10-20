#!/usr/bin/env python
# -*- encoding: utf-8 -*-

"""
Created by crzorz on 2022/09/15
Copyright © 2022 BaldStudio. All rights reserved.
"""

import os
import sys

sys.path.append(os.environ['BSTOOLS_ROOT'])

from bstools import VERSION, BSTOOLS_ROOT
from bstools.portal import main

version_file = os.path.join(BSTOOLS_ROOT, 'version')
if not os.path.exists(version_file):
  with open(version_file, 'w', encoding='utf-8') as f:
    f.write(VERSION)

if __name__ == '__main__':
  main()