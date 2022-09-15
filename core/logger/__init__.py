#!/usr/bin/env python
# -*- encoding: utf-8 -*-

"""
Created by crzorz on 2022/09/15
Copyright © 2022 BaldStudio. All rights reserved.
"""

import os
import sys
import logging

from colorlog import ColoredFormatter

LOG_LEVEL = logging.INFO
LOGFORMAT = "%(log_color)s%(levelname)s%(reset)s: %(log_color)s%(message)s%(reset)s"


logging.root.setLevel(LOG_LEVEL)
formatter = ColoredFormatter(LOGFORMAT)

stream = logging.StreamHandler()
stream.setLevel(LOG_LEVEL)
stream.setFormatter(formatter)

logger = logging.getLogger('cg')
logger.setLevel(LOG_LEVEL)
logger.addHandler(stream)

def set_log_level(level):
    logging.root.setLevel(level)
    stream.setLevel(level)
    logger.setLevel(level)