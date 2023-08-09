#!/usr/bin/env python
# -*- encoding: utf-8 -*-

"""
Created by changrunze on 2023/6/1
Copyright © 2023 BaldStudio. All rights reserved.
"""

import re
import subprocess
import tempfile

from typing import AnyStr
from bstools import GIT
from bstools.misc.logging import logger
from bstools.misc.file import *
from bstools.misc.loader import Loader


def is_git_repo(verbose) -> AnyStr:
    cmd = [
        GIT, 'rev-parse', '--is-inside-work-tree'
    ]
    logger.debug('Running: %r', cmd)
    if verbose:
        return subprocess.check_output(cmd).decode()
    process = subprocess.Popen(cmd,
                               stdout=subprocess.PIPE,
                               stderr=subprocess.PIPE,
                               universal_newlines=True)
    return str(process.communicate()[0].strip())


def is_git_tag_exist(verbose, tag: str) -> bool:
    cmd = [
        GIT, 'tag', '-l', tag
    ]
    logger.debug('Running: %r', cmd)
    if verbose:
        return tag == subprocess.check_output(cmd).decode()
    process = subprocess.Popen(cmd,
                               stdout=subprocess.PIPE,
                               stderr=subprocess.PIPE,
                               universal_newlines=True)
    return tag == process.communicate()[0].strip()


def git_force_fetch():
    cmd = [
        GIT, 'fetch', '-f', '--tag'
    ]
    logger.debug('Running: %r', cmd)
    subprocess.check_output(cmd)


# 检查 git 是否有改动
def git_has_any_changed():
    cmd = [
        GIT, 'status', '--porcelain',
    ]
    logger.debug('Running: %r', cmd)
    result = subprocess.check_output(cmd)
    return bool(result.decode())


def preflight(args):
    if len(is_git_repo(args.verbose)) == 0:
        logger.error('not a git repository (or any of the parent directories): .git')
        return False
    if not any(name.endswith('.podspec') for name in os.listdir(os.getcwd())):
        logger.error('找不到 podspec 文件')
        return False
    if git_has_any_changed():
        logger.error('local git repository must be clean')
        return False
    git_force_fetch()
    return True


def postflight():
    logger.info('🎉 发布成功')


# 查找 cocoapods 源码路径
def find_cocoapods_dir():
    gem_path = os.path.join(shutil.which('pod'), '../../gems')
    logger.debug('🩹 gems path %s' % gem_path)
    pattern = re.compile(r'^cocoapods-(\d+)(.+)')
    gem_dirs = os.listdir(gem_path)
    for n in gem_dirs:
        if pattern.search(n):
            cocoapods_dir = os.path.join(gem_path, n)
            logger.debug('🩹 cocoapods path %s' % cocoapods_dir)
            return cocoapods_dir


# 查找补丁对应的cocoapods源文件
def find_cocoapods_file(cocoapods_dir, target_file, base_name):
    for root, _, files in os.walk(cocoapods_dir):
        for f in files:
            # 为了避免找到不同路径下的同名文件，增加上级目录的比较
            if f == target_file and os.path.basename(root) == base_name:
                return os.path.join(root, f)


# 打入cocoapods补丁
def try_patched_pod():
    cocoapods_dir = find_cocoapods_dir()
    if not cocoapods_dir:
        logger.error('cocoapods path is not found')
        return
    patch_dir = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'cocoapods_patch')
    for root, _, files in os.walk(patch_dir):
        for f in files:
            if f.endswith('.rb'):
                src_file = os.path.join(root, f)
                logger.debug('🩹 找到补丁文件 %s' % src_file)

                # 找到对应文件替换
                dst_file = find_cocoapods_file(os.path.join(cocoapods_dir, 'lib'),
                                               f,
                                               os.path.basename(root))
                if not dst_file:
                    logger.warn('未找到补丁对应的源文件')
                    continue
                symlink_force(src_file, os.path.abspath(dst_file))
                logger.info('🩹 替换文件 %s' % f)


