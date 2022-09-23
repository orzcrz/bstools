#!/usr/bin/env python
# -*- encoding: utf-8 -*-

"""
Created by crzorz on 2022/09/15
Copyright © 2022 BaldStudio. All rights reserved.
"""

import os
import sys

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
    self.integrateParser.add_argument('-s', '-silent', 
                                      action='store_true', 
                                      default=False, 
                                      help='Quite Mode')
    
    
  def handle_command(self, args):
    self.args = args
