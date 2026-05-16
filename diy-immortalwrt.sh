#!/bin/bash
#
# https://github.com/P3TERX/Actions-OpenWrt
# File name: diy-immortalwrt.sh
# Description: OpenWrt DIY script part 2 (After Update feeds)
#
# Copyright (c) 2019-2024 P3TERX <https://p3terx.com>
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#

# Modify default IP
sed -i 's/192.168.1.1/192.168.88.166/g' package/base-files/files/bin/config_generate

# Modify default theme
#sed -i 's/luci-theme-bootstrap/luci-theme-argon/g' feeds/luci/collections/luci/Makefile

# Modify hostname
sed -i 's/ImmortalWrt/Immortal-Router/g' package/base-files/files/bin/config_generate

# 1. 创建 OpenClash 内核的存放目录
mkdir -p files/etc/openclash/core

# 2. 下载 Meta 内核 (x86_64 架构)
wget -qO- https://raw.githubusercontent.com/vernesong/OpenClash/core/master/meta/clash-linux-amd64.tar.gz | tar xOvz > files/etc/openclash/core/clash_meta

# 3. 赋予内核执行权限
chmod +x files/etc/openclash/core/clash*
