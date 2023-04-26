#!/usr/bin/env python
# -*- encoding: utf-8 -*-

"""
Created by crzorz on 2022/09/15
Copyright © 2022 BaldStudio. All rights reserved.
"""

import os
import sys

sys.path.append(os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))

from bstools import VERSION, ROOT_DIR
from bstools.portal import main

version_file = os.path.join(ROOT_DIR, 'version')
if not os.path.exists(version_file):
    with open(version_file, 'w', encoding='utf-8') as f:
        f.write(VERSION)

if __name__ == '__main__':
    main()
