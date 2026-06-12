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
# 1. 修改預設 IP 地址
# 作用：將固件預設的後台 IP 從 192.168.1.1 修改為 192.168.88.252。
# =================================================================
sed -i 's/192.168.1.1/192.168.88.252/g' package/base-files/files/bin/config_generate


# =================================================================
# 2. 修改預設主題 (當前註解停用)
# 作用：保留自訂勾選空間，不強制替換預設主題。
# =================================================================
#sed -i 's/luci-theme-bootstrap/luci-theme-argon/g' feeds/luci/collections/luci/Makefile


# =================================================================
# 3. 修改路由器主機名稱 (Hostname)
# 作用：將預設的 "OpenWrt" 主機名稱修改為您專屬的 "xtusrpa-lede"。
# =================================================================
sed -i 's/OpenWrt/xtusrpa-lede/g' package/base-files/files/bin/config_generate


# =================================================================
# 4. 建立 OpenClash 核心存放目錄
# 作用：在編譯環境中提前建立對應的資料夾，以便存放預載的核心。
# =================================================================
mkdir -p files/etc/openclash/core


# =================================================================
# 5. 下載 Meta 核心 (適用於 x86_64 虛擬機)
# 作用：從 OpenClash 官方原始碼庫下載最新的 Meta 核心，
#       解壓並自動重命名為 "clash_meta" 放入對應目錄。
# =================================================================
echo "Downloading Meta Core..."
wget -qO- https://raw.githubusercontent.com/vernesong/OpenClash/core/master/meta/clash-linux-amd64.tar.gz | tar xOvz > files/etc/openclash/core/clash_meta


# =================================================================
# 6. 下載 Premium (TUN) 核心 (適用於 x86_64 虛擬機)
# 作用：下載指定版本的 Premium (TUN) 核心，
#       解壓並自動重命名為 "clash_tun" 放入對應目錄。
# =================================================================
echo "Downloading TUN Core..."
wget -qO- https://raw.githubusercontent.com/vernesong/OpenClash/core/master/premium/clash-linux-amd64-2023.08.17.tar.gz | tar xOvz > files/etc/openclash/core/clash_tun


# =================================================================
# 7. 賦予核心最高執行權限
# 作用：強制為 files/etc/openclash/core/ 目錄下的所有 clash 核心
#       加上可執行權限 (chmod +x)，防止刷機後因權限不足導致外掛無法運作。
# =================================================================
chmod +x files/etc/openclash/core/clash*

# -------------------------------------------------------------------------
# 自定义 LAN 口网关和 DNS
# 作用: 自动生成 uci-defaults 脚本，让系统首次开机时自动配置网关和 DNS
# -------------------------------------------------------------------------

# 创建 uci-defaults 存放目录
mkdir -p files/etc/uci-defaults

# 写入网络配置代码 (EOF 之间的内容会被自动写入 99-custom-network 文件中)
cat << "EOF" > files/etc/uci-defaults/99-custom-network
#!/bin/sh

# 自定义 LAN 口网关 (请根据你的主路由 IP 自行修改)
uci set network.lan.gateway='192.168.88.1'

# 自定义 LAN 口 DNS (可以添加多个)
uci add_list network.lan.dns='202.99.224.68'
uci add_list network.lan.dns='202.99.224.67'
uci add_list network.lan.dns='202.99.224.8'

# 如果你把它作为旁路由，防止和主路由冲突，可以取消下面这行的注释来关闭 DHCP
uci set dhcp.lan.ignore='1' && uci commit dhcp

# 提交保存网络配置
uci commit network

# 执行完毕后删除自身，避免以后每次重启都执行
rm -f /etc/uci-defaults/99-custom-network
exit 0
EOF

# 赋予该脚本可执行权限
chmod +x files/etc/uci-defaults/99-custom-network

# =========================================================
# 手动拉取 MosDNS 和对应的 Geo 数据库源码 (适用于 LEDE)
# =========================================================

# 拉取 MosDNS v5 版本源码
git clone -b v5 https://github.com/sbwml/luci-app-mosdns package/mosdns

# 拉取 v2ray-geodata 数据库（替代原来的 v2ray-geoip/geosite）
git clone https://github.com/sbwml/v2ray-geodata package/v2ray-geodata

# =========================================================
# 1. 强制清理默认的老旧动态 DNS 组件 (luci-app-ddns)，防止冲突
# =========================================================
rm -rf feeds/packages/net/ddns-scripts
rm -rf feeds/luci/applications/luci-app-ddns

# =========================================================
# 2. 从第三方源拉取最新的 luci-app-ddns-go 源码包
# =========================================================
# 这里使用的是社区非常稳定且常用的 sirpdboy 源
git clone https://github.com/sirpdboy/luci-app-ddns-go.git package/ddns-go

# 在 diy-part2.sh 中拉取 AppFilter 源码
git clone https://github.com/destan19/OpenAppFilter.git package/OpenAppFilter
