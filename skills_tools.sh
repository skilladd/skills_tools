#!/bin/bash
# Cloudflare + Nginx + Fail2ban 自动配置脚本
# 功能：使 Nginx 识别真实访客 IP，Fail2ban 通过 Cloudflare API 封禁攻击 IP
# 适用系统：Ubuntu 20.04+ / Debian 11+ / CentOS 7+ (需支持 systemd)
# 作者：Assistant
# 版本：1.0

set -e  # 遇错即停

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 日志函数
log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }

# 检查是否为 root 用户
if [[ $EUID -ne 0 ]]; then
    log_error "请使用 root 用户执行此脚本，或使用 sudo"
fi

# 检测操作系统
detect_os() {
    if [[ -f /etc/os-release ]]; then
        . /etc/os-release
        OS=$ID
        VER=$VERSION_ID
    else
        log_error "无法检测操作系统类型"
    fi
    log_info "检测到操作系统：$OS $VER"
}

# 安装依赖包
install_packages() {
    log_info "正在安装所需软件包 (nginx, fail2ban, curl, jq)..."
    if command -v apt-get &> /dev/null; then
        apt-get update
        apt-get install -y nginx fail2ban curl jq
    elif command -v yum &> /dev/null; then
        yum install -y epel-release
        yum install -y nginx fail2ban curl jq
    else
        log_error "不支持的包管理器，请手动安装 nginx, fail2ban, curl, jq"
    fi
    log_info "软件包安装完成"
}

# 获取 Cloudflare IP 列表并配置 Nginx
configure_nginx() {
    log_info "正在下载 Cloudflare IP 列表..."
    CF_IPV4_URL="https://www.cloudflare.com/ips-v4"
    CF_IPV6_URL="https://www.cloudflare.com/ips-v6"

    CF_IPV4=$(curl -s $CF_IPV4_URL)
    CF_IPV6=$(curl -s $CF_IPV6_URL)

    if [[ -z "$CF_IPV4" && -z "$CF_IPV6" ]]; then
        log_error "下载 Cloudflare IP 列表失败，请检查网络"
    fi

    # 备份原 nginx.conf
    NGINX_CONF="/etc/nginx/nginx.conf"
    if [[ -f "$NGINX_CONF" ]]; then
        cp "$NGINX_CONF" "${NGINX_CONF}.bak.$(date +%Y%m%d%H%M%S)"
        log_info "已备份 nginx.conf"
    fi

    # 在 http 块中添加 set_real_ip_from 和 real_ip_header
    # 首先检查是否已存在相关配置，避免重复添加
    if grep -q "real_ip_header CF-Connecting-IP" "$NGINX_CONF"; then
        log_warn "Nginx 似乎已配置 Cloudflare real_ip，跳过修改"
    else
        log_info "正在配置 Nginx 真实 IP 模块..."
        # 在 http 块开头插入配置（通常 http 块第一行是 http {）
        # 使用 awk 在第一个 http 块之后插入内容
        awk -v ipv4="$CF_IPV4" -v ipv6="$CF_IPV6" '
        /^http\s*{/ {
            print;
            print "    # Cloudflare IP ranges for real_ip_module";
            split(ipv4, arr4, "\n");
            for (i in arr4) if (arr4[i] != "") print "    set_real_ip_from " arr4[i] ";";
            split(ipv6, arr6, "\n");
            for (i in arr6) if (arr6[i] != "") print "    set_real_ip_from " arr6[i] ";";
            print "    real_ip_header CF-Connecting-IP;";
            print "";
            next;
        }
        { print }
        ' "$NGINX_CONF" > "${NGINX_CONF}.tmp" && mv "${NGINX_CONF}.tmp" "$NGINX_CONF"
        log_info "Nginx 配置已更新"
    fi

    # 测试 Nginx 配置
    nginx -t || log_error "Nginx 配置测试失败，请检查配置文件"

    # 重启 Nginx
    systemctl restart nginx
    systemctl enable nginx
    log_info "Nginx 已重启并设为开机自启"
}

# 获取用户输入的 Cloudflare API 凭证
get_cf_credentials() {
    echo -e "${YELLOW}请输入你的 Cloudflare API Token (需要 编辑区域防火墙 权限):${NC}"
    read -p "API Token: " CF_API_TOKEN
    echo
    if [[ -z "$CF_API_TOKEN" ]]; then
        log_error "API Token 不能为空"
    fi

    echo -e "${YELLOW}请输入你的 Cloudflare Zone ID (在域名概述页面右侧):${NC}"
    read -p "Zone ID: " CF_ZONE_ID
    if [[ -z "$CF_ZONE_ID" ]]; then
        log_error "Zone ID 不能为空"
    fi

    # 可选：验证 Token 有效性
    log_info "正在验证 API Token..."
    RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" -X GET "https://api.cloudflare.com/client/v4/zones/$CF_ZONE_ID" \
        -H "Authorization: Bearer $CF_API_TOKEN" \
        -H "Content-Type: application/json")
    if [[ "$RESPONSE" != "200" ]]; then
        log_error "API Token 或 Zone ID 无效，请检查后重新运行脚本"
    else
        log_info "API 凭证验证成功"
    fi
}

