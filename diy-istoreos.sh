#!/bin/bash
#
# https://github.com/P3TERX/Actions-OpenWrt
# File name: diy-lede.sh
# Description: OpenWrt DIY script part 2 (After Update feeds)
#
# Copyright (c) 2019-2024 P3TERX <https://p3terx.com>
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#

# =================================================================
# 1. 修改预设 IP 地址（已废弃，由下方的 uci-defaults 强行接管）
# =================================================================
# sed -i 's/192.168.1.1/192.168.88.252/g' package/base-files/files/bin/config_generate


# =================================================================
# 2. 修改预设主题 (当前注解停用)
# =================================================================
#sed -i 's/luci-theme-bootstrap/luci-theme-argon/g' feeds/luci/collections/luci/Makefile


# =================================================================
# 3. 修改路由器主机名称 (Hostname)
# =================================================================
sed -i 's/OpenWrt/xtusrpa-IStoreos/g' package/base-files/files/bin/config_generate


# =================================================================
# 4. 建立 OpenClash 核心存放目录
# =================================================================
mkdir -p files/etc/openclash/core


# =================================================================
# 5. 下载 Meta 核心 (适用于 x86_64 虚拟机)
# =================================================================
echo "Downloading Meta Core..."
wget -qO- https://raw.githubusercontent.com/vernesong/OpenClash/core/master/meta/clash-linux-amd64.tar.gz | tar xOvz > files/etc/openclash/core/clash_meta


# =================================================================
# 6. 下载 Premium (TUN) 核心 (适用于 x86_64 虚拟机)
# =================================================================
echo "Downloading TUN Core..."
wget -qO- https://raw.githubusercontent.com/vernesong/OpenClash/core/master/premium/clash-linux-amd64-2023.08.17.tar.gz | tar xOvz > files/etc/openclash/core/clash_tun


# =================================================================
# 7. 赋予核心最高执行权限
# =================================================================
chmod +x files/etc/openclash/core/clash*


# =================================================================
# 8. 终极网络基建：开机强制接管 LAN 口全部配置（帝王级写法）
# =================================================================
mkdir -p files/etc/uci-defaults

cat << "EOF" > files/etc/uci-defaults/99-custom-network
#!/bin/sh

# 1. 枪毙动态获取！强制将 LAN 口设置为“静态 (static)”模式
uci set network.lan.proto='static'

# 2. 郑重锁死固定 IP 和子网掩码
uci set network.lan.ipaddr='192.168.88.252'
uci set network.lan.netmask='255.255.255.0'

# 3. 写入上级网关
uci set network.lan.gateway='192.168.88.1'

# 4. 写入 DNS
uci add_list network.lan.dns='202.99.224.68'
uci add_list network.lan.dns='202.99.224.67'
uci add_list network.lan.dns='202.99.224.8'

# 5. 作为旁路由使用时，关闭自身的 DHCP 服务，防止脑裂冲突
uci set dhcp.lan.ignore='1' && uci commit dhcp

# 提交保存全部网络配置
uci commit network

# 功成身退：执行完毕后删除自身，防止以后每次重启软路由都执行
rm -f /etc/uci-defaults/99-custom-network
exit 0
EOF

chmod +x files/etc/uci-defaults/99-custom-network
