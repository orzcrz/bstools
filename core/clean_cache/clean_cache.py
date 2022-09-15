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
  
  
  def help(self):
    return 'cg cleancache'


  def description(self):
    return '清理缓存文件, 释放mac的硬盘空间'


  def args_parser(self, parser):
    self.integrateParser = parser
    self.integrateParser.add_argument("-q", 
                                      action='store_true', 
                                      default=False, 
                                      help='Quite Mode')
    
    
  def handle_command(self, args):
    self.args = args