# 配置 Fail2ban
configure_fail2ban() {
    log_info "开始配置 Fail2ban..."

    # 创建 action.d/cloudflare.conf
    ACTION_CONF="/etc/fail2ban/action.d/cloudflare.conf"
    if [[ -f "$ACTION_CONF" ]]; then
        cp "$ACTION_CONF" "${ACTION_CONF}.bak"
        log_info "已备份现有 cloudflare.conf"
    fi

    cat > "$ACTION_CONF" <<EOF
[Definition]

actionstart =

actionstop =

actioncheck =

actionban = curl -s -o /dev/null -X POST "https://api.cloudflare.com/client/v4/zones/$CF_ZONE_ID/firewall/access_rules/rules" \\
                -H "Authorization: Bearer $CF_API_TOKEN" \\
                -H "Content-Type: application/json" \\
                --data '{"mode":"block","configuration":{"target":"ip","value":"<ip>"},"notes":"Banned by Fail2ban"}'

actionunban = curl -s -o /dev/null -X DELETE "https://api.cloudflare.com/client/v4/zones/$CF_ZONE_ID/firewall/access_rules/rules?configuration_target=ip&configuration_value=<ip>" \\
                  -H "Authorization: Bearer $CF_API_TOKEN" \\
                  -H "Content-Type: application/json"

[Init]
EOF
    log_info "已创建 Fail2ban Cloudflare 动作定义"

    # 创建过滤器：nginx-req-limit (监控 4xx/5xx 请求)
    FILTER_REQ="/etc/fail2ban/filter.d/nginx-req-limit.conf"
    cat > "$FILTER_REQ" <<'EOF'
[Definition]
failregex = ^<HOST> -.*"(GET|POST|PUT|DELETE|HEAD).*HTTP.*" (400|401|403|404|405|429|444|500|502|503) .*$
ignoreregex =
EOF
    log_info "已创建过滤器 nginx-req-limit"

    # 创建过滤器：nginx-404 (针对大量 404 扫描)
    FILTER_404="/etc/fail2ban/filter.d/nginx-404.conf"
    cat > "$FILTER_404" <<'EOF'
[Definition]
failregex = ^<HOST> -.*"(GET|POST).*HTTP.*" 404 .*$
ignoreregex =
EOF
    log_info "已创建过滤器 nginx-404"

    # 配置 jail.local (如果不存在则创建，否则追加)
    JAIL_LOCAL="/etc/fail2ban/jail.local"
    if [[ ! -f "$JAIL_LOCAL" ]]; then
        touch "$JAIL_LOCAL"
        log_info "创建 jail.local"
    fi

    # 检查是否已存在相关 jail 配置，避免重复
    if grep -q "nginx-req-limit" "$JAIL_LOCAL"; then
        log_warn "jail.local 中已存在 nginx-req-limit 配置，跳过追加"
    else
        cat >> "$JAIL_LOCAL" <<EOF

[nginx-req-limit]
enabled = true
filter = nginx-req-limit
action = cloudflare
         iptables-multiport[name=nginx, port="http,https", protocol=tcp]
logpath = /var/log/nginx/access.log
maxretry = 5
findtime = 60
bantime = 600

[nginx-404]
enabled = true
filter = nginx-404
action = cloudflare
         iptables-multiport[name=nginx-404, port="http,https", protocol=tcp]
logpath = /var/log/nginx/access.log
maxretry = 5
findtime = 60
bantime = 3600
EOF
        log_info "已将监控规则添加到 jail.local"
    fi

    # 可选：设置全局默认配置（忽略自家 IP 等）
    if ! grep -q "ignoreip = " "$JAIL_LOCAL"; then
        echo -e "${YELLOW}请输入你的本地管理 IP (用于白名单，多个 IP 用空格分隔，直接回车跳过):${NC}"
        read -p "IP: " MY_IP
        if [[ -n "$MY_IP" ]]; then
            sed -i "/\[DEFAULT\]/a ignoreip = 127.0.0.1/8 ::1 $MY_IP" "$JAIL_LOCAL"
            log_info "已将 $MY_IP 加入全局白名单"
        fi
    fi

    # 重启 Fail2ban
    systemctl restart fail2ban
    systemctl enable fail2ban
    log_info "Fail2ban 已重启并设为开机自启"
}

# 显示最终状态
show_status() {
    log_info "========== 部署完成 =========="
    log_info "Nginx 配置: 已启用 real_ip 模块，仅信任 Cloudflare IP"
    log_info "Fail2ban 状态:"
    fail2ban-client status
    echo ""
    log_info "你可以使用以下命令查看详细封禁状态:"
    echo "  sudo fail2ban-client status nginx-req-limit"
    echo "  sudo fail2ban-client status nginx-404"
    echo ""
    log_warn "请确保 Cloudflare 域名 SSL/TLS 加密模式设置为“完全（严格）”，否则可能导致回源失败"
    log_info "脚本执行完毕！"
}

# 主函数
main() {
    detect_os
    install_packages
    configure_nginx
    get_cf_credentials
    configure_fail2ban
    show_status
}

# 运行主函数
main
