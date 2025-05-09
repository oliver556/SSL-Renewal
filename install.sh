#!/bin/bash
set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 检查是否为root用户
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}错误：需要 root 权限${NC}"
    echo -e "${YELLOW}请使用以下方式之一运行此脚本：${NC}"
    echo -e "1. ${GREEN}sudo bash <(curl -fsSL https://raw.githubusercontent.com/oliver556/SSL-Renewal/main/install.sh)${NC}"
    echo -e "2. ${GREEN}su root${NC}"
    echo -e "   ${GREEN}bash <(curl -fsSL https://raw.githubusercontent.com/oliver556/SSL-Renewal/main/install.sh)${NC}"
    exit 1
fi

# 检查并安装必要的依赖
install_dependencies() {
    echo -e "${GREEN}正在检查并安装必要的依赖...${NC}"
    
    # 检查系统类型
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS=$ID
    else
        echo -e "${RED}无法识别操作系统，请手动安装依赖。${NC}"
        exit 1
    fi

    case $OS in
        ubuntu|debian)
            apt update -y
            apt install -y curl socat git cron
            ;;
        centos)
            yum update -y
            yum install -y curl socat git cronie
            systemctl start crond
            systemctl enable crond
            ;;
        *)
            echo -e "${RED}不支持的操作系统：$OS${NC}"
            exit 1
            ;;
    esac
}

# 安装acme.sh
install_acme() {
    echo -e "${GREEN}正在安装 acme.sh...${NC}"
    if ! command -v acme.sh >/dev/null 2>&1; then
        curl https://get.acme.sh | sh
        export PATH="$HOME/.acme.sh:$PATH"
        ~/.acme.sh/acme.sh --upgrade
    fi
}

# 创建必要的目录
setup_directories() {
    echo -e "${GREEN}正在创建必要的目录...${NC}"
    mkdir -p /etc/ssl/{certs,private,domains}
    chmod 755 /etc/ssl/certs
    chmod 700 /etc/ssl/private
    chmod 755 /etc/ssl/domains
}

# 复制主脚本
copy_main_script() {
    echo -e "${GREEN}正在安装主脚本...${NC}"
    cp ssl-manager /usr/local/bin/ssl-manager
    chmod +x /usr/local/bin/ssl-manager
}

# 主安装流程
echo -e "${GREEN}开始安装 SSL 证书管理工具...${NC}"
install_dependencies
install_acme
setup_directories
copy_main_script

echo -e "${GREEN}安装完成！${NC}"
echo -e "现在你可以通过运行 ${YELLOW}ssl-manager${NC} 来管理 SSL 证书" 