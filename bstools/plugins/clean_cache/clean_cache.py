#!/usr/bin/env python
# -*- encoding: utf-8 -*-

"""
Created by crzorz on 2022/09/15
Copyright © 2022 BaldStudio. All rights reserved.
"""

import os
import shutil
import subprocess

from bstools.utils.logger import logger

class CleanCache:  
  
  def __init__(self):
    self.free_disk_memory = 0
  
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

    logger.info('🔍 开始清理')

    self.clean_pods_cache()    
    self.clean_document_pods()
    self.clean_xcode_cache()
    
    logger.info("✅ 清理完成，释放 {} 磁盘空间".format(self.format_size(self.free_disk_memory)))

    
  def format_size(self, num, suffix='B'):
    for unit in ['','K','M','G','T','P','E','Z']:
        if abs(num) < 1024.0:
            return "%3.1f %s%s" % (num, unit, suffix)
        num /= 1024.0
    return "%.1f %s%s" % (num, 'Y', suffix)

  
  def sizeof_directory(self, dir):
    return float(subprocess.check_output("du -d 0 '{}' | awk '{{print $1}}'".format(dir), shell=True)) * 512
  
  
  ## 清空目录下的所有内容，保留目录
  def clear_directory(self, dir_path):
    dirs = os.listdir(dir_path)
    for f in dirs:
      file_path = os.path.join(dir_path, f)
      if os.path.isfile(file_path):
        os.remove(file_path)
      elif os.path.isdir(file_path):
        shutil.rmtree(file_path)
  
  
  ## 清理 pod 缓存
  def clean_pods_cache(self):
    pod_cache_path = os.path.expanduser('~/Library/Caches/CocoaPods/Pods/')
    logger.info('清理Pods缓存')
    if os.path.exists(pod_cache_path):
      self.free_disk_memory += self.sizeof_directory(pod_cache_path)
      self.clear_directory(pod_cache_path)

      
  ## 清理Documents下，Xcode工程中的Pods目录
  def clean_document_pods(self):
    logger.info('清理Documents中的Pods目录')
    doc_dir = os.path.expanduser('~/Documents')
    includes = [ 'Pods' ]
    for root, dirs, files in os.walk(doc_dir):
      if not os.path.basename(root) in includes:
        continue
      logger.debug('清理 %s' % root)
      self.free_disk_memory += self.sizeof_directory(root)
      shutil.rmtree(root)

  
  ## 清理Xcode缓存
  def clean_xcode_cache(self):
    logger.info('清理Xcode缓存')
    xcode_data_dir = os.path.expanduser('~/Library/Developer/Xcode/')
    
    derived_data_path = os.path.join(xcode_data_dir, 'DerivedData')
    if os.path.exists(derived_data_path):
      logger.debug('清理Xcode缓存 :: DerivedData')
      self.free_disk_memory += self.sizeof_directory(derived_data_path)
      self.clear_directory(derived_data_path)
    
    ios_support_path = os.path.join(xcode_data_dir, 'iOS DeviceSupport')
    if os.path.exists(ios_support_path):
      logger.debug('清理Xcode缓存 :: iOS DeviceSupport')
      self.free_disk_memory += self.sizeof_directory(ios_support_path)
      self.clear_directory(ios_support_path)

    macos_support_path = os.path.join(xcode_data_dir, 'macOS DeviceSupport')
    if os.path.exists(macos_support_path):
      logger.debug('清理Xcode缓存 :: macOS DeviceSupport')
      self.free_disk_memory += self.sizeof_directory(macos_support_path)
      self.clear_directory(macos_support_path)

    archives_path = os.path.join(xcode_data_dir, 'Archives')
    if os.path.exists(archives_path):
      logger.debug('清理Xcode缓存 :: Archives')
      self.free_disk_memory += self.sizeof_directory(archives_path)
      self.clear_directory(archives_path)
      
    products_path = os.path.join(xcode_data_dir, 'Products')
    if os.path.exists(products_path):
      logger.debug('清理Xcode缓存 :: Products')
      self.free_disk_memory += self.sizeof_directory(products_path)
      self.clear_directory(products_path)