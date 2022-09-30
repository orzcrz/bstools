#!/usr/bin/env python
# -*- encoding: utf-8 -*-

"""
Created by crzorz on 2022/09/15
Copyright © 2022 BaldStudio. All rights reserved.
"""

import sys
import logging
import argparse
import time

from core.logger import logger, set_log_level
from core.routines import routines
from .update import update_tool

parser = argparse.ArgumentParser(prog='bs',
                                 description="命令行工具箱",
                                 epilog='工具箱版本 1.0.0')
parser.add_argument('--verbose', 
                    action='store_true', 
                    default=False, 
                    help="详细输出")

parser.add_argument('--update', 
                    action='store_true', 
                    default=False,
                    help="更新到最新版本")

subparser = parser.add_subparsers(title="目前支持的功能", dest="command")
command_handler_map = {}
  
def register_commands():
  for CommandClass in routines:
    cmd = CommandClass()
    cmd_args_parser = subparser.add_parser(cmd.name(), 
                                           help=cmd.help(), 
                                           description=cmd.description(),
                                           epilog='当前版本: %s' % cmd.version())
    cmd.args_parser(cmd_args_parser)
    cmd_args_parser.add_argument('--verbose', 
                                 action='store_true', 
                                 default=False, 
                                 help="详细输出")

    command_handler_map[cmd.name()] = cmd;


def handle_command(args):
  command_handler = command_handler_map.get(args.command)
  if command_handler == None:
    parser.print_help()
  else:
    begin_time = time.time()
    command_handler.handle_command(args)
    cost = time.time() - begin_time
    logger.debug("TOTAL COST: {}".format(cost))


def main():
  # 调整日志输出级别
  args = parser.parse_args()
  if args.verbose:
    set_log_level(logging.DEBUG)

  # 更新工具
  if args.update:
    update_tool()
    return

  register_commands()    
  handle_command(args)


if __name__ == '__main__':
  sys.exit(main())