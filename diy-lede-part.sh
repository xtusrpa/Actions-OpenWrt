#!/bin/bash
#
# https://github.com/P3TERX/Actions-OpenWrt
# File name: diy-part1.sh
# Description: OpenWrt DIY script part 1 (Before Update feeds)
#
# Copyright (c) 2019-2024 P3TERX <https://p3terx.com>
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#

# =================================================================
# 1. 剔除不用且容易冲突的 helloworld (SSR-Plus)
# =================================================================
#sed -i 's/^#\(.*helloworld\)/\1/' feeds.conf.default
#echo 'src-git helloworld https://github.com/fw876/helloworld' >>feeds.conf.default

# =================================================================
# 2. 追加 OpenClash 官方源 (核心代理)
# =================================================================
echo 'src-git openclash https://github.com/vernesong/OpenClash.git' >>feeds.conf.default

# =================================================================
# 3. 追加 MosDNS 和其他常用极客插件包的综合源 (kenzok8/small)
# 作用：提供最新的 MosDNS、网易云解锁等 Lean 源码里缺失的插件
# =================================================================
echo 'src-git smpackage https://github.com/kenzok8/small-package' >>feeds.conf.default
