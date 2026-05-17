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
# 1. 取消注释默认的 helloworld 源 (当前被注释)
# 作用：大雕的 LEDE 源码里自带了 helloworld 源，但默认是被 '#' 注释掉的。
# 删掉行首的 '#' 就可以激活它。
# =================================================================
#sed -i 's/^#\(.*helloworld\)/\1/' feeds.conf.default


# =================================================================
# 2. 追加 helloworld 软件源 (当前生效)
# 作用：强行向源列表里写入 helloworld 的仓库地址。
# 结果：你能在编译菜单 (make menuconfig) 里找到并安装 "luci-app-ssr-plus" 插件。
# =================================================================
echo 'src-git helloworld https://github.com/fw876/helloworld' >>feeds.conf.default


# =================================================================
# 3. 追加 Passwall 软件源 (当前被注释)
# 作用：引入著名科学插件 Passwall 的源码。因为行首有 '#'，所以不会生效。
# 如果你想用 Passwall，可以把这行最前面的 '#' 删掉。
# =================================================================
#echo 'src-git passwall https://github.com/xiaorouji/openwrt-passwall' >>feeds.conf.default


# 追加 OpenClash 软件源 后面出问题可用井号注释掉
echo 'src-git openclash https://github.com/vernesong/OpenClash.git' >>feeds.conf.default