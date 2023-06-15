#!/usr/bin/env python
# -*- encoding: utf-8 -*-

"""
Created by crzorz on 2022/09/15
Copyright © 2022 BaldStudio. All rights reserved.
"""

import logging
import types

from colorlog import ColoredFormatter


class LogLevel:
    CRITICAL = logging.CRITICAL
    FATAL = logging.FATAL
    ERROR = logging.ERROR
    WARNING = logging.WARNING
    WARN = logging.WARN
    INFO = logging.INFO
    DEBUG = logging.DEBUG
    NOTSET = logging.NOTSET


LOG_FORMAT = ColoredFormatter(
    '%(log_color)s[%(levelname)s]:[%(asctime)s] %(message)s%(reset)s')
stream = logging.StreamHandler()
stream.setFormatter(LOG_FORMAT)

logger = logging.getLogger('bs')
logger.addHandler(stream)


def set_level(self, level):
    logging.root.setLevel(level)
    stream.setLevel(level)
    logger.setLevel(level)


logger.set_level = types.MethodType(set_level, logger)
logger.set_level(LogLevel.INFO)
