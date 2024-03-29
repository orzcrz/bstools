#!/usr/bin/env python
# -*- encoding: utf-8 -*-

"""
Created by crzorz on 2022/09/27
Copyright © 2022 BaldStudio. All rights reserved.
"""

import os
import sys
import subprocess
import fnmatch

from bstools.misc.logging import logger

DEVELOPER_DIR = subprocess.getoutput('xcode-select --print-path')
XCODE_CONTENT_DIR = os.path.dirname(DEVELOPER_DIR)
CRASH_TOOL_DIR = os.path.join(XCODE_CONTENT_DIR, 'SharedFrameworks/DVTFoundation.framework/Versions/A/Resources')

IPS_TOOL_DIR = os.path.join(XCODE_CONTENT_DIR, 'SharedFrameworks/CoreSymbolicationDT.framework/Versions/A/Resources')
sys.path.append(IPS_TOOL_DIR)

XC_ENVIRON = os.environ.copy()
XC_ENVIRON['DEVELOPER_DIR'] = DEVELOPER_DIR


class SymbolParser:

    def __init__(self):
        self._args_parser = None
        self._args = None

    @property
    def name(self):
        return 'dsym'

    @property
    def version(self):
        return '1.0.0'

    @property
    def help(self):
        return 'bs dsym -p "PATH/to/file"'

    @property
    def description(self):
        return '利用Xcode自带的工具解析crash、ips文件'

    @property
    def args_parser(self):
        return self._args_parser

    @args_parser.setter
    def args_parser(self, parser):
        self._args_parser = parser
        parser.add_argument('-d', '--dsym-path',
                            help='指定符号文件的完整路径, 默认在待解析文件同目录下寻找，使用找到的第一个".app.dSYM"文件')
        parser.add_argument('-p', '--parse',
                            help='指定需要解析的crash/ips文件完整路径')
        parser.add_argument('-o', '--output',
                            help='指定重新符号化文件的输出路径，默认和待解析文件同目录')
        parser.add_argument('-u', '--uuid',
                            help='指定dSYM文件路径，查看对应的UUID')

    @property
    def args(self):
        return self._args

    @args.setter
    def args(self, args):
        self._args = args
        # 输出dSYM文件的UUID
        if args.uuid:
            self._get_uuid(args.uuid)
            return

        if not args.parse:
            self.args_parser.print_help()
            return
        ext = os.path.splitext(args.parse)[-1]
        output = args.output
        if not output:
            logger.debug('未指定output，将自动设置')
            output = os.path.join(os.path.dirname(args.parse), 'output%s' % ext)
            logger.debug('输出文件路径为 %s' % output)

        dsym_path = args.dsym_path
        if not dsym_path:
            logger.debug('未指定dSYM，将自动寻找')
            search_dir = os.path.dirname(args.parse)
            matches = fnmatch.filter(os.listdir(search_dir), '*.app.dSYM')
            if not matches:
                logger.error('No dSYM files found in %s' % search_dir)
                return
            dsym_path = os.path.join(search_dir, matches[0])
            logger.debug('找到dSYM文件 %s' % dsym_path)

        if ext == '.crash':
            self._parse_crash(dsym_path, args.parse, output)
        elif ext == '.ips':
            self._parse_ips(dsym_path, args.parse, output)
        else:
            logger.error('Unknown ext: %s', ext)

    @staticmethod
    def _parse_crash(dsym_path, file, output):
        cmd = [os.path.join(CRASH_TOOL_DIR, 'symbolicatecrash'), file, dsym_path]
        logger.debug('Running: %r', cmd)
        logger.debug('Output File: %s', output)
        subprocess.check_call(cmd, stdout=open(output, 'w'), env=XC_ENVIRON)

    @staticmethod
    def _parse_ips(dsym_path, file, output):
        cmd = [
            'python', os.path.join(IPS_TOOL_DIR, 'CrashSymbolicator.py'),
            '-d', dsym_path,
            '-o', output,
            '-p', file
        ]
        logger.debug('Running: %r', cmd)
        subprocess.check_call(cmd)

    @staticmethod
    def _get_uuid(file):
        cmd = ['dwarfdump', '-u', file]
        logger.debug('Running: %r', cmd)
        subprocess.check_call(cmd)
