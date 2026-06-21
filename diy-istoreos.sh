#!/bin/bash
#
# iStoreOS DIY Script Part 2 (After Update feeds)

# =================================================================
# 创建 uci-defaults 目录
# =================================================================
mkdir -p files/etc/uci-defaults

# =================================================================
# 1. 主机名称设置
# =================================================================
cat << "EOF" > files/etc/uci-defaults/99-custom-settings
#!/bin/sh
uci set system.@system[0].hostname='xtusrpa-IStoreos'
uci commit system
exit 0
EOF
chmod +x files/etc/uci-defaults/99-custom-settings

# =================================================================
# 2. 网络配置（帝王级旁路由配置）
# =================================================================
cat << "EOF" > files/etc/uci-defaults/99-custom-network
#!/bin/sh
# 强制静态 IP 配置
uci set network.lan.proto='static'
uci set network.lan.ipaddr='192.168.88.252'
uci set network.lan.netmask='255.255.255.0'
uci set network.lan.gateway='192.168.88.1'

# DNS 设置
uci -q delete network.lan.dns
uci add_list network.lan.dns='202.99.224.68'
uci add_list network.lan.dns='202.99.224.67'
uci add_list network.lan.dns='202.99.224.8'

# 关闭 LAN DHCP（旁路由模式）
uci set dhcp.lan.ignore='1'
uci commit dhcp

uci commit network

# 自删除，防止重复执行
rm -f /etc/uci-defaults/99-custom-network
exit 0
EOF
chmod +x files/etc/uci-defaults/99-custom-network

echo "✅ 自定义 uci-defaults 文件创建并赋予权限完成"
