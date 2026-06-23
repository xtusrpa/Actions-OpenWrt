#!/bin/bash
# iStoreOS DIY Script Part 2

# =================================================================
# 1. 预设系统配置 (uci-defaults 注入机制)
# =================================================================
mkdir -p files/etc/uci-defaults

# --- 主机名 ---
cat << "EOF" > files/etc/uci-defaults/99-custom-settings
#!/bin/sh
uci set system.@system[0].hostname='xtusrpa-IStoreos'
uci commit system
exit 0
EOF
chmod +x files/etc/uci-defaults/99-custom-settings

# --- 帝王级旁路由网络配置 ---
cat << "EOF" > files/etc/uci-defaults/99-custom-network
#!/bin/sh
# 强制静态 IP
uci set network.lan.proto='static'
uci set network.lan.ipaddr='192.168.88.252'
uci set network.lan.netmask='255.255.255.0'
uci set network.lan.gateway='192.168.88.1'

# 本机初始化DNS
uci -q delete network.lan.dns
uci add_list network.lan.dns='202.99.224.68'
uci add_list network.lan.dns='202.99.224.67'
uci add_list network.lan.dns='202.99.224.8'

# 关闭 IPv4 DHCP
uci set dhcp.lan.ignore='1'

# 【极其关键】彻底阉割 odhcpd 的 IPv6 路由宣告能力
uci set dhcp.lan.ra='disabled'
uci set dhcp.lan.dhcpv6='disabled'
uci set dhcp.lan.ndp='disabled'

uci commit dhcp
uci commit network
exit 0
EOF
chmod +x files/etc/uci-defaults/99-custom-network

echo "✅ 自定义 uci-defaults 注入完毕"


# =================================================================
# 2. 第三方应用包拉取 (App Clones)
# =================================================================

# 解锁网易云灰色歌曲 UI
git clone https://github.com/UnblockNeteaseMusic/luci-app-unblockneteasemusic.git package/luci-app-unblockneteasemusic

# AdGuard Home Web管理界面 (呼应 .config)
git clone https://github.com/kongfl888/luci-app-adguardhome.git package/luci-app-adguardhome


# =================================================================
# 3. 核心驱动强行注入 (Files Overlay)
# =================================================================

# OpenClash Meta内核预置 (利用 files 机制100%稳妥映射)
mkdir -p files/etc/openclash/core

# 加上 -k 参数防止部分编译机本地 SSL 证书旧导致 raw.github 拒绝连接
wget -qO- -k https://raw.githubusercontent.com/vernesong/OpenClash/core/master/meta/clash-linux-amd64.tar.gz | tar xOvz > files/etc/openclash/core/clash_meta

chmod +x files/etc/openclash/core/clash_meta

echo "✅ 核心二进制文件注入完毕"
