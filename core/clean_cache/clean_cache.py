#!/usr/bin/env python
# -*- encoding: utf-8 -*-

"""
Created by crzorz on 2022/09/15
Copyright © 2022 BaldStudio. All rights reserved.
"""

import os
import sys
import subprocess

from core.logger import logger

class CleanCache:  
  
  def name(self):
    return 'cleancache'
  
  
  def version(self):
    return '1.0.0'

  
  def help(self):
    return 'bs cleancache'


  def description(self):
    return '清理缓存文件, 释放mac的硬盘空间'


  def args_parser(self, parser):
    self.integrateParser = parser


  def handle_command(self, args):
    self.args = args
    size = self._sizeof_fmt(1024)
    logger.info(size)

  
  def _sizeof_fmt(self, num, suffix='B'):
    for unit in ['','K','M','G','T','P','E','Z']:
        if abs(num) < 1024.0:
            return "%3.1f %s%s" % (num, unit, suffix)
        num /= 1024.0
    return "%.1f %s%s" % (num, 'Y', suffix)

  
  def sizeof_directory(self, dir):
    return float(subprocess.check_output("du -d 0 {} | awk '{{print $1}}'".format(dir), shell=True)) * 512