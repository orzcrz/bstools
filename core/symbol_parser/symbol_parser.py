#!/usr/bin/env python
# -*- encoding: utf-8 -*-

"""
Created by crzorz on 2022/09/27
Copyright © 2022 BaldStudio. All rights reserved.
"""

import os
import subprocess

from core.logger import logger

XCODE_CONTENT_DIR = "/Applications/Xcode.app/Contents"
DEVELOPER_DIR = os.path.join(XCODE_CONTENT_DIR, 'Developer')
TOOL_DIR = os.path.join(XCODE_CONTENT_DIR, 'SharedFrameworks/DVTFoundation.framework/Versions/A/Resources')

XC_ENVIRON = os.environ.copy()
XC_ENVIRON['DEVELOPER_DIR'] = DEVELOPER_DIR

class SymbolParser:
    
  def name(self):
    return 'symbol'


  def version(self):
    return '1.0.0'


  def help(self):
    return 'bs symbol'


  def description(self):
    return 'SymbolParser'


  def args_parser(self, parser):
      self.integrateParser = parser
      self.integrateParser.add_argument('-p', '--parse', 
                                        help='指定需要解析的crash文件完整路径')
      self.integrateParser.add_argument('-o', '--output', 
                                  help='指定重新符号化文件的输出路径，默认和待解析文件同路径')
            
      self.integrateParser.add_argument('-u', '--uuid', 
                                        help='查看dSYM文件对应的UUID')


  def handle_command(self, args):
    self.args = args
    
    # 重新符号化.crash文件
    if args.parse:
      output = args.output
      if not output:
        output = os.path.join(args.parse, '..', 'output.crash')
      self._parse_crash(args.parse, output)
      return 0
    
    # 输出dSYM文件的UUID
    if args.uuid:
      self._get_uuid(args.uuid)
      return 0
    
          
  def _parse_crash(self, file, output):  
    cmd = [ os.path.join(TOOL_DIR, 'symbolicatecrash'), file ]
    logger.debug('Running: %r', cmd)
    logger.debug('Output File: %s', output)
    subprocess.check_call(cmd, stdout=open(output,'w'), env=XC_ENVIRON)
  
  
  def _get_uuid(self, file):
    cmd = ['dwarfdump', '-u', file]
    logger.debug('Running: %r', cmd)
    subprocess.check_call(cmd)
