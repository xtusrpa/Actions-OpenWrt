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
# 作用：將固件預設的後台 IP 從 192.168.1.1 修改為 192.168.88.166。
# =================================================================
sed -i 's/192.168.1.1/192.168.88.166/g' package/base-files/files/bin/config_generate


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
