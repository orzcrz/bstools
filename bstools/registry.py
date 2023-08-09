#!/usr/bin/env python
# -*- encoding: utf-8 -*-

"""
Created by crzorz on 2022/09/15
Copyright © 2022 BaldStudio. All rights reserved.
"""

from bstools.plugins.clean_mac import CleanMac
from bstools.plugins.symbol_parser import SymbolParser
from bstools.plugins.publish_pod import PublishPod

PLUGINS = [
	CleanMac,
	SymbolParser,
	PublishPod,
]
