#!/usr/bin/env python
# -*- encoding: utf-8 -*-

"""
Created by crzorz on 2022/09/15
Copyright © 2022 BaldStudio. All rights reserved.
"""

import os
import shutil
import subprocess

from bstools.utils.logging import logger


class CleanMac:

	def __init__(self):
		self._args_parser = None
		self._args = None
		self._free_disk_memory = 0

	@property
	def name(self):
		return 'clean'

	@property
	def version(self):
		return '1.0.0'

	@property
	def help(self):
		return 'bs clean'

	@property
	def description(self):
		return '清理缓存文件, 释放mac的硬盘空间'

	@property
	def args_parser(self):
		return self._args_parser

	@args_parser.setter
	def args_parser(self, parser):
		self._args_parser = parser
		parser.add_argument('-x', '--xcode', default=True, help='清理Xcode常见的缓存')
		parser.add_argument('-p', '--pod', default=True, help='清理Cocoapods常见的缓存')

	@property
	def args(self):
		return self._args

	@args.setter
	def args(self, args):
		self._args = args
		logger.info('🔍 开始清理')
		if args.pod:
			self._clean_pods_cache()
			self._clean_document_pods()
		if args.xcode:
			self._clean_xcode_cache()
		logger.info("✅ 清理完成，释放 {} 磁盘空间".format(self._format_size(self._free_disk_memory)))

	@staticmethod
	def _format_size(num, suffix='B'):
		for unit in ['', 'K', 'M', 'G', 'T', 'P', 'E', 'Z']:
			if abs(num) < 1024.0:
				return "%3.1f %s%s" % (num, unit, suffix)
			num /= 1024.0
		return "%.1f %s%s" % (num, 'Y', suffix)

	@staticmethod
	def _sizeof_directory(path):
		return float(subprocess.check_output("du -d 0 '{}' | awk '{{print $1}}'".format(path), shell=True)) * 512

	# 清空目录下的所有内容，保留目录
	@staticmethod
	def _clear_directory(path):
		dirs = os.listdir(path)
		for f in dirs:
			file_path = os.path.join(path, f)
			if os.path.isfile(file_path):
				os.remove(file_path)
			elif os.path.isdir(file_path):
				shutil.rmtree(file_path)

	# 清理 pod 缓存
	def _clean_pods_cache(self):
		pod_cache_path = os.path.expanduser('~/Library/Caches/CocoaPods/Pods/')
		logger.info('清理Pods缓存')
		if os.path.exists(pod_cache_path):
			self._free_disk_memory += self._sizeof_directory(pod_cache_path)
			self._clear_directory(pod_cache_path)

	# 清理Documents下，Xcode工程中的Pods目录
	def _clean_document_pods(self):
		logger.info('清理Documents中的Pods目录')
		doc_dir = os.path.expanduser('~/Documents')
		includes = ['Pods']
		for root, dirs, files in os.walk(doc_dir):
			if not os.path.basename(root) in includes:
				continue
			logger.debug('清理 %s' % root)
			self._free_disk_memory += self._sizeof_directory(root)
			shutil.rmtree(root)

	# 清理Xcode缓存
	def _clean_xcode_cache(self):
		logger.info('清理Xcode缓存')
		xcode_data_dir = os.path.expanduser('~/Library/Developer/Xcode/')

		derived_data_path = os.path.join(xcode_data_dir, 'DerivedData')
		if os.path.exists(derived_data_path):
			logger.debug('清理Xcode缓存 :: DerivedData')
			self._free_disk_memory += self._sizeof_directory(derived_data_path)
			self._clear_directory(derived_data_path)

		ios_support_path = os.path.join(xcode_data_dir, 'iOS DeviceSupport')
		if os.path.exists(ios_support_path):
			logger.debug('清理Xcode缓存 :: iOS DeviceSupport')
			self._free_disk_memory += self._sizeof_directory(ios_support_path)
			self._clear_directory(ios_support_path)

		macos_support_path = os.path.join(xcode_data_dir, 'macOS DeviceSupport')
		if os.path.exists(macos_support_path):
			logger.debug('清理Xcode缓存 :: macOS DeviceSupport')
			self._free_disk_memory += self._sizeof_directory(macos_support_path)
			self._clear_directory(macos_support_path)

		archives_path = os.path.join(xcode_data_dir, 'Archives')
		if os.path.exists(archives_path):
			logger.debug('清理Xcode缓存 :: Archives')
			self._free_disk_memory += self._sizeof_directory(archives_path)
			self._clear_directory(archives_path)

		products_path = os.path.join(xcode_data_dir, 'Products')
		if os.path.exists(products_path):
			logger.debug('清理Xcode缓存 :: Products')
			self._free_disk_memory += self._sizeof_directory(products_path)
			self._clear_directory(products_path)
