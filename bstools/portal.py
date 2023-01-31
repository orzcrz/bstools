#!/usr/bin/env python
# -*- encoding: utf-8 -*-

"""
Created by crzorz on 2022/09/15
Copyright © 2022 BaldStudio. All rights reserved.
"""

import argparse
import time

from bstools import VERSION
from bstools.utils.logging import logger, LogLevel
from bstools.registry import PLUGINS
from bstools.update import update_if_needed

parser = argparse.ArgumentParser(prog='bs',
                                 description="命令行工具箱",
                                 epilog='工具箱版本 %s' % VERSION)

parser.add_argument('--verbose',
                    action='store_true',
                    default=False,
                    help="详细输出")

parser.add_argument('-v', '--version',
                    action="version",
                    help="工具箱版本",
                    version=VERSION)

parser.add_argument('--update',
                    action='store_true',
                    default=False,
                    help="更新到最新版本")

parser.add_argument('--update-force',
                    action='store_true',
                    default=False,
                    help="强制更新到最新版本")

plugin_parser = parser.add_subparsers(title="目前支持的功能", dest="command")
plugins_by_name = {}


def register_plugins():
    for plugin_class in PLUGINS:
        plugin = plugin_class()
        plugin.args_parser = plugin_parser.add_parser(plugin.name,
                                                      help=plugin.help,
                                                      description=plugin.description,
                                                      epilog='当前版本: %s' % plugin.version)
        plugin.args_parser.add_argument('--verbose',
                                        action='store_true',
                                        default=False,
                                        help="详细输出")
        plugin.args_parser.add_argument('--version',
                                        action="version",
                                        version=plugin.version)

        plugins_by_name[plugin.name] = plugin


def main():
    register_plugins()

    args = parser.parse_args()

    # 调整日志输出级别
    if args.verbose:
        logger.set_level(LogLevel.DEBUG)

    # 更新工具
    if args.update or args.update_force:
        update_if_needed(args.update_force)
        return

    logger.debug(args)
    plugin = plugins_by_name.get(args.command)
    if plugin is None:
        parser.print_help()
    else:
        begin_time_ms = time.time() * 1000
        plugin.args = args
        cost = time.time() * 1000 - begin_time_ms
        logger.debug('TOTAL COST: {:.4f} ms'.format(cost))


if __name__ == '__main__':
    main()