# 更新 podspec 版本号
def update_podspec(version):
    podspec_file = os.path.basename(os.getcwd()) + '.podspec'
    logger.debug('当前podspec文件：%s', podspec_file)
    temp_dir = tempfile.mkdtemp()
    podspec_temp_file = os.path.join(temp_dir, podspec_file)
    logger.debug('修改版本号为 %s', version)
    pattern = re.compile(r'(s.version)(\s*)=(\s*)[\'|\"](.*)[\'|\"]')
    with open(podspec_file, 'r') as f1, open(podspec_temp_file, 'w') as f2:
        for line in f1:
            line = re.sub(pattern, 's.version      = \'%s\'' % version, line)
            f2.write(line)
    logger.debug(subprocess.check_output(['cat', podspec_temp_file]).decode())
    return podspec_temp_file


def push_pod_repo(podspec_file):
    logger.debug('发布podspec')
    pod = shutil.which('pod')
    cmd = [
        pod, 'repo', 'push', 'kami-vision', podspec_file,
        '--allow-warnings',
        '--force',
    ]
    logger.debug('Running: %r', cmd)
    subprocess.check_output(cmd)


class PublishPod:
    def __init__(self):
        self._args_parser = None
        self._args = None
        self._loading = None

    @property
    def name(self):
        return 'publish'

    @property
    def version(self):
        return '1.0.0'

    @property
    def help(self):
        return 'kam publish'

    @property
    def description(self):
        return '发布私有Pod的工具，支持SNAPSHOT版本'

    @property
    def args_parser(self):
        return self._args_parser

    @args_parser.setter
    def args_parser(self, parser):
        self._args_parser = parser
        parser.add_argument('--pod-patch',
                            action='store_true',
                            default=False,
                            help='使用pod补丁，增加 pod repo push --force的命令')
        parser.add_argument('-s', '--snapshot', type=str, help='发布 SNAPSHOT 版')
        parser.add_argument('--release', type=str, help='发布正式版')

    @property
    def args(self):
        return self._args

    @args.setter
    def args(self, args):
        self._args = args
        if args.pod_patch:
            try_patched_pod()
            return
        env = 'RELEASE' if args.release else 'SNAPSHOT'
        logger.info('📌 确认发布环境 [ %s ]' % env)
        if not preflight(args):
            logger.error('操作已终止')
            return
        if args.release:
            self.publish_release(args)
            return
        if args.snapshot:
            self.publish_snapshot(args)
            return
        self._args_parser.print_help()

    def publish_snapshot(self, args):
        version = args.snapshot + '-SNAPSHOT'
        logger.info('🍙 准备发布快照版本 %s' % version)
        self.begin_loading()
        cmd = [
            GIT, 'tag', '-af', version, '-m', 'v%s' % version
        ]
        logger.debug('Running: %r', cmd)
        subprocess.check_output(cmd)
        push = [
            GIT, 'push', 'origin', '-f', version,
        ]
        self.push_remote(push, version)

    def publish_release(self, args):
        version = args.release
        logger.info('🍘 准备发布正式版本 %s' % version)
        if is_git_tag_exist(args.verbose, version):
            logger.error('版本号 %s 已存在', version)
            return
        self.begin_loading()
        cmd = [
            GIT, 'tag', '-a', version, '-m', 'v%s' % version
        ]
        logger.debug('Running: %r', cmd)
        subprocess.check_output(cmd)
        push = [
            GIT, 'push', 'origin', version
        ]
        self.push_remote(push, version)

    def push_remote(self, push, version):
        logger.debug('Running: %r', push)
        if self.args.verbose:
            subprocess.check_output(push)
        else:
            subprocess.check_call(push, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        podspec_file = update_podspec(version)
        push_pod_repo(podspec_file)
        self.end_loading()
        postflight()

    def begin_loading(self):
        self._loading = Loader('☕️ 正在发布...', '', 0.05).start()

    def end_loading(self):
        self._loading.stop()
