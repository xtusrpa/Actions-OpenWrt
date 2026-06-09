#!/bin/bash
#
# https://github.com/P3TERX/Actions-OpenWrt
# 文件名: diy-immortalwrt.sh
# 描述: OpenWrt/ImmortalWrt DIY 自定义脚本第二部分 (在更新和安装 feeds 软件包之后执行)
#
# 版权所有 (c) 2019-2024 P3TERX <https://p3terx.com>
#
# 本软件是自由软件，遵循 MIT 开源协议。
# 详情请参阅 /LICENSE 文件。
#

# 修改默认后台管理 IP 地址
# 作用: 编译出的固件刷入机器后，默认访问后台的 IP 就是 192.168.88.166
sed -i 's/192.168.1.1/192.168.88.252/g' package/base-files/files/bin/config_generate

# 修改默认界面主题 (目前处于被注释关闭状态)
# 作用: 默认的主题是 bootstrap，如果去掉开头的 # 号，默认主题将变为漂亮的 argon 主题
#sed -i 's/luci-theme-bootstrap/luci-theme-argon/g' feeds/luci/collections/luci/Makefile

# 修改系统主机名 (路由器名称)
# 作用: 将系统默认显示的 "ImmortalWrt" 替换为指定的 "xtusrpa-immortalwrt"
sed -i 's/ImmortalWrt/xtusrpa-immortalwrt/g' package/base-files/files/bin/config_generate

# -------------------------------------------------------------------------
# 以下操作用于在编译阶段提前预置 OpenClash 的核心文件 (Core)
# 这样刷机后就不用再手动连接 GitHub 下载内核了，直接可用，避免因为网络问题导致插件无法启动
# -------------------------------------------------------------------------

# 1. 创建预置 OpenClash 内核的专属本地存放目录
# 作用: 在源码目录中创建 files 文件夹（编译时这个目录下的文件会被直接原样塞进固件系统的根目录下）
mkdir -p files/etc/openclash/core

# 2. 下载 Meta 内核
# 作用: 从官方核心库下载 amd64 (x86_64) 架构的 Meta 内核压缩包，直接解压并将核心文件提取重命名为 clash_meta，放入刚才创建的预置目录
echo "正在下载 OpenClash Meta 内核..."
wget -qO- https://raw.githubusercontent.com/vernesong/OpenClash/core/master/meta/clash-linux-amd64.tar.gz | tar xOvz > files/etc/openclash/core/clash_meta

# 3. 下载 Premium (TUN) 内核
# 作用: 从官方核心库下载用于接管全局流量的 TUN 闭源内核，解压并将核心文件提取重命名为 clash_tun，同样放入预置目录
echo "正在下载 OpenClash TUN 内核..."
wget -qO- https://raw.githubusercontent.com/vernesong/OpenClash/core/master/premium/clash-linux-amd64-2023.08.17.tar.gz | tar xOvz > files/etc/openclash/core/clash_tun

# 4. 赋予内核文件可执行权限
# 作用: 给所有存入预置目录且名字以 clash 开头的文件赋予最高执行权限 (+x)，确保路由器开机后插件可以直接调用内核运行
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

# -------------------------------------------------------------------------
# 拉取 MosDNS v5 及 v2ray-geodata 依赖源码
# 作用: 确保编译阶段能找到 MosDNS 及其运行所需的地理位置数据
# -------------------------------------------------------------------------
git clone https://github.com/sbwml/luci-app-mosdns -b v5 package/mosdns
git clone https://github.com/sbwml/v2ray-geodata package/v2ray-geodata
