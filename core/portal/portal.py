#!/usr/bin/env python
# -*- encoding: utf-8 -*-

"""
Created by crzorz on 2022/09/15
Copyright © 2022 BaldStudio. All rights reserved.
"""

import os
import sys
import logging
import argparse
import time

from core.logger import logger, set_log_level
from .routines import routines

parser = argparse.ArgumentParser(prog='bs',
                                 description="命令行工具箱")
subparser = parser.add_subparsers(title="Commands", dest="command")
command_handler_map = {}

def parse_args():
  parser.add_argument("--verbose", 
                      action="store_true", 
                      default=False,
                      help="详细输出")
  
  return parser.parse_args()


def register_commands():
  for CommandClass in routines:
    cmd = CommandClass()
    cmd_args_parser = subparser.add_parser(cmd.name(), 
                                           help=cmd.help(), 
                                           description=cmd.description())
    cmd.args_parser(cmd_args_parser)
    cmd_args_parser.add_argument("--verbose", 
                                 action="store_true", 
                                 default=False, 
                                 help="详细输出")
    command_handler_map[cmd.name()] = cmd;


def main():
  register_commands()
  
  args = parse_args()
  if args.verbose:
    set_log_level(logging.DEBUG)
  
  command_handler = command_handler_map.get(args.command)
  if command_handler == None:
    parser.print_help()
  else:
    begin_time = time.time()
    command_handler.handle_command(args)
    cost = time.time() - begin_time
    logger.debug("TOTAL COST: {}".format(cost))


if __name__ == '__main__':
  sys.exit(main())