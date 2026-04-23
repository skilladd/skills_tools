#!/bin/bash

# ------------- 主函数 -------------
main_menu() {
    while true; do
        clear
        echo -e "${PINK}"
        echo "===================================================================================================="
        echo "     ██        ██            ██        ██              ██                       ██                   "
        echo "     ██        ██         ██           ██  ██          ██                       ████████             "
        echo "     ██        ██      ██       ██     ████            ██                       ██                   "
        echo " ████████  ██████████  ████████████  ████        ██  ██████████ █████████   █████████████              "
        echo "     ██        ██                 ██    ███████████    ██    ██ ██     ██   ██         ██              "
        echo "     ██        ██      ████████████    ██              ██    ██ ██     ██   ██         ██              "
        echo "     ████   ████████   ██ ██████ ██    ██      ██      ██    ██ ██     ██   ██         ██              "
        echo "   ████     ██    ██   ██        ██    ██████████      ██    ██ ██     ██   █████████████              "
        echo "██   ██       ██ ██    ██ ██████ ██    ██              ██    ██ ██     ██  ██           ██             "
        echo "     ██       ████     ██        ██    ██       ██    ██     ██ ██     ██  ██  ██    ██  ██            "
        echo "   ████   ████    ████ ██      ████      █████████  ██     ████ █████████ ██   ██    ██    ██    v0.1  "
        echo "===================================================================================================="   
        echo -e "${NC}"                                
        title "主菜单：$(detect_os)"
        echo -e "${BLUE}1) 系统源更新/设置${NC}"
        echo -e "${YELLOW}2) 系统测试常用的工具${NC}"
        echo -e "${GREEN}3) 网站建站工具${NC}"
        echo -e "${PINK}4) 系统面板管理工具${NC}"
        echo -e "${MAGENTA}5) VPN搭建工具${NC}"
        echo -e "${CYAN}6) 网络安全工具${NC}"
        echo -e "${GREEN}7) 其他扩展工具${NC}"
        echo -e "${RED}0) 退出${NC}"
        read -p "请输入选项: " sel

        case $sel in
            1) submenu1 ;;
            2) submenu2 ;;
            3) submenu3 ;;
            4) submenu4 ;;
            5) submenu5 ;;
            6) submenu6 ;;
            7) submenu7 ;;
            0) exit 0 ;;
            *) error "无效选项"; sleep 1 ;;
        esac
    done
}

























# ------------- 函数 （复用）-------------

# 颜色定义（可选）
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
PINK='\033[1;35m'
MAGENTA='\033[1;35m' #紫色
NC='\033[0m' # 无色
#打印标题
title() {
    echo -e "${PINK}========== $1 ==========${NC}" >&2
}
info(){
    echo -e "${BLUE}[INFO]  $1${NC}" >&2
}
error(){
    echo -e "${RED}[ERROR]  $1${NC}" >&2
}
warn(){
    echo -e "${YELLOW}[warning]  $1${NC}" >&2
}
success(){
    echo -e "${GREEN}[success]  $1${NC}" >&2
}
#检测系统发行版和版本
detect_os() {
    # 初始化变量
    local os_id=""
    local os_version=""
    local os_name=""

    # 优先使用 /etc/os-release
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        os_id="$ID"
        os_version="$VERSION_ID"
        os_name="$NAME"
    fi

    # 如果没有获取到，尝试其他方法
    if [ -z "$os_id" ]; then
        if [ -f /etc/redhat-release ]; then
            os_id="rhel"  # 或 centos/fedora，这里统一用 rhel 家族
            os_name=$(cat /etc/redhat-release | sed 's/ release .*//')
            os_version=$(cat /etc/redhat-release | sed 's/.* release //; s/ .*//')
        elif [ -f /etc/debian_version ]; then
            os_id="debian"
            os_name="Debian"
            os_version=$(cat /etc/debian_version)
        elif [ -f /etc/arch-release ]; then
            os_id="arch"
            os_name="Arch Linux"
            os_version="rolling"
        elif [ -f /etc/SuSE-release ]; then
            os_id="suse"
            os_name=$(head -1 /etc/SuSE-release)
            os_version=$(grep VERSION /etc/SuSE-release | cut -d' ' -f3)
        fi
    fi

    # 如果仍为空，尝试 lsb_release
    if [ -z "$os_id" ] && command -v lsb_release >/dev/null 2>&1; then
        os_id=$(lsb_release -is 2>/dev/null | tr '[:upper:]' '[:lower:]')
        os_version=$(lsb_release -rs 2>/dev/null)
        os_name=$(lsb_release -ds 2>/dev/null)
    fi

    # 去除可能的引号
    os_id=$(echo "$os_id" | tr -d '"' | tr '[:upper:]' '[:lower:]')
    os_version=$(echo "$os_version" | tr -d '"')
    os_name=$(echo "$os_name" | tr -d '"')

    # 如果没有识别到，设为 unknown
    if [ -z "$os_id" ]; then
        os_id="unknown"
        os_name="Unknown"
    fi
    echo "$os_id"
}
#检测运行的命令是否正确
check_cmd() {
    if ! command -v "$1" &>/dev/null; then
        return 1
    fi
    return 0
}


# 进度条函数
show_spinner() {
    local pid=$1
    local delay=0.1
    # 定义旋转字符数组（每个元素是一个完整的字符）
    local spin_chars=('⠋' '⠙' '⠹' '⠸' '⠼' '⠴' '⠦' '⠧' '⠇' '⠏')
    # 如果终端不支持 Braille，可以使用以下 ASCII 数组：
    # local spin_chars=('|' '/' '-' '\')
    # local spin_chars=('.' 'o' 'O' '0')
    tput sc  # 保存光标位置
    local i=0
    while kill -0 "$pid" 2>/dev/null; do
    tput rc
    # 输出方括号和当前字符，使用 %s
    printf "[%s]" "${spin_chars[$i]}"
    i=$(( (i+1) % ${#spin_chars[@]} ))
    sleep $delay
    done
    tput rc
    printf "   "   # 覆盖三个字符（方括号和字符）
    tput rc
}
# 检测系统类型并安装缺失工具
check_and_install_tools() {
    local -n pkg_map_ref=$1
    shift  # 移除第一个参数，剩余的是工具列表
    local TOOLS=("$@")
    local missing_tools=()
    for tool in "${TOOLS[@]}"; do
        if ! command -v "$tool" &>/dev/null; then
            missing_tools+=("$tool")
        fi
    done

    if [ ${#missing_tools[@]} -eq 0 ]; then
        success "所有必要工具已安装。"
        return
    fi

    warn "检测到以下工具缺失：${missing_tools[*]}，尝试安装..."

    
    # 设置安装命令（根据系统类型）
    local install_cmd=""
    case "$(detect_os)" in
        ubuntu|debian|kali)   
            # 先更新，再安装
            sudo apt update >/dev/null 2>&1
            install_cmd="sudo apt install -y"
            ;;
        centos|rhel|fedora)
            if [[ "$os_id" == "fedora" ]]; then
                install_cmd="sudo dnf install -y"
            else
                install_cmd="sudo yum install -y"
            fi
            ;;
        *)
            error "不支持的发行版：$(detect_os)，请手动安装依赖。"
            return
            ;;
    esac
    
    # 安装每个缺失工具
    for tool in "${missing_tools[@]}"; do
        local pkg_name="${pkg_map_ref[$tool]}"
        if [[ -z "$pkg_name" ]]; then
            error "未知的包名：$pkg_name，跳过。"
            continue
        fi
        echo -n "正在安装 ${pkg_name} ... "
        # 执行安装命令，完全屏蔽输出
        DEBIAN_FRONTEND=noninteractive timeout 300 $install_cmd "$pkg_name" >/dev/null 2>&1 &
        local install_pid=$!
        show_spinner $install_pid
        wait $install_pid
        if [ $? -eq 0 ]; then
            success "工具安装完成。"
        else
            error "工具安装失败。"
            info "请尝试手动安装一下软件，命令：$install_cmd $pkg_name"
            go_back
        fi
    done
    
}



# 倒计时返回
countdown(){
	# 倒计时返回
	for i in {40..1}; do
	echo -ne "\r倒计时: $i 秒后返回菜单，按任意键跳过... "
	if read -t 1 -n 1; then
	    echo -e "\n"
	    break
	fi
	done
}
#没有倒计时返回
go_back(){
    echo -ne "按任意键跳过返回菜单... "
	if read -n 1; then
	    echo -e "\n"
	    return
	fi
}
# 验证端口号
validate_port() {
    
    local port=$1
    while true; do
        read -p "请输入代理访问监听端口 (1-65535，回车默认 $port): " LISTEN_PORT
        LISTEN_PORT=${LISTEN_PORT:-$port}
        if ! [[ $LISTEN_PORT =~ ^[0-9]+$ ]] && [ $LISTEN_PORT -ge 1 ] && [ $LISTEN_PORT -le 65535 ] ; then
            error "无效端口号，请输入 1-65535 之间的数字。"
            continue
        fi
        if ss -tln | grep -q ":$LISTEN_PORT "; then
            warn "警告：端口 $LISTEN_PORT 已被占用，可以选择其他端口。"
            read -p "是否继续使用该端口？(y/n, 默认n): " confirm
            [[ "$confirm" == "y" ]] && break || continue
        else
            break
        fi
    done
}


#子选择菜单函数
select_menu() {
    local prompt="$1"
    shift
    local options=("$@")
    local selected=0

    while true; do
        clear
        echo -e "${PINK}====== $prompt ======${NC}"
        for i in "${!options[@]}"; do
            # 显示编号（从1开始）
            local num=$((i+1))
            if [[ $i -eq $selected ]]; then
                # 高亮显示当前选项（可选，仍保留视觉提示）
                tput rev
                echo "  $num. ${options[$i]}"
                tput sgr0
            else
                echo "  $num. ${options[$i]}"
            fi
        done

        # 读取用户输入
        read -p "请输入数字选择（1-${#options[@]}）：" input
        # 检查输入是否为数字且有效
        if [[ "$input" =~ ^[0-9]+$ ]] && (( input >= 1 && input <= ${#options[@]} )); then
            # 转换为0基索引并返回
            selected=$((input - 1))
            return $selected
        else
            # 无效输入，显示错误并等待继续（保留循环，不清屏太频繁）
            echo "无效输入，请重新输入（数字1-${#options[@]}）"
            sleep 1
        fi
    done
}

#获取公网IP
get_public_ip(){
    if check_cmd curl; then
        public_ip=$(curl -s --max-time 5 ifconfig.me 2>/dev/null || curl -s --max-time 5 icanhazip.com 2>/dev/null)
        if [ -n "$public_ip" ]; then
            echo "$public_ip"
        else
            echo "无法获取公网 IP（超时或无响应）"
        fi
    elif check_cmd wget; then
        public_ip=$(wget -qO- --timeout=5 ifconfig.me 2>/dev/null || wget -qO- --timeout=5 icanhazip.com 2>/dev/null)
        if [ -n "$public_ip" ]; then
            echo "$public_ip"
        else
            echo "无法获取公网 IP（超时或无响应）"
            check_and_install_tools "wget"
        fi
    fi
}

docker_install_sh() {
    if ! check_cmd docker &>/dev/null; then
        warn "Docker 未安装，开始安装..."
        # 安装 Docker
        echo -n "Docker 正在安装 ... "
        sudo curl -sSL https://get.docker.com | sudo bash >/dev/null 2>&1 &
        local install_pid=$!
        show_spinner "$install_pid"
        wait "$install_pid"
        if [ $? -eq 0 ]; then
            success "Docker 安装成功，正在启动服务..."
            sudo systemctl start docker
            sudo systemctl enable docker
            success "Docker 服务已启动并设置开机自启"
            return 0
        else
            error "Docker 安装失败"
            return 1
        fi
    else
        warn "Docker 已存在，跳过安装。"
        # 即使已安装，也确保服务正在运行（可选）
        if ! systemctl is-active --quiet docker; then
            warn "Docker 服务未运行，正在启动..."
            sudo systemctl start docker
            sudo systemctl enable docker
            
        fi
        return 0
    fi
}

#判断软件是否安装(docker)
check_docker(){
    local docker_name=$1
    # 检查 docker 命令是否可用
    if ! check_cmd docker; then
        echo "docker未安装"
        # 安装后再次确认
        if ! check_cmd docker; then
            return 1
        fi
    fi

    # 检查 docker 服务是否运行
    if ! sudo docker info >/dev/null 2>&1; then
        echo "docker服务未运行"
        return 1
    fi

    # 3检查容器是否存在
    if sudo docker ps -a --format '{{.Names}}' | grep -qx "$docker_name"; then
        # 容器存在，进一步检查是否正在运行
        if sudo docker ps --format '{{.Names}}' | grep -qx "$docker_name"; then
            echo "运行中(docker)"
        else
            echo "已停止(docker)"
        fi
    else
        echo "$docker_name 未安装"
    fi
    return 0

}
check_service(){
    local service_name="$1"

    # 1. 检查服务单元文件是否存在
    if ! sudo systemctl list-unit-files --full --all | grep -q "^${service_name}\.service"; then
        return 2
    fi

    # 2. 检查服务是否激活（运行中）
    if sudo systemctl is-active --quiet "$service_name"; then
        return 0
    else
        return 1
    fi
}

#验证定时任务的输入
validate_cron_nput() {
    local input="$1"
    local field="$2"
    local min="$3"
    local max="$4"

    # 允许空字符串（表示使用默认 *）
    if [[ -z "$input" ]]; then
        return 0
    fi

    # 允许常见的特殊符号：* , - /
    if [[ "$input" =~ ^[\*0-9\,\-\/]+$ ]]; then
        # 更细致的校验：检查 */ 或数字范围等
        if [[ "$input" =~ ^[0-9]+$ ]]; then
            if (( input < min || input > max )); then
                error "错误：$field 的值 $input 不在范围 $min-$max 内"
                return 1
            fi
        fi
        return 0
    else
        error "错误：$field 包含非法字符，只能使用数字、*、,、-、/"
        return 1
    fi
}


# ------------- 子菜单功能1 -------------
submenu1() {
	while true; do
        select_menu "系统参数设置面板 - 当前系统: $(detect_os)" "系统源的更新" "设置系统定时执行的任务" "返回主菜单"
        choice=$?
        case $choice in
            0) clear; update_repo && success "更新成功"; countdown ;;
            1) clear; setup_cron ;;
            2) return ;;
        esac
	done
}

update_repo(){
    case "$(detect_os)" in
        ubuntu|debian|kali)
            info "检测到 Debian/Ubuntu 系统，执行 apt update..."
            sudo apt update
            ;;
        rhel|centos|fedora|rocky|almalinux)
            info "检测到 RHEL/CentOS/Fedora 系统，执行 yum/dnf 更新..."
            if command -v dnf >/dev/null 2>&1; then
                sudo dnf makecache
            else
                sudo yum makecache
            fi
            ;;
        arch|manjaro)
            info "检测到 Arch/Manjaro 系统，执行 pacman -Sy..."
            sudo pacman -Sy
            ;;
        opensuse|suse)
            info "检测到 openSUSE 系统，执行 zypper refresh..."
            sudo zypper refresh
            ;;
        alpine)
            info "检测到 Alpine 系统，执行 apk update..."
            sudo apk update
            ;;
        *)
            info "未知或不支持的系统类型: $sys_type"
            return 1
            ;;
    esac
}

setup_cron(){
    while true; do
        select_menu "设置系统定时执行的任务 - 当前系统: $(detect_os)" "添加定时任务" "查看当前系统定时任务" "删除定时任务" "返回上级菜单"
        choice=$?
        case $choice in
            0) clear; add_cron; go_back ;;
            1) clear; list_cron; go_back ;;
            2) clear; delete_cron; go_back ;;
            3) return ;;
        esac
	done
}

add_cron(){
    title "添加定时任务"
    cat << EOF
    示例：
        每天凌晨 3:30     → 分钟=30, 小时=3, 日期=*, 月份=*, 星期=*
        每月1号 0:0       → 分钟=0, 小时=0, 日期=1, 月份=*, 星期=*
        每周一 5:15       → 分钟=15, 小时=5, 日期=*, 月份=*, 星期=1
        每 10 分钟        → 分钟=*/10, 小时=*, 日期=*, 月份=*, 星期=*
EOF
    title "输入定时任务执行的时间"
    # 获取分钟
    while true; do
        read -p "分钟 (0-59, 默认 *) : " minute
        if validate_cron_nput "$minute" "分钟" 0 59; then
            minute=${minute:-*}
            break
        fi
    done

    # 获取小时
    while true; do
        read -p "小时 (0-23, 默认 *) : " hour
        if validate_cron_nput "$hour" "小时" 0 23; then
            hour=${hour:-*}
            break
        fi
    done

    # 获取日期（月份中的第几天）
    while true; do
        read -p "日期 (1-31, 默认 *) : " day
        if validate_cron_nput "$day" "日期" 1 31; then
            day=${day:-*}
            break
        fi
    done

    # 获取月份
    while true; do
        read -p "月份 (1-12, 默认 *) : " month
        if validate_cron_nput "$month" "月份" 1 12; then
            month=${month:-*}
            break
        fi
    done

    # 获取星期
    while true; do
        read -p "星期 (0-7, 0和7=周日, 默认 *) : " weekday
        if validate_cron_nput "$weekday" "星期" 0 7; then
            weekday=${weekday:-*}
            break
        fi
    done

    # 获取要执行的命令
    while true; do
        read -p "请输入要定时执行的完整命令（例如：/usr/bin/backup.sh）: " command
        if [[ -z "$command" ]]; then
            error "命令不能为空，请重新输入"
        else
            break
        fi
    done
    # 生成cron表达式
    local cron_line="$minute $hour $day $month $weekday $command"
    
    # 显示确认信息
    warn "即将添加以下定时任务："
    info "    $cron_line"
    read -p "确认添加吗？(y/N) " confirm
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        success "已取消操作。"
    else
        # 备份当前 crontab
        sudo crontab -l > /tmp/crontab_backup_$$ 2>/dev/null
        if [[ $? -eq 0 ]]; then
            success "已备份当前 crontab 到 /tmp/crontab_backup_$$"
        fi

        # 添加新任务（先去重，避免完全相同的行重复）
        sudo crontab -l 2>/dev/null | grep -Fx "$cron_line" >/dev/null
        if [[ $? -eq 0 ]]; then
            warn "警告：该定时任务已经存在于 crontab 中，不会重复添加。"
        else
            (sudo crontab -l 2>/dev/null; echo "$cron_line") | crontab -
            if [[ $? -eq 0 ]]; then
                success "成功添加定时任务！"
                info "当前用户的所有 crontab 任务如下："
                crontab -l
            else
                error "添加失败，请检查权限或 crontab 格式。"
            fi
        fi
    fi

}

# 查看定时任务
list_cron() {
    title "当前系统定时任务:"
    sudo crontab -l 2>/dev/null || echo "没有设置定时任务"

}

delete_cron(){
    # 获取当前定时任务
    sudo crontab -l > /tmp/current_crontab 2>/dev/null
    
    # 检查是否有定时任务
    if [ ! -s /tmp/current_crontab ]; then
        warn "没有设置定时任务"
        sudo rm -f /tmp/current_crontab
        
    else
        # 列出定时任务并编号
        title "当前定时任务:"
        echo "------------------"
        local line_num=1
        while IFS= read -r line; do
            if [ -n "$line" ]; then
                echo "$line_num. $line"
                line_num=$((line_num + 1))
            fi
        done < /tmp/current_crontab
        echo "------------------"
        
        while true; do
            read -p "请输入要删除的任务编号: " choice
            if [[ ! $choice =~ ^[0-9]+$ ]]; then
                error "错误: 请输入有效的数字"
                sudo rm -f /tmp/current_crontab
                continue
            fi
            local total_lines=$(wc -l < /tmp/current_crontab)
            if [ $choice -lt 1 ] || [ $choice -gt $total_lines ]; then
                error "错误: 无效的任务编号"
                sudo rm -f /tmp/current_crontab
                continue
            fi
            # 删除选中的任务
            local line_to_delete=$choice
            sudo awk -v line="$line_to_delete" 'NR != line' /tmp/current_crontab > /tmp/new_crontab

            sudo crontab /tmp/new_crontab
            if [ $? -eq 0 ]; then
                success "成功: 定时任务已删除"
            else
                error "错误: 定时任务删除失败"
            fi
            break
        done
        sudo rm -f /tmp/current_crontab /tmp/new_crontab
    fi
  
}




# ------------- 子菜单功能2 -------------
submenu2() {
    while true; do
        select_menu "系统测试常用的工具- 当前系统: $(detect_os)" "获取系统信息详细" "服务器网络测试" "服务器性能测试(硬盘读/写)" "硬盘挂载" "返回主菜单"
        choice=$?
        case $choice in
            0) clear;submenu2-1;go_back ;;
            1) clear;submenu2-2  ;;
            2) clear;submenu2-3 ;;
            3) clear;submenu2-4 ;;
            4) return ;;
        esac
    done
}

submenu2-1(){
    # 1. 系统版本和类型
    title "系统版本和类型"
    if check_cmd hostnamectl; then
        hostnamectl | grep -E "Operating System|Kernel|Architecture" | sed 's/^[[:space:]]*//' || true
    elif [ -f /etc/os-release ]; then
        . /etc/os-release
        info "操作系统: $PRETTY_NAME"
        info "系统类型: $(uname -o)"
    elif [ -f /etc/issue ]; then
        info "系统版本: $(cat /etc/issue | head -1)"
    else
        error "无法获取系统版本信息"
    fi
    info "内核版本: $(uname -r)"
    echo

    # 2. 内核详细信息
    title "内核"
    uname -a
    echo

    # 3. CPU 参数
    title "CPU 参数"
    if [ -f /proc/cpuinfo ]; then
        info "CPU 型号: $(grep "model name" /proc/cpuinfo | head -1 | cut -d: -f2 | sed 's/^[ \t]*//')"
        info "物理 CPU 数: $(grep "physical id" /proc/cpuinfo | sort -u | wc -l)"
        info "每颗 CPU 核心数: $(grep "cpu cores" /proc/cpuinfo | head -1 | cut -d: -f2 | sed 's/^[ \t]*//')"
        info "逻辑 CPU 总数: $(grep -c "processor" /proc/cpuinfo)"
        if grep -q "cpu MHz" /proc/cpuinfo; then
            info "CPU 频率: $(grep "cpu MHz" /proc/cpuinfo | head -1 | cut -d: -f2 | sed 's/^[ \t]*//') MHz"
        elif check_cmd lscpu; then
            lscpu | grep "CPU MHz" | sed 's/^[[:space:]]*//'
        fi
    else
        error "无法读取 CPU 信息"
    fi
    echo
    # 4. 内存大小
    title "内存大小"
    if check_cmd free; then
        free -h
    else
        error "无法获取内存信息"
    fi
    echo
    # 5. 硬盘大小
    title "硬盘大小"
    if check_cmd lsblk; then
        info "物理磁盘信息："
        lsblk -d -o NAME,SIZE,MODEL 2>/dev/null || lsblk -d -o NAME,SIZE
    else
        info "分区使用情况（df -h）："
        df -h --total 2>/dev/null || df -h
    fi
    echo
    # 6. 后台运行的程序（仅显示运行软件，过滤内核线程）
    title "后台运行的程序"
    if check_cmd ps; then
        # 过滤掉内核线程（COMMAND 列包含 [ 的进程）
        total=$(ps aux | grep -c -v '\[.*\]')
        info "运行软件列表（过滤内核线程，仅显示前20行，总数：$total）："
        ps aux | grep -v '\[.*\]' | head -20
    else
        error "ps 命令不可用"
    fi
    echo

    # 7. 系统的目录结构（根目录）
    title "系统的目录结构（根目录）"
    ls -la /
    echo
    #8. 网络 IP 地址和网卡（内网 + 公网）
    title "网络 IP 地址和网卡"
    echo "--- 内网 IP 地址（含回环）---"
    if check_cmd ip; then
        # 显示所有 IPv4 地址，包括回环
        ip -4 -o addr show | while read line; do
            iface=$(echo "$line" | awk '{print $2}' | cut -d: -f1)
            addr=$(echo "$line" | awk '{print $4}' | cut -d/ -f1)
            info "接口: $iface, IP: $addr"
        done
    elif check_cmd ifconfig; then
        ifconfig -a | grep -E '^[a-z]|inet ' | while read line; do
            if [[ $line =~ ^[a-zA-Z] ]]; then
                iface=$(echo "$line" | cut -d: -f1)
            elif [[ $line =~ inet[[:space:]]+([0-9.]+) ]]; then
                addr="${BASH_REMATCH[1]}"
                info "接口: $iface, IP: $addr"
            fi
        done
    else
        error "无法获取内网 IP（缺少 ip/ifconfig 命令）"
    fi

    title "公网 IP 地址"
        info "公网的 IP $(get_public_ip)"
    echo


    # 9. 系统安装的软件
    title "系统安装的软件"
    if command -v dpkg &>/dev/null; then
        info "Debian/Ubuntu 系统，已安装软件包列表（dpkg -l）："
        # 使用 2>/dev/null 隐藏 dpkg 可能产生的错误（如权限不足）
        if dpkg -l 2>/dev/null | head -20 | grep -q .; then
            dpkg -l 2>/dev/null | head -20
            info "... 总数：$(dpkg -l 2>/dev/null | wc -l)"
        else
            echo "无法获取软件包列表，可能权限不足或 dpkg 数据库损坏。"
        fi
    elif command -v rpm &>/dev/null; then
        info "RHEL/CentOS/Fedora 系统，已安装软件包列表（rpm -qa）："
        rpm -qa 2>/dev/null | head -20
        info "... 总数：$(rpm -qa 2>/dev/null | wc -l)"
    elif command -v pacman &>/dev/null; then
        info "Arch Linux 系统，已安装软件包列表（pacman -Q）："
        pacman -Q 2>/dev/null | head -20
        info "... 总数：$(pacman -Q 2>/dev/null | wc -l)"
    elif command -v apk &>/dev/null; then
        info "Alpine Linux 系统，已安装软件包列表（apk info）："
        apk info 2>/dev/null | head -20
        info "... 总数：$(apk info 2>/dev/null | wc -l)"
    else
        error "无法识别的包管理器，无法列出已安装软件"
    fi
    echo

}
submenu2-2(){
    while true; do
        select_menu "服务器网络测试 - $(get_public_ip)" "三网回程延迟路由测试(besttrace)" "三网回程线路测试(mtr_trace)" "网络带宽测试" "返回上级菜单"
        choice=$?
        case $choice in
            0) clear;return_trip_besttrace ; go_back;;
            1) clear;return_trip_mtr_trace;go_back;;
            2) clear;network_speed;go_back;;
            3) return ;;
        esac
    done

}

#安装besttrace函数
install_besttrace(){
    local -A MY_PKG_MAP=(
        ["unzip"]="unzip"
        )
    check_and_install_tools MY_PKG_MAP "unzip"
    if ! command -v "besttrace" &>/dev/null; then
        #定义下载地址和文件名
        ZIP_URL="https://cdn.ipip.net/17mon/besttrace4linux.zip"
        ZIP_FILE="besttrace4linux.zip"
        if [ -f "$ZIP_FILE" ]; then
            echo "文件 $ZIP_FILE 已存在，跳过下载。"
        else
            echo "正在下载 besttrace..."
            wget "$ZIP_URL" -O "$ZIP_FILE" || { echo "下载失败，请检查网络或链接。";return; }
        fi
        # 创建临时目录用于解压
        TEMP_DIR=$(mktemp -d)
        echo "创建临时目录：$TEMP_DIR"

        # 解压文件到临时目录
        echo "解压 $ZIP_FILE 到临时目录..."
        unzip -q "$ZIP_FILE" -d "$TEMP_DIR" || { echo "解压失败，可能文件损坏。";return ; }

        # 查找解压出的 besttrace 可执行文件（通常直接在临时目录根下）
        BIN_PATH=$(find "$TEMP_DIR" -type f -name "besttrace" | head -n 1)
        if [ -z "$BIN_PATH" ]; then
            echo "错误：在解压文件中未找到 besttrace 可执行文件。"
            rm -rf "$TEMP_DIR"
            return
        fi

        # 添加执行权限
        chmod +x "$BIN_PATH"

        # 移动文件到系统目录（根据权限使用 sudo）
        DEST="/usr/local/bin"
        echo "正在将 besttrace 安装到 $DEST ..."
        if [ "$EUID" -eq 0 ]; then
            # 当前为 root 用户，直接移动
            mv "$BIN_PATH" "$DEST/"
        else
            # 非 root 用户，尝试使用 sudo
            if command -v sudo &> /dev/null; then
                sudo mv "$BIN_PATH" "$DEST/"
            else
                echo "错误：需要 root 权限才能写入 $DEST，且 sudo 不可用。"
                rm -rf "$TEMP_DIR"
                return
            fi
        fi

        # 清理临时目录
        echo "清理临时文件..."
        rm -rf "$TEMP_DIR"

        # 验证安装
        echo "验证安装版本："
        besttrace --version

        # 可选：询问是否删除下载的 zip 文件
        read -p "是否删除已下载的压缩包 $ZIP_FILE ？(y/N) " -r
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            rm -f "$ZIP_FILE"
            echo "已删除 $ZIP_FILE"
        else
            echo "保留 $ZIP_FILE，下次运行可跳过下载。"
        fi
        title "besttrace 安装成功！"
    
    fi
}
return_trip_besttrace(){

    if check_cmd "besttrace" ; then
        success "besttrace工具已存在"
    else
        install_besttrace
    fi
    #设置token
    while true; do
        select_menu "TONKEN选项(https://user.ipip.net/client.php)" "使用脚本自带Token" "输入自己的Token" "返回上级菜单"
        choice=$?
        case $choice in
            0) echo "1cd98e5f1ada678a4c4501f38b7c9eb5d6a60267">besttrace.lic ;break;;
            1) read -p "请输入ipip的Token: " ipip_token; echo "${ipip_token}">besttrace.lic ;break ;;
            2) return ;;
        esac
    done
    # 定义测试节点 (使用关联数组，需 Bash 4.0+)
    local -A NODES=(
        ["北京电信"]="219.141.147.210"
        ["上海电信"]="202.96.209.133"
        ["广州电信"]="202.96.128.86"
        ["北京联通"]="202.106.50.1"
        ["上海联通"]="210.22.97.1"
        ["广州联通"]="157.122.10.21"
        ["北京移动"]="221.179.155.161"
        ["上海移动"]="211.136.112.200"
        ["广州移动"]="211.139.129.5"
    )
    title "三网回程延迟路由测试 (besttrace)"
    for name in "${!NODES[@]}"; do
        besttrace_node "$name" "${NODES[$name]}"
    done

    

}
# besttrace测试节点
besttrace_node() {
    local name="$1"
    local ip="$2"
    title  "测试节点：$name ($ip) "
    besttrace -q 1 -n  -g cn "$ip" 
    echo ""
}

return_trip_mtr_trace(){
	sudo apt update -y && apt install mtr -y
	sudo yum clean all && yum makecache && yum install mtr -y
	clear
    iplise=(219.141.136.12 202.106.50.1 221.179.155.161 202.96.209.133 210.22.97.1 211.136.112.200 58.60.188.222 210.21.196.6 120.196.165.24)
    iplocal=(北京电信 北京联通 北京移动 上海电信 上海联通 上海移动 深圳电信 深圳联通 深圳移动)
    echo -e "\n正在测试,请稍等..."
    echo -e "——————————————————————————————\n"
    for i in {0..8}; do
        mtr -r --n --tcp -i 1 ${iplise[i]} > /root/traceroute_testlog
        grep -q "59\.43\." /root/traceroute_testlog
        if [ $? == 0 ];then
            grep -q "202\.97\."  /root/traceroute_testlog
            if [ $? == 0 ];then
            echo -e "目标:${iplocal[i]}[${iplise[i]}]\t回程线路:\033[1;32m电信CN2 GT\033[0m"
            else
            echo -e "目标:${iplocal[i]}[${iplise[i]}]\t回程线路:\033[1;31m电信CN2 GIA\033[0m"
            fi
        else
            grep -q "202\.97\."  /root/traceroute_testlog
            if [ $? == 0 ];then
                grep -q "219\.158\." /root/traceroute_testlog
                if [ $? == 0 ];then
                echo -e "目标:${iplocal[i]}[${iplise[i]}]\t回程线路:\033[1;33m联通169\033[0m"
                else
                echo -e "目标:${iplocal[i]}[${iplise[i]}]\t回程线路:\033[1;34m电信163\033[0m"
                fi
            else
                    grep -q "218\.105\."  /root/traceroute_testlog
                    if [ $? == 0 ];then
                    echo -e "目标:${iplocal[i]}[${iplise[i]}]\t回程线路:\033[1;35m联通9929\033[0m"
                    else
                        grep -q "219\.158\."  /root/traceroute_testlog
                        if [ $? == 0 ];then
                            grep -q "219\.158\.113\." /root/traceroute_testlog
                            if [ $? == 0 ];then
                            echo -e "目标:${iplocal[i]}[${iplise[i]}]\t回程线路:\033[1;33m联通AS4837\033[0m"
                            else
                            echo -e "目标:${iplocal[i]}[${iplise[i]}]\t回程线路:\033[1;33m联通169\033[0m"
                            fi
                        else				
                            grep -q "223\.120\."  /root/traceroute_testlog
                            if [ $? == 0 ];then
                            echo -e "目标:${iplocal[i]}[${iplise[i]}]\t回程线路:\033[1;35m移动CMI\033[0m"
                            else
                                grep -q "221\.183\."  /root/traceroute_testlog
                                if [ $? == 0 ];then
                                echo -e "目标:${iplocal[i]}[${iplise[i]}]\t回程线路:\033[1;35m移动cmi\033[0m"
                                else
                                echo -e "目标:${iplocal[i]}[${iplise[i]}]\t回程线路:其他"
                            fi
                        fi
                    fi
                fi
            fi
        fi
    echo 
    done
    rm -f /root/traceroute_testlog
    echo -e "\n——————————————————————————————\n本脚本测试结果为TCP回程路由,非ICMP回程路由 仅供参考,以最新IP段为准 谢谢\n"

}
#网络测试
network_speed(){

    if check_cmd "iperf3" ; then
        success "iperf3工具已存在"
    else
        local -A MY_PKG_MAP=(
            ["iperf3"]="iperf3"
        )
        check_and_install_tools MY_PKG_MAP "iperf3"
    fi
    # 动态解析速度
    parse_iperf_speed() {
        local output=$1
        local type=$2
        local line=$(echo "$output" | grep "$type" | tail -1)
        if [[ -n "$line" ]]; then
            local val=$(echo "$line" | awk '{for(i=1;i<=NF;i++) if($i~/bits\/sec/) print $(i-1)}')
            local unit=$(echo "$line" | awk '{for(i=1;i<=NF;i++) if($i~/bits\/sec/) print $i}')
            [[ -n "$val" ]] && echo "$val $unit" || echo "fail"
        else
            echo "fail"
        fi
    }

    run_iperf_yabs_style() {
        local host=$1
        local port=$2
        
        # 尝试端口轮询
        for p in $(seq "$port" $((port + 2))); do
            # 1. 首先尝试 YABS 标准的 8 线程
            local out=$(timeout 12 iperf3 -c "$host" -p "$p" -t 8 -P 8 2>/dev/null || true)
            local send=$(parse_iperf_speed "$out" "sender")
            
            # 2. 如果 8 线程失败，降级尝试单线程 (解决部分节点限流问题)
            if [[ "$send" == "fail" ]]; then
                out=$(timeout 10 iperf3 -c "$host" -p "$p" -t 5 2>/dev/null || true)
                send=$(parse_iperf_speed "$out" "sender")
            fi

            if [[ "$send" != "fail" ]]; then
                sleep 1
                local out_rev=$(timeout 12 iperf3 -c "$host" -p "$p" -t 8 -P 8 -R 2>/dev/null || true)
                local recv=$(parse_iperf_speed "$out_rev" "receiver")
                echo "$send | $recv"
                return
            fi
        done
        echo "busy | busy"
    }
    SERVERS=(
    "Online.net     | Paris, FR (10G)       | ping.online.net          | 5201"
    "LeaseWeb       | Hong Kong (10G)       | speedtest.hkg12.hk.leaseweb.net | 5201"
    "Clouvider      | Los Angeles, US (10G) | la.iperf.clouvider.net   | 5201"
    "Speedtest.de   | Frankfurt, DE (10G)   | speedtest.wtnet.de       | 5200"
    "Misaka.io      | Tokyo, JP (1G)        | tyo02.iperf.misaka.io    | 5201"
    )
    title "网络带宽测试"
    printf "%-15s | %-22s | %-16s | %-16s | %-10s\n" "供应商" "  地区" "  上传速度" "  下载速度" "  Ping"
    echo "----------------|------------------------|------------------|------------------|----------"

    for server in "${SERVERS[@]}"; do
        IFS='|' read -r provider location host port <<< "$server"
        provider=$(echo "$provider" | xargs); location=$(echo "$location" | xargs)
        host=$(echo "$host" | xargs); port=$(echo "$port" | xargs)

        echo -ne "正在测试: $provider..." "\r"
        
        # 获取 Ping
        ping_val=$(ping -c 2 -W 2 "$host" 2>/dev/null | tail -1 | awk -F '/' '{print $5}')
        [[ -z "$ping_val" ]] && ping_ms="timeout" || ping_ms="$(printf "%.1f ms" "$ping_val")"

        # 执行测试
        res=$(run_iperf_yabs_style "$host" "$port")
        send=$(echo "$res" | cut -d'|' -f1 | xargs)
        recv=$(echo "$res" | cut -d'|' -f2 | xargs)

        printf "\r%-15s | %-22s | %-16s | %-16s | %-10s\n" "$provider" "$location" "$send" "$recv" "$ping_ms"
    done
}
submenu2-3(){
    #安装依赖工具
    if check_cmd "fio" && check_cmd "jq" && check_cmd "bc"; then
        success "fio和jq工具已存在"
    else
        local -A MY_PKG_MAP=(
            ["fio"]="fio"
            ["jq"]="jq"
            ["bc"]="bc"
        )
        check_and_install_tools MY_PKG_MAP "fio" "jq" "bc"
    fi

    while true; do
        select_menu "fio的四种核心测试" "随机读/写IOPS（模拟数据库查询等）" "顺序读吞吐量（模拟大文件拷贝、视频流播放）" "顺序写吞吐量（模拟大文件写入）" "混合随机读写与延迟（模拟复杂真实场景）" "返回主菜单"
        choice=$?
        case $choice in
            0) clear;fio_iops_r_w;go_back;break ;;
            1) clear;fio_iops_r;go_back;break ;;
            2) clear;fio_iops_w;go_back;break ;;
            3) clear;fio_iops_rw;go_back;break ;;
            4) break ;;
        esac
    done

}
fio_iops_r_w(){
    # 定义关联数组：描述 -> 命令
    local -A commands=(
        ["randread"]="fio --name=randread_iops --filename=/mnt/data/fio_r_testfile --rw=randread --bs=4k --size=4G --iodepth=32 --numjobs=4 --runtime=120 --time_based --direct=1 --ioengine=libaio --group_reporting --output-format=json --output=/tmp/fio_rr_result.json"
        ["randwrite"]="fio --name=randwrite_iops --filename=/mnt/data/fio_w_testfile --rw=randwrite --bs=4k --size=4G --iodepth=32 --numjobs=4 --runtime=120 --time_based --direct=1 --ioengine=libaio --group_reporting --output-format=json --output=/tmp/fio_rw_result.json"
    )
    fio_iops commands
}

fio_iops_r(){
    # 定义关联数组：描述 -> 命令
    local -A commands=(
        ["read"]="fio --name=randread_iops --filename=/mnt/data/fio_r_testfile --rw=read --bs=1M --size=10G --iodepth=8 --numjobs=1 --runtime=120 --time_based --direct=1 --ioengine=libaio --group_reporting --output-format=json --output=/tmp/fio_r_result.json"
    )
    fio_iops commands
}
fio_iops_w(){
    # 定义关联数组：描述 -> 命令
    local -A commands=(
        ["write"]="fio --name=randread_iops --filename=/mnt/data/fio_r_testfile --rw=write --bs=1M --size=10G --iodepth=8 --numjobs=1 --runtime=120 --time_based --direct=1 --ioengine=libaio --group_reporting --output-format=json --output=/tmp/fio_w_result.json"
    )
    fio_iops commands
}
fio_iops_rw(){
    # 定义关联数组：描述 -> 命令
    local -A commands=(
        ["randreadwrite"]="fio --name=randread_iops --filename=/mnt/data/fio_r_testfile --rw=randrw --rwmixread=70 --bs=4k --size=4G --iodepth=1 --numjobs=1 --runtime=60 --time_based --direct=1 --ioengine=libaio --group_reporting --output-format=json --output=/tmp/fio_rrw_result.json"
    )
    fio_iops commands
}


fio_iops(){
    local -n cmds=$1
    #创建目录
    mkdir -p /mnt/data
    # 定义关联数组：描述 -> 命令
    for cmd in "${!cmds[@]}"; do
        title "进行fio的 $cmd 性能测试，请稍等..."
        echo -n "测试中 ${cmd} ... "
        eval "${cmds[$cmd]}" >/dev/null 2>&1 &
        local cmd_pid=$!   # 如果不在函数内，去掉 local
        show_spinner "$cmd_pid"
        wait "$cmd_pid"
        if [ $? -eq 0 ]; then
            case "$cmd" in
                randread)
                    fio_r_w_format "/tmp/fio_rr_result.json"
                    ;;
                randwrite)
                    fio_r_w_format "/tmp/fio_rw_result.json"
                    ;;
                write)
                    fio_r_w_format "/tmp/fio_w_result.json"
                    ;;
                read)
                    fio_r_w_format "/tmp/fio_r_result.json"
                    ;;
                *)
                    fio_rw_format "/tmp/fio_rrw_result.json"
            esac
        else
            error "$cmd 失败。"
        fi
    done
}

fio_r_w_format(){
    local JSON_FILE="$1"
    if [ ! -f "$JSON_FILE" ]; then
        error "错误：未找到 JSON 文件 $JSON_FILE"
        return
    fi
    # 提取关键指标
    JOB=$(jq '.jobs[0]' "$JSON_FILE")
    JOB_NAME=$(echo "$JOB" | jq -r '.jobname')
    READ_IOPS=$(echo "$JOB" | jq -r '.read.iops')
    WRITE_IOPS=$(echo "$JOB" | jq -r '.write.iops')
    READ_BW=$(echo "$JOB" | jq -r '.read.bw')
    WRITE_BW=$(echo "$JOB" | jq -r '.write.bw')
    READ_LAT_NS=$(echo "$JOB" | jq -r '.read.lat_ns.mean')
    WRITE_LAT_NS=$(echo "$JOB" | jq -r '.write.lat_ns.mean')
    READ_LAT_US=$(echo "scale=2; $READ_LAT_NS / 1000" | bc)
    WRITE_LAT_US=$(echo "scale=2; $WRITE_LAT_NS / 1000" | bc)

    if [ "$READ_IOPS" != "null" ] && [ "$READ_IOPS" != "0" ]; then
        printf "随机读 IOPS: %'.0f\n" $READ_IOPS
        printf "随机读带宽: %'.0f KiB/s (约 %.2f MB/s)\n" $READ_BW $(echo "scale=2; $READ_BW / 1024" | bc)
        printf "随机读平均延迟: %.2f µs\n" $READ_LAT_US
    else
        printf "随机写 IOPS: %'.0f\n" $WRITE_IOPS
        printf "随机写带宽: %'.0f KiB/s (约 %.2f MB/s)\n" $WRITE_BW $(echo "scale=2; $WRITE_BW / 1024" | bc)
        printf "随机写平均延迟: %.2f µs\n" $WRITE_LAT_US
    fi
    #删除文件
    eval "rm -rf /mnt/data/$JSON_FILE" >/dev/null 2>&1 &
}
fio_rw_format(){
    local JSON_FILE="$1"
    if [ ! -f "$JSON_FILE" ]; then
        error "错误：未找到 JSON 文件 $JSON_FILE"
        return
    fi

    # 读取第一个 job 的数据
    JOB=$(jq '.jobs[0]' "$JSON_FILE")

    JOB_NAME=$(echo "$JOB" | jq -r '.jobname')
    READ_IOPS=$(echo "$JOB" | jq -r '.read.iops // 0')
    WRITE_IOPS=$(echo "$JOB" | jq -r '.write.iops // 0')
    READ_BW_KB=$(echo "$JOB" | jq -r '.read.bw // 0')
    WRITE_BW_KB=$(echo "$JOB" | jq -r '.write.bw // 0')
    READ_LAT_NS=$(echo "$JOB" | jq -r '.read.lat_ns.mean // 0')
    WRITE_LAT_NS=$(echo "$JOB" | jq -r '.write.lat_ns.mean // 0')

    # 延迟百分位数（读）
    READ_CLAT_PERCENTILES=$(echo "$JOB" | jq -r '.read.clat_percentiles."1.000000" // 0')
    READ_CLAT_PERCENTILES_50=$(echo "$JOB" | jq -r '.read.clat_percentiles."50.000000" // 0')
    READ_CLAT_PERCENTILES_99=$(echo "$JOB" | jq -r '.read.clat_percentiles."99.000000" // 0')
    # 写
    WRITE_CLAT_PERCENTILES=$(echo "$JOB" | jq -r '.write.clat_percentiles."1.000000" // 0')
    WRITE_CLAT_PERCENTILES_50=$(echo "$JOB" | jq -r '.write.clat_percentiles."50.000000" // 0')
    WRITE_CLAT_PERCENTILES_99=$(echo "$JOB" | jq -r '.write.clat_percentiles."99.000000" // 0')

    # 读部分
    if [ "$READ_IOPS" != "0" ]; then
        READ_BW_MB=$(echo "scale=2; $READ_BW_KB / 1024" | bc)
        READ_LAT_US=$(echo "scale=2; $READ_LAT_NS / 1000" | bc)
        echo "【读取性能】"
        printf "  IOPS:         %'.0f\n" $READ_IOPS
        printf "  带宽:         %'.0f KiB/s (约 %.2f MB/s)\n" $READ_BW_KB $READ_BW_MB
        printf "  平均延迟:     %.2f µs\n" $READ_LAT_US
        if [ "$READ_CLAT_PERCENTILES" != "0" ]; then
            printf "  延迟百分位数:\n"
            printf "    1%%:        %.0f µs\n" $READ_CLAT_PERCENTILES
            printf "    50%%:       %.0f µs\n" $READ_CLAT_PERCENTILES_50
            printf "    99%%:       %.0f µs\n" $READ_CLAT_PERCENTILES_99
        fi
        echo "-----------------------------------------------------"
    fi

    # 写部分
    if [ "$WRITE_IOPS" != "0" ]; then
        WRITE_BW_MB=$(echo "scale=2; $WRITE_BW_KB / 1024" | bc)
        WRITE_LAT_US=$(echo "scale=2; $WRITE_LAT_NS / 1000" | bc)
        echo "【写入性能】"
        printf "  IOPS:         %'.0f\n" $WRITE_IOPS
        printf "  带宽:         %'.0f KiB/s (约 %.2f MB/s)\n" $WRITE_BW_KB $WRITE_BW_MB
        printf "  平均延迟:     %.2f µs\n" $WRITE_LAT_US
        if [ "$WRITE_CLAT_PERCENTILES" != "0" ]; then
            printf "  延迟百分位数:\n"
            printf "    1%%:        %.0f µs\n" $WRITE_CLAT_PERCENTILES
            printf "    50%%:       %.0f µs\n" $WRITE_CLAT_PERCENTILES_50
            printf "    99%%:       %.0f µs\n" $WRITE_CLAT_PERCENTILES_99
        fi

    fi 
    #删除文件
    eval "rm -rf /mnt/data/$JSON_FILE" >/dev/null 2>&1 &
}

submenu2-4(){ 
    while true; do
        select_menu "$(detect_os) 系统-硬盘挂载 " "传统分区硬盘挂载(新硬盘)" "返回上级菜单"
        choice=$?
        case $choice in
            0) clear;traditional_drive ;;
            1) return ;;
        esac
    done
}
traditional_drive(){

    # 检查基础命令（增加 parted）
    for cmd in lsblk blkid mount umount mkfs.ext4 parted; do
        if ! command -v "$cmd" &>/dev/null; then
            error "错误：命令 $cmd 未安装。"
            local -A MY_PKG_MAP=(
                ["$cmd"]="$cmd"
            )
            check_and_install_tools MY_PKG_MAP "$cmd"
        fi
    done
    clear
    # 直接运行 lsblk 获取所有块设备信息
    echo -e "${PINK}正在扫描设备...${NC}"
    lsblk_output=$(sudo lsblk -o NAME,TYPE,SIZE,MOUNTPOINT,FSTYPE,LABEL -n -l 2>/dev/null)

    # 如果 lsblk 没有输出，则退出
    if [[ -z "$lsblk_output" ]]; then
        error "无法获取设备信息。"
        go_back
    
    else
    # 存储未挂载的设备列表（每行格式：设备名|类型|大小|文件系统|标签）
        unmounted_devices=()

        # 存储分区和磁盘信息
        declare -A part_parent
        declare -A disk_mount
        declare -A disk_size
        declare -A disk_fstype
        declare -A disk_label
        all_disks=()

        # 第一遍：收集所有磁盘和分区信息
        while IFS= read -r line; do
            [[ -z "$line" ]] && continue
            name=$(echo "$line" | awk '{print $1}')
            type=$(echo "$line" | awk '{print $2}')
            size=$(echo "$line" | awk '{print $3}')
            mnt=$(echo "$line" | awk '{print $4}')
            fstype=$(echo "$line" | awk '{print $5}')
            label=$(echo "$line" | awk '{print $6}')

            [[ "$name" =~ ^(loop|ram|zram) ]] && continue

            if [[ "$type" == "disk" ]]; then
                all_disks+=("$name")
                disk_mount["$name"]="$mnt"
                disk_size["$name"]="$size"
                disk_fstype["$name"]="$fstype"
                disk_label["$name"]="$label"
            elif [[ "$type" == "part" ]]; then
                # 提取父磁盘名（去除末尾数字）
                parent=$(echo "$name" | sed -E 's/[0-9]+$//')
                part_parent["$name"]="$parent"
                if [[ -z "$mnt" ]]; then
                    # 未挂载的分区，直接添加到最终列表
                    unmounted_devices+=("$name|$type|$size|$fstype|$label")
                fi
            fi
        done <<< "$lsblk_output"

        # 第二遍：检查空磁盘（没有分区的磁盘，且本身无挂载点）
        for disk in "${all_disks[@]}"; do
            # 如果磁盘有挂载点，跳过
            if [[ -n "${disk_mount[$disk]}" ]]; then
                continue
            fi
            # 检查是否有分区属于该磁盘
            has_part=0
            for part in "${!part_parent[@]}"; do
                if [[ "${part_parent[$part]}" == "$disk" ]]; then
                    has_part=1
                    break
                fi
            done
            if [[ $has_part -eq 0 ]]; then
                # 无分区的空磁盘，添加到最终列表
                unmounted_devices+=("$disk|disk|${disk_size[$disk]}|${disk_fstype[$disk]}|${disk_label[$disk]}")
            fi
        done

        # 如果没有未挂载设备，退出
        if [[ ${#unmounted_devices[@]} -eq 0 ]]; then
            error "没有找到未挂载的设备。"
            go_back
        
        else
        # 显示设备列表
            # 显示当前磁盘分区状态（调试信息）
            title "当前磁盘分区状态"
            sudo lsblk -f
            title ""
            success "找到以下未挂载的设备："
            for i in "${!unmounted_devices[@]}"; do
                IFS='|' read -r name type size fstype label <<< "${unmounted_devices[$i]}"
                label_info=""
                [[ -n "$label" ]] && label_info=" (标签: $label)"
                echo "  $((i+1)). /dev/$name 类型: $type 大小: $size 文件系统: ${fstype:-无}${label_info}"
            done

            # 用户选择
            echo -n "请选择要操作的设备编号 [1-${#unmounted_devices[@]}]: "
            read -r choice
            if [[ ! "$choice" =~ ^[0-9]+$ ]] || (( choice < 1 || choice > ${#unmounted_devices[@]} )); then
                error "无效选择，退出。"
                go_back
            fi


            IFS='|' read -r selected_name selected_type selected_size _ _ <<< "${unmounted_devices[$((choice-1))]}"
            selected_device="/dev/$selected_name"
            success "已选择设备: $selected_device (类型: $selected_type, 大小: $selected_size)"

            # 如果设备是磁盘且无分区，询问是否创建分区表
            if [[ "$selected_type" == "disk" ]]; then
                warn "注意：您选择的是一个完整的磁盘，目前没有分区表。"
                echo -n "是否要为此磁盘创建分区表并创建分区？(y/n，默认 n): "
                read -r create_part
                if [[ "$create_part" == "y" || "$create_part" == "Y" ]]; then
                    # 选择分区表类型
                    while true; do
                        echo "请选择分区表类型："
                        echo "  1) GPT   (推荐，支持大于2TB的磁盘)"
                        echo "  2) MBR   (传统，最大支持2TB)"
                        read -p "请输入选项 [1-2]: " part_type
                        if [[ "$part_type" == "1" ]]; then
                            table_type="gpt"
                            break
                        elif [[ "$part_type" == "2" ]]; then
                            # 检查磁盘大小是否超过2TB
                            # 解析大小（例如 "1.8T", "500G", "5T"）
                            size_value=$(echo "$selected_size" | sed -E 's/([0-9.]+)([KMGTP]?)/\1/')
                            size_unit=$(echo "$selected_size" | sed -E 's/[0-9.]+([KMGTP]?)/\1/')
                            # 转换为整数（以GB为单位比较）
                            size_gb=0
                            case $size_unit in
                                K) size_gb=$(echo "scale=2; $size_value / 1024 / 1024" | bc 2>/dev/null || echo 0);;
                                M) size_gb=$(echo "scale=2; $size_value / 1024" | bc 2>/dev/null || echo 0);;
                                G) size_gb=$size_value;;
                                T) size_gb=$(echo "$size_value * 1024" | bc 2>/dev/null || echo 0);;
                                P) size_gb=$(echo "$size_value * 1024 * 1024" | bc 2>/dev/null || echo 0);;
                                *) size_gb=0;;
                            esac
                            if (( $(echo "$size_gb > 2048" | bc -l 2>/dev/null || echo 0) )); then
                                error "警告：磁盘大小超过2TB，MBR分区表无法支持全部容量。建议使用GPT。"
                                read -p "是否仍要继续使用MBR？(y/n，默认 n): " force_mbr
                                if [[ "$force_mbr" != "y" && "$force_mbr" != "Y" ]]; then
                                    continue
                                fi
                            fi
                            table_type="msdos"
                            break
                        else
                            error "无效选项，请重新选择。"
                        fi
                    done

                    warn "正在为 $selected_device 创建 $table_type 分区表并创建一个分区占满全部空间..."
                    # 使用 parted 创建分区表并创建分区
                    if sudo parted -s "$selected_device" mklabel "$table_type" && \
                    sudo parted -s "$selected_device" mkpart primary 0% 100%; then
                        # 让内核重新读取分区表
                        sudo partprobe "$selected_device" 2>/dev/null || true
                        sleep 1
                        # 获取新创建的分区设备名
                        # 通常第一个分区为 ${selected_device}1
                        partition="${selected_device}1"
                        # 确认分区存在
                        if [[ -b "$partition" ]]; then
                            success "分区创建成功：$partition"
                            # 后续将使用分区进行格式化
                            selected_device="$partition"
                            selected_type="part"
                        else
                            error "分区创建失败，请检查。"
                            go_back
                        fi
                    else
                        error "分区表创建失败，请检查。"
                        go_back
                    fi
                else
                    echo "跳过分区创建，将直接格式化整个磁盘（不推荐）。"
                fi
            fi

            # 格式化（可选）
            echo -n "是否要对设备进行格式化？(y/n): "
            read -r fmt_choice
            if [[ "$fmt_choice" == "y" || "$fmt_choice" == "Y" ]]; then
                # 获取当前文件系统
                current_fs=$(sudo lsblk -n -o FSTYPE "$selected_device" 2>/dev/null | head -1)
                if [[ -n "$current_fs" && "$current_fs" != " " ]]; then
                    warn "设备 $selected_device 已有文件系统: $current_fs"
                    read -p "是否重新格式化？(y/n): " reformat
                    if [[ "$reformat" != "y" && "$reformat" != "Y" ]]; then
                        echo "跳过格式化。"
                    else
                        # 选择文件系统类型
                        while true; do
                            echo "请选择要格式化的文件系统类型："
                            echo "  1) ext4   (推荐)"
                            echo "  2) xfs    (需手动安装 xfsprogs)"
                            echo "  3) btrfs  (需安装 btrfs-progs)"
                            read -p "请输入选项 [1-3]: " fs_choice
                            case $fs_choice in
                                1) fstype="ext4"; mkfs_cmd="mkfs.ext4 -F"; break ;;
                                2) if command -v mkfs.xfs &>/dev/null; then
                                        fstype="xfs"; mkfs_cmd="mkfs.xfs -f"; break
                                    else
                                        error "未安装 mkfs.xfs，请手动安装 xfsprogs。"
                                        
                                    fi ;;
                                3) local -A MY_PKG_MAP=(["btrfs"]="btrfs-progs");check_and_install_tools MY_PKG_MAP "btrfs";fstype="btrfs"; mkfs_cmd="mkfs.btrfs -f"; break;;
                                *) error "无效选项。" ;;
                            esac
                        done
                        warn "正在格式化 $selected_device 为 $fstype..."
                        if sudo $mkfs_cmd "$selected_device"; then
                            success "格式化成功。"
                        else
                            error "格式化失败。"
                            go_back
                        fi
                    fi
                else
                    # 设备无文件系统，直接格式化
                    while true; do
                        echo "请选择要格式化的文件系统类型："
                        echo "  1) ext4   (推荐)"
                        echo "  2) xfs    (需手动安装 xfsprogs)"
                        echo "  3) btrfs  (需安装 btrfs-progs)"
                        read -p "请输入选项 [1-3]: " fs_choice
                        case $fs_choice in
                            1) fstype="ext4"; mkfs_cmd="mkfs.ext4 -F"; break ;;
                            2) if command -v mkfs.xfs &>/dev/null; then
                                fstype="xfs"; mkfs_cmd="mkfs.xfs -f"; break
                            else
                                error "未安装 mkfs.xfs，请手动安装 xfsprogs。"
                            fi ;;
                            3) local -A MY_PKG_MAP=(["btrfs"]="btrfs-progs");check_and_install_tools MY_PKG_MAP "btrfs";fstype="btrfs"; mkfs_cmd="mkfs.btrfs -f"; break ;;
                            *) error "无效选项。";;
                            esac
                        done
                    warn "正在格式化 $selected_device 为 $fstype..."
                    if sudo $mkfs_cmd "$selected_device"; then
                        success "格式化成功。"
                    else
                        error "格式化失败。"
                        go_back
                    fi
                fi
            fi

            # 挂载
            read -p "请输入挂载点目录 (例如 /mnt/data): " mount_point
            if [[ -z "$mount_point" ]]; then
                error "挂载点不能为空。"
                go_back
            fi
            if [[ ! -d "$mount_point" ]]; then
                sudo mkdir -p "$mount_point"
                echo "已创建目录 $mount_point"
            fi

            echo "选择挂载方式："
            echo "  1) 临时挂载 (重启后失效)"
            echo "  2) 永久挂载 (写入 /etc/fstab)"
            read -p "请输入选项 [1-2]: " mount_type

            case $mount_type in
                1)
                    echo -e "${YELLOW}正在临时挂载 $selected_device 到 $mount_point...${NC}"
                    if sudo mount "$selected_device" "$mount_point"; then
                        success "挂载成功！"
                        sudo df -h "$mount_point"
                    else
                        error "挂载失败。"
                        go_back
                    fi
                    ;;
                2)
                    uuid=$(sudo blkid -s UUID -o value "$selected_device")
                    if [[ -z "$uuid" ]]; then
                        error "无法获取 UUID。"
                        
                    fi
                    fstype=$(sudo lsblk -n -o FSTYPE "$selected_device" | head -1)
                    if [[ -z "$fstype" ]]; then
                        error "无法获取文件系统类型。"
                        go_back
                    fi

                    sudo cp /etc/fstab /etc/fstab.bak
                    sudo echo "UUID=$uuid $mount_point $fstype defaults 0 2" >> /etc/fstab
                    success "已添加条目到 /etc/fstab"
                    if sudo mount "$mount_point"; then
                        success "挂载成功！"
                        sudo df -h "$mount_point"
                        warn "提示：取消永久挂载前，先删除已添加到 /etc/fsta文件内的条目，在移除硬盘，或者导致系统无法正常开机使用"
                        go_back
                    else
                        error "挂载失败，已恢复 fstab 备份。"
                        sudo mv /etc/fstab.bak /etc/fstab
                        go_back
                    fi
                    ;;
                *)
                    error "无效选项。"
                    go_back
                    ;;
            esac
        fi

        
    fi

 
}


# ------------- 子菜单功能3 -------------

submenu3() {
    while true; do
        select_menu "网站建站工具" "安装1panel面板" "安装宝塔面板" "安装Nginx和设置反向代理" "返回主菜单"
        choice=$?

        case $choice in
            0) clear; submenu3-1 ;;
            1) clear; submenu3-2 ;;
            2) clear; submenu3-3 ;;
            3) return ;;
        esac
    done
}
submenu3-1(){
    local onep_status
    while true; do
        check_service "1panel-core"
        case $? in
            0) onep_status="服务存在且运行中" ;;
            1) onep_status="服务存在但未运行" ;;
            2) onep_status="未安装" ;;
        esac
        select_menu "1panel面板-状态：$onep_status" "安装1panel面板" "重启1panel面板" "停止1panel面板" "查看1panel面板当前状态" "修改1panel面板端口号" "修改1panel面板登录密码" "修改1panel面板登录账号" "卸载1panel面板" "返回上级菜单"
        choice=$?
        case $choice in
            0) clear; eval 'bash -c "$(curl -sSL https://resource.fit2cloud.com/1panel/package/v2/quick_start.sh)"';go_back ;;
            1) clear;if check_cmd 1pctl ; then sudo 1pctl restart;else error "1panel面板未安装";fi ;go_back ;;
            2) clear;if check_cmd 1pctl ; then sudo 1pctl stop;else error "1panel面板未安装";fi ;go_back ;;
            3) clear;if check_cmd 1pctl ; then sudo 1pctl status;else error "1panel面板未安装";fi ;go_back ;;
            4) clear;if check_cmd 1pctl ; then sudo 1pctl update port;else error "1panel面板未安装";fi ;go_back ;;
            5) clear;if check_cmd 1pctl ; then sudo 1pctl update password;else error "1panel面板未安装";fi ;go_back ;;
            6) clear;if check_cmd 1pctl ; then sudo 1pctl update username;else error "1panel面板未安装";fi ;go_back ;;
            7) clear;if check_cmd 1pctl ; then sudo 1pctl uninstall;else error "1panel面板未安装";fi ;go_back;;
            8) return ;;
        esac
    done
}
submenu3-2(){

    local bt_status
    while true; do
        # 判断宝塔面板是否安装
        check_service "bt"
        case $? in
            0) bt_status="服务存在且运行中" ;;
            1) bt_status="服务存在但未运行" ;;
            2) bt_status="未安装" ;;
        esac
        select_menu "宝塔面板-状态：$bt_status" "安装宝塔面板" "重启宝塔面板" "停止宝塔面板" "查看面板访问的信息" "修改宝塔面板端口号" "修改宝塔面板登录密码" "修改宝塔面板登录账号" "卸载宝塔面板" "返回上级菜单"
        choice=$?
        case $choice in
            0) clear; eval "if [ -f /usr/bin/curl ];then curl -sSO https://download.bt.cn/install/install_panel.sh;else wget -O install_panel.sh https://download.bt.cn/install/install_panel.sh;fi;bash install_panel.sh ed8484bec";go_back ;;
            1) clear;if check_cmd bt ; then sudo bt 1;else error "宝塔面板未安装";fi ; go_back ;;
            2) clear;if check_cmd bt ; then sudo bt 2;else error "宝塔面板未安装";fi ; go_back ;;
            3) clear;if check_cmd bt ; then sudo bt 14;else error "宝塔面板未安装";fi ; go_back ;;
            4) clear;if check_cmd bt ; then sudo bt 8;else error "宝塔面板未安装";fi ; go_back ;;
            5) clear;if check_cmd bt ; then sudo bt 5;else error "宝塔面板未安装";fi ; go_back ;;
            6) clear;if check_cmd bt ; then sudo bt 6;else error "宝塔面板未安装";fi ; go_back ;;
            7) clear;if check_cmd bt ; then sudo wget http://download.bt.cn/install/bt-uninstall.sh;clear;sudo bash bt-uninstall.sh;rm -rf bt-uninstall.sh;else error "宝塔面板未安装";fi ; go_back ;;
            8) return ;;
        esac
    done
}

submenu3-3(){
    local nginx_status
    while true; do
    # 判断Nginx是否安装
        check_service "nginx"
        case $? in
            0) nginx_status="服务存在且运行中" ;;
            1) nginx_status="服务存在但未运行" ;;
            2) nginx_status="未安装" ;;
        esac
        select_menu "Nginx反向代理/负载均衡 -状态：$nginx_status" "安装nginx（apt、yum）" "重启nginx" "停止nginx" "查看nginx状态" "重载nginx配置文件" "设置nginx开机自启" "反向代理内网服务" "卸载nginx" "返回上级菜单"
        choice=$?
        case $choice in
            0) clear; local -A MY_PKG_MAP=(["nginx"]="nginx" ["nginx-common"]="nginx-common" ["nginx-core"]="nginx-core");check_and_install_tools MY_PKG_MAP "nginx" "nginx-common" "nginx-core";go_back  ;;
            1) clear;if check_cmd nginx ; then title "重启nginx服务" ; sudo systemctl restart nginx;else error "nginx未安装";fi ; go_back ;;
            2) clear;if check_cmd nginx ; then title "停止nginx服务" ; sudo systemctl stop nginx;if pgrep -f "nginx" ; then sudo nginx -s stop ; fi;else error "nginx未安装";fi ; go_back ;;
            3) clear;if check_cmd nginx ; then title "查看nginx服务状态" ; sudo systemctl status nginx;else error "nginx未安装";fi ; go_back ;;
            4) clear;if check_cmd nginx ; then title "重载nginx服务配置文件" ; sudo systemctl reload nginx;else error "nginx未安装";fi ; go_back ;;
            5) clear;if check_cmd nginx ; then title "设置nginx服务开机自启动" ; sudo systemctl enable nginx;else error "nginx未安装";fi ;go_back ;;
            6) clear;if check_cmd nginx ; then nginx_reverse; else error "nginx未安装";fi ;;
            7) clear;if check_cmd nginx ; then title "停止nginx服务";sudo systemctl stop nginx|| true;if pgrep -f "nginx" ; then sudo nginx -s stop ; fi;print_info "卸载nginx";sudo apt purge nginx nginx-common nginx-core -y;print_info "移除nginx依赖";sudo apt autoremove -y; print_info "删除残留的配置和数据";sudo rm -rf /etc/nginx;sudo rm -rf /var/www/html ;else error "nginx未安装";fi ; go_back;;
            8) return ;;
        esac
    done
}
nginx_reverse(){
    while true; do
        select_menu "反向代理内网服务" "反向代理单服务(upstream)" "反向代理多个服务（虚拟主机）" "删除反向代理服务" "返回上级菜单"
        choice=$?
        case $choice in
            0) clear;nginx_reverse_input; go_back;;
            1) clear;more_nginx_reverse;go_back  ;;
            2) clear;del_nginx_reverse;go_back  ;;
            3) break ;;
        esac
    done
}
detect_nginx_vhost_dir() {
    # 判断是否为 Debian/Ubuntu 系列
    case "$(detect_os)" in
        ubuntu|debian|kali)
            CONF_DIR="/etc/nginx/sites-available"
            ENABLED_DIR="/etc/nginx/sites-enabled"
            # 确保目录存在
            mkdir -p "$CONF_DIR" "$ENABLED_DIR" 2>/dev/null
            ;;
        rhel|centos|fedora|rocky|almalinux)
            CONF_DIR="/etc/nginx/conf.d"
            mkdir -p "$CONF_DIR" 2>/dev/null
            echo "$CONF_DIR"
    esac
}

# 验证 URL 路径（以 / 开头，不含空格）
validate_location() {
    local loc=$1
    [[ $loc =~ ^/ && ! $loc =~ [[:space:]] ]]
}
# 验证后端地址格式（IP:端口 或 域名:端口）
validate_backend() {
    local backend=$1
    # 简单验证 IP:端口 格式
    [[ $backend =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}:[0-9]+$ ]] || \
    [[ $backend =~ ^[a-zA-Z0-9.-]+:[0-9]+$ ]]
}
# 清理旧配置（根据 server_name 和 location 路径）
clean_old_config() {
    local server_name=$1
    local loc_path=$2
    local listen_port=$3
    # 生成配置文件名：将 server_name 和 location 路径组合，替换特殊字符
    local safe_server_name=$(echo "$server_name" | tr -c 'a-zA-Z0-9' '_')
    local safe_location=$(echo "$loc_path" | tr '/' '_' | sed 's/^_//')
    local file_name="reverse_proxy_${safe_server_name}_${safe_location}_${listen_port}.conf"
    if [[ -n "$AVAILABLE_DIR" ]] && [[ -n "$ENABLED_DIR" ]]; then
        # Debian 风格
        sudo rm -f "$AVAILABLE_DIR/$file_name" 2>/dev/null
        sudo rm -f "$ENABLED_DIR/$file_name" 2>/dev/null
    else
        # 其他风格
        sudo rm -f "$CONF_DIR/$file_name" 2>/dev/null
    fi
}

nginx_reverse_input() {
    # 获取公网 IP 作为默认域名
    local public_ip=$(curl -s --max-time 5 ifconfig.me 2>/dev/null || curl -s --max-time 5 icanhazip.com 2>/dev/null)
    title "设置代理访问的域名或IP"
    read -p "请输入代理访问的 域名 或 IP，回车默认 $public_ip: " SERVER_NAME
    SERVER_NAME=${SERVER_NAME:-$public_ip}

    # 获取监听端口（可选择 80 或 443）
    validate_port "80"

    # 获取要代理的 URL 路径
    while true; do
        read -p "请输入要代理访问的 URL 路径（如 /api，回车默认根路径为 /）: " REQUEST_PATH
        REQUEST_PATH=${REQUEST_PATH:-/}
        if validate_location "$REQUEST_PATH"; then
            [[ "$REQUEST_PATH" != "/" ]] && REQUEST_PATH=$(echo "$REQUEST_PATH" | sed 's:/*$::')
            break
        else
            error "无效路径，必须以 / 开头且不含空格。"
        fi
    done

    # 获取后端服务器列表
    backends=()
    while true; do
        read -p "请输入要代理服务器IP地址和端口号（例如 192.168.1.10:8080），回车跳过: " backend
        if [[ -z "$backend" ]]; then
            [[ ${#backends[@]} -eq 0 ]] && echo -e "${RED}至少需要添加一个代理服务IP地址和端口号。${NC}" || break
        else
            if validate_backend "$backend"; then
                backends+=("$backend")
                success "已添加：$backend"
            else
                error "无效格式，请使用 IP:端口 或 域名:端口 格式。"
            fi
        fi
    done

    # 获取权重
    weights=()
    for i in "${!backends[@]}"; do
        warn "权重越大，代理访问的优先级越高"
        read -p "请输入后端 ${backends[$i]} 的权重（回车默认 1）: " weight
        weights+=("${weight:-1}")
    done

    # ========== HTTPS 配置开始 ==========
    read -p "是否为此反向代理启用 HTTPS？(y/n，默认n): " enable_https
    enable_https=${enable_https:-n}
    ssl_enabled=false
    ssl_cert=""
    ssl_key=""
    http_redirect=false

    if [[ "$enable_https" =~ ^[Yy]$ ]]; then
        ssl_enabled=true
        # 若监听端口不是 443，提示建议使用 443
        if [[ "$LISTEN_PORT" != "443" ]]; then
            warn "提示：HTTPS 通常使用 443 端口，当前监听端口为 $LISTEN_PORT。"
                LISTEN_PORT=443
                success "已改为 443 端口。"
            # read -p "是否将监听端口改为 443？(y/n，默认n): " change_port
            # if [[ "$change_port" =~ ^[Yy]$ ]]; then

            # fi
        fi

        echo "选择证书类型："
        select cert_type in "生成自签名证书" "使用已有证书" "取消"; do
            case $cert_type in
                生成自签名证书)
                    # 生成自签名证书（融合原 selfsigned_ca 逻辑）
                    SSL_DIR="/etc/nginx/ssl"
                    sudo mkdir -p "$SSL_DIR"
                    CERT_KEY="$SSL_DIR/nginx-selfsigned.key"
                    CERT_CRT="$SSL_DIR/nginx-selfsigned.crt"
                    if [[ -f "$CERT_KEY" || -f "$CERT_CRT" ]]; then
                        warn "证书文件已存在，将覆盖生成。"
                        sudo rm -f "$CERT_KEY" "$CERT_CRT"
                    fi
                    title "生成自签名 SSL 证书（有效期 365 天）..."
                    local server_fqdn=$(hostname -f 2>/dev/null || hostname 2>/dev/null || echo "localhost")
                    sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
                        -keyout "$CERT_KEY" \
                        -out "$CERT_CRT" \
                        -subj "/C=CN/ST=Beijing/L=Beijing/O=SelfSigned/CN=$server_fqdn" \
                        -addext "subjectAltName = DNS:$server_fqdn, DNS:localhost, IP:127.0.0.1" >/dev/null 2>&1 &
                    local openssl_pid=$!
                    show_spinner $openssl_pid
                    wait $openssl_pid
                    sudo chmod 600 "$CERT_KEY"
                    sudo chmod 644 "$CERT_CRT"
                    success "证书生成完成: $CERT_CRT 和 $CERT_KEY"
                    ssl_cert="$CERT_CRT"
                    ssl_key="$CERT_KEY"
                    break
                    ;;
                使用已有证书)
                    warn "如果是Cloudflare，选择 源服务器 进行证书申请，加密模式设置为 完全（严格）"
                    read -p "请输入证书文件路径（如 /path/to/cert.pem）: " ssl_cert
                    read -p "请输入私钥文件路径（如 /path/to/cert.key）: " ssl_key
                    if [[ -f "$ssl_cert" && -f "$ssl_key" ]]; then
                        success "证书路径有效"
                        break
                    else
                        error "证书文件或私钥文件不存在，请重新选择。"
                        continue
                    fi
                    ;;
                取消)
                    ssl_enabled=false
                    break
                    ;;
            esac
        done

        if [[ "$ssl_enabled" == true ]]; then
            read -p "是否将 HTTP (80端口) 请求重定向到 HTTPS？(y/n，默认n): " do_redirect
            [[ "$do_redirect" =~ ^[Yy]$ ]] && http_redirect=true
        fi
    fi
    # ========== HTTPS 配置结束 ==========

    # 调用输出函数，传入 SSL 参数
    nginx_reverse_output "$SERVER_NAME" "$REQUEST_PATH" "$LISTEN_PORT" backends weights \
        "$ssl_enabled" "$ssl_cert" "$ssl_key" "$http_redirect"
}

# nginx_reverse_output，支持 SSL
nginx_reverse_output() {
    local SERVER_NAME=$1
    local LOCATION_PATH=$2
    local LISTEN_PORT=$3
    local -n BACKENDS=$4
    local -n WEIGHTS=$5
    local SSL_ENABLED=$6
    local SSL_CERT=$7
    local SSL_KEY=$8
    local HTTP_REDIRECT=$9

    # 清理旧配置
    clean_old_config "$SERVER_NAME" "$LOCATION_PATH" "$LISTEN_PORT"

    # 生成配置文件名（包含协议标识，便于区分）
    local safe_server_name=$(echo "$SERVER_NAME" | tr -c 'a-zA-Z0-9' '_')
    local safe_location=$(echo "$LOCATION_PATH" | tr '/' '_' | sed 's/^_//')
    local proto_suffix=$([[ "$SSL_ENABLED" == true ]] && echo "_https" || echo "_http")
    CONF_BASENAME="reverse_proxy_${safe_server_name}_${safe_location}_${LISTEN_PORT}${proto_suffix}.conf"

    detect_nginx_vhost_dir
    CONF_FILE="$CONF_DIR/$CONF_BASENAME"

    success "生成配置文件：$CONF_FILE"

    # 构建 server 块内容
    local server_block=""

    # 监听端口，若启用 SSL 则加上 ssl 参数
    if [[ "$SSL_ENABLED" == true ]]; then
        server_block+="    listen $LISTEN_PORT ssl http2;\n"
        server_block+="    ssl_certificate $SSL_CERT;\n"
        server_block+="    ssl_certificate_key $SSL_KEY;\n"
        server_block+="    ssl_protocols TLSv1.2 TLSv1.3;\n"
        server_block+="    ssl_ciphers HIGH:!aNULL:!MD5;\n"
    else
        server_block+="    listen $LISTEN_PORT;\n"
    fi

    server_block+="    server_name $SERVER_NAME;\n\n"

    # 构建 location 部分
    local location_block=""
    if [[ ${#BACKENDS[@]} -gt 1 ]]; then
        local UPSTREAM_NAME="backend_${safe_server_name}_${safe_location}_${LISTEN_PORT}"
        location_block+="upstream $UPSTREAM_NAME {\n"
        for i in "${!BACKENDS[@]}"; do
            location_block+="    server ${BACKENDS[$i]} weight=${WEIGHTS[$i]};\n"
        done
        location_block+="}\n\n"
        location_block+="server {\n"
        location_block+="$server_block"
        location_block+="    location $LOCATION_PATH {\n"
        location_block+="        proxy_pass http://$UPSTREAM_NAME;\n"
        location_block+="        proxy_set_header Host \$host;\n"
        location_block+="        proxy_set_header X-Real-IP \$remote_addr;\n"
        location_block+="        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;\n"
        location_block+="        proxy_set_header X-Forwarded-Proto \$scheme;\n"
        location_block+="    }\n"
        location_block+="}\n"
    else
        location_block+="server {\n"
        location_block+="$server_block"
        location_block+="    location $LOCATION_PATH {\n"
        location_block+="        proxy_pass http://${BACKENDS[0]};\n"
        location_block+="        proxy_set_header Host \$host;\n"
        location_block+="        proxy_set_header X-Real-IP \$remote_addr;\n"
        location_block+="        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;\n"
        location_block+="        proxy_set_header X-Forwarded-Proto \$scheme;\n"
        location_block+="    }\n"
        location_block+="}\n"
    fi

    #如果需要 HTTP 重定向，额外生成一个 server 块
    local redirect_block=""
    if [[ "$HTTP_REDIRECT" == true && "$SSL_ENABLED" == true && "$LISTEN_PORT" == "443" ]]; then
        redirect_block="\nserver {\n    listen 80;\n    server_name $SERVER_NAME;\n    return 301 https://\$host\$request_uri;\n}\n"
    fi

    # 写入配置文件
    echo -e "$location_block$redirect_block" | sudo tee "$CONF_FILE" > /dev/null

    # 启用配置（Debian 风格需创建符号链接）
    if [[ -n "$ENABLED_DIR" ]]; then
        sudo ln -sf "$CONF_FILE" "$ENABLED_DIR/$CONF_BASENAME" 2>/dev/null && \
            success "已创建符号链接：$ENABLED_DIR/$CONF_BASENAME -> $CONF_FILE"
    fi

    # 测试 Nginx 配置
    warn "\n测试 Nginx 配置..."
    if sudo nginx -t; then
        success "配置测试通过。"
    else
        error "配置测试失败，请检查配置文件：$CONF_FILE"
        return
    fi

    # 重载 Nginx
    warn "重载 Nginx 服务..."
    if sudo systemctl is-active nginx &> /dev/null; then
        sudo systemctl reload nginx
    else
        sudo systemctl start nginx
    fi

    if sudo systemctl status nginx &> /dev/null; then
        success "Nginx 已成功重载，反向代理配置生效。"
    else
        error "Nginx 启动失败，请检查日志。"
        return
    fi


}

del_nginx_reverse(){
    title "自定删除nginx反向代理配置文件"
    #获取配置文件目录
    detect_nginx_vhost_dir

    # 确认 CONF_DIR 存在且可读
    if [[ ! -d "$CONF_DIR" ]]; then
        error "错误：配置目录 $CONF_DIR 不存在！"
        exit 1
    fi

    # 列出所有 .conf 文件
    mapfile -t conf_files < <(sudo find "$CONF_DIR" -maxdepth 1 -name "*.conf" -type f | sort)

    if [[ ${#conf_files[@]} -eq 0 ]]; then
         warn "在 $CONF_DIR 中没有找到任何 .conf 文件。"
        return
    fi

    info "找到以下 .conf 配置文件："
    for i in "${!conf_files[@]}"; do
        echo "  [$((i+1))] ${conf_files[$i]}"
    done

    # 交互式选择要删除的文件
    read -p  "请输入要删除的配置文件编号（多个编号用空格分隔），或输入 'all' 删除全部，或直接回车取消：" choice
    # 处理输入
    if [[ -z "$choice" ]]; then
        echo "操作已取消。"
        return
    fi

    delete_files=()
    if [[ "$choice" == "all" ]]; then
        delete_files=("${conf_files[@]}")
    else
        for num in $choice; do
            if [[ "$num" =~ ^[0-9]+$ ]] && (( num >= 1 && num <= ${#conf_files[@]} )); then
                delete_files+=("${conf_files[$((num-1))]}")
            else
                error "无效编号: $num，已跳过。"
            fi
        done
    fi

    if [[ ${#delete_files[@]} -eq 0 ]]; then
        info "未选择任何有效文件，退出。"
        return
    fi

    # 显示将要删除的文件并二次确认
    warn "即将删除以下文件："
    for file in "${delete_files[@]}"; do
        info "  $file"
    done

    read -p "确认删除？(y/N)" confirm
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        info "操作已取消。"
        return
    fi

    # 执行删除
    for file in "${delete_files[@]}"; do
        if sudo rm -f "$file"; then
            success "已删除: $file"
            # 如果启用了 sites-enabled 且该文件有对应的符号链接，也尝试删除链接（可选）
            if [[ -n "$ENABLED_DIR" && -L "$ENABLED_DIR/$(basename "$file")" ]]; then
                sudo rm -f "$ENABLED_DIR/$(basename "$file")"
                info "已移除符号链接: $ENABLED_DIR/$(basename "$file")"
                sudo nginx -s reload
            fi
        else
            error "删除失败: $file"
        fi
    done



}
more_nginx_reverse(){
    while true; do
        nginx_reverse_input  
        while true; do
            read -p "是否继续添加反向代理设置（y/n）: " choice
            case "$choice" in
                [yY])
                    break
                    ;;
                [nN])
                    info "退出添加。"
                    # 用户选择退出，跳出内循环并终止外循环
                    break 2
                    ;;
                *)
                    error "无效输入，请输入 y 或 n。"
                    ;;
            esac
        done
    done
}












# ------------- 子菜单功能4 -------------
submenu4() {
    while true; do
        select_menu "安装系统面板管理工具" "Prometheus（普罗米修斯）面板" "哪吒面板（一键安装脚步）" "Komari面板" "Beszel面板" "返回主菜单"
        choice=$?

        case $choice in
            0) clear;prometheus_panel;;
            1) clear;neza_panel ;;
            2) clear;Komari_panel ;;
            3) clear;Beszel_panel ;;
            4) return ;;
        esac
    done
}

prometheus_panel(){
    while true; do
        local prometheus_status=$(check_docker "prometheus")
        echo ""
        select_menu "prometheus（普罗米修斯）面板- 容器状态：$prometheus_status" "安装Prometheus（普罗米修斯）+grafana 面板" "卸载prometheus（普罗米修斯）" "安装node_exporter(上线监测)" "卸载node_exporter" "返回上级菜单"
        choice=$?
        case $choice in
            0) clear;prometheus_install_docker;go_back;;
            1) clear;if sudo docker ps -a --format '{{.Names}}' | grep -qx 'prometheus'; then prometheus_uninstall_docker;else warn "prometheus未安装运行" ;fi ;go_back ;;
            2) clear;node_exporter_install;go_back ;;
            3) clear;if [ -f /usr/local/bin/node_exporter ];then node_exporter_uninstall;else warn "node_exporter未安装运行";fi ;go_back ;;
            4) return ;;
        esac
    done
}
prometheus_install_docker(){
    
    docker_install_sh
    if [ $? -eq 0 ]; then
        clear
        #配置参数
        local NETWORK_NAME="monitoring"
        #数据持久化存储
        BASE_DIR="/tmp/prometheus-stack"
        mkdir -p "$BASE_DIR"/{prometheus,rules,alertmanager,blackbox,grafana}
        mkdir -p "$BASE_DIR/prometheus/targets"
        success "工作目录: $BASE_DIR"

        title "生成配置文件.."
        cat > "$BASE_DIR/prometheus/prometheus.yml" << 'EOF'
global:
  scrape_interval: 15s
  evaluation_interval: 15s

alerting:
  alertmanagers:
    - static_configs:
        - targets: ['alertmanager:9093']

rule_files:
  - "/etc/prometheus/rules/*.yml"

scrape_configs:
  - job_name: 'node-exporter'
    static_configs:
      - targets: ['node-exporter:9100']
    file_sd_configs:
      - files:
          - '/etc/prometheus/targets/nodes.yml'
        refresh_interval: 1m

  - job_name: 'blackbox-exporter'
    metrics_path: /probe
    params:
      module: [http_2xx]
    file_sd_configs:
      - files:
          - '/etc/prometheus/targets/websites.yml'
        refresh_interval: 1m
    relabel_configs:
      - source_labels: [__address__]
        target_label: __param_target
      - source_labels: [__param_target]
        target_label: instance
      - target_label: __address__
        replacement: blackbox-exporter:9115
EOF
        cat > "$BASE_DIR/prometheus/targets/nodes.yml" << 'EOF'
- targets:
    - '192.168.1.10:9100'
  labels:
    env: 'production'
    team: 'ops'

- targets:
    - '192.168.2.50:9100'
  labels:
    env: 'testing'
EOF
        cat > "$BASE_DIR/prometheus/targets/websites.yml" << 'EOF'
- targets:
    - https://www.google.com
    - https://www.github.com
    - http://my-internal-app.local
  labels:
    service: 'public-api'

EOF
        #生成 Alertmanager 配置文件
        cat > "$BASE_DIR/alertmanager/alertmanager.yml" << 'EOF'
route:
  receiver: "null"

receivers:
  - name: "null"
EOF
        #生成 Blackbox Exporter 配置文件
        cat > "$BASE_DIR/blackbox/blackbox.yml" << 'EOF'
modules:
  http_2xx:
    prober: http
    http:
      preferred_ip_protocol: "ip4"
  http_post_2xx:
    prober: http
    http:
      method: POST
  tcp_connect:
    prober: tcp
  icmp:
    prober: icmp
EOF
        success "配置文件生成成功"
        title "创建 Docker 网络"
        if ! sudo docker network ls --format '{{.Name}}' | grep -q "^${NETWORK_NAME}$"; then
            success "创建 Docker 网络: $NETWORK_NAME"
            sudo docker network create "$NETWORK_NAME"
        else
            warn "Docker 网络已存在: $NETWORK_NAME"
        fi
        title "停止并移除已存在的同名容器（避免冲突）"
        containers=("prometheus" "alertmanager" "node-exporter" "blackbox-exporter" "grafana")
        for c in "${containers[@]}"; do
            if sudo docker ps -a --format '{{.Names}}' | grep -q "^${c}$"; then
                success "停止并移除旧容器: $c"
                sudo docker stop "$c" >/dev/null 2>&1 || true
                sudo docker rm "$c" >/dev/null 2>&1 || true
            fi
        done

        title " 创建 Docker 卷（用于持久化数据）"
        volumes=("prometheus-data" "alertmanager-data" "grafana-data")
        for v in "${volumes[@]}"; do
            if ! sudo docker volume ls --format '{{.Name}}' | grep -q "^${v}$"; then
                success "创建 Docker 卷: $v${NC}"
                sudo docker volume create "$v" >/dev/null
            else
                warn "Docker 卷已存在: $v"
            fi
        done
        title "启动 Prometheus 容器..."
        docker run -d \
        --name prometheus \
        --restart unless-stopped \
        --network "$NETWORK_NAME" \
        -p 9090:9090 \
        -v "$BASE_DIR/prometheus/prometheus.yml:/etc/prometheus/prometheus.yml:ro" \
        -v "$BASE_DIR/rules:/etc/prometheus/rules:ro" \
        -v "$BASE_DIR/prometheus/targets:/etc/prometheus/targets:ro" \
        -v prometheus-data:/prometheus \
        prom/prometheus:latest \
        --config.file=/etc/prometheus/prometheus.yml \
        --storage.tsdb.path=/prometheus \
        --storage.tsdb.retention.time=15d \
        --web.enable-lifecycle

        title "启动 Alertmanager 容器..."
        docker run -d \
        --name alertmanager \
        --restart unless-stopped \
        --network "$NETWORK_NAME" \
        -v "$BASE_DIR/alertmanager/alertmanager.yml:/etc/alertmanager/alertmanager.yml:ro" \
        -v alertmanager-data:/alertmanager \
        prom/alertmanager:latest \
        --config.file=/etc/alertmanager/alertmanager.yml

        title "启动 Node Exporter 容器..."
        docker run -d \
        --name node-exporter \
        --restart unless-stopped \
        --network "$NETWORK_NAME" \
        --pid="host" \
        -v /proc:/host/proc:ro \
        -v /sys:/host/sys:ro \
        -v /:/rootfs:ro \
        prom/node-exporter:latest \
        --path.procfs=/host/proc \
        --path.sysfs=/host/sys \
        --path.rootfs=/rootfs \
        --collector.filesystem.mount-points-exclude="^/(sys|proc|dev|host|etc)($$|/)"

        title "启动 Blackbox Exporter 容器..."
        docker run -d \
        --name blackbox-exporter \
        --restart unless-stopped \
        --network "$NETWORK_NAME" \
        -v "$BASE_DIR/blackbox/blackbox.yml:/etc/blackbox_exporter/config.yml:ro" \
        prom/blackbox-exporter:latest \
        --config.file=/etc/blackbox_exporter/config.yml

        title "启动 Grafana 容器..."
        docker run -d \
        --name grafana \
        --restart unless-stopped \
        --network "$NETWORK_NAME" \
        -p 3000:3000 \
        -e GF_SECURITY_ADMIN_USER=admin \
        -e GF_SECURITY_ADMIN_PASSWORD=admin \
        -v grafana-data:/var/lib/grafana \
        grafana/grafana-oss:latest

        
        title "Docker 部署完成！"
        success "Prometheus UI:      http://prometheus:9090(内部访问)"
        success "Alertmanager UI:    http://alertmanager:9093(内部访问)"
        success "Node Exporter:      http://node-exporter:9100(内部访问)"
        success "Blackbox Exporter:  http://blackbox-exporter:9115(内部访问)"
        success "Grafana:            http://$(get_public_ip):3000 (admin/admin)"
        success "工作目录: ${YELLOW}$BASE_DIR${NC}"
        success "配置文件可直接修改，修改后执行以下命令热加载 Prometheus 配置（无需重启）:"
        warn "curl -X POST http://localhost:9090/-/reload"
        warn ""
        warn "查看容器状态: docker ps | grep -E 'prometheus|alertmanager|node-exporter|blackbox|grafana'"
        warn "查看日志: docker logs -f <容器名>"
        warn "为了安全，可以使用 宿主机防火墙 和 反向代理 等技术层面来限制 IP 访问。"

    else
        error "Docker安装失败。"
        
    fi
}

prometheus_uninstall_docker(){
    docker_install_sh
    if [ $? -eq 0 ]; then
        # 默认配置
        NETWORK_NAME="monitoring"
        CONTAINERS=("prometheus" "alertmanager" "node-exporter" "blackbox-exporter" "grafana")
        VOLUMES=("prometheus-data" "alertmanager-data" "grafana-data")
        DEFAULT_BASE_DIR="/tmp/prometheus-stack"

        title "停止并删除容器..."
        for c in "${CONTAINERS[@]}"; do
            if sudo docker ps -a --format '{{.Names}}' | grep -q "^${c}$"; then
                success "删除容器: $c"
                sudo docker stop "$c" >/dev/null 2>&1 || true
                sudo docker rm "$c" >/dev/null 2>&1 || true
            else
                warn "容器不存在: $c"
            fi
        done

        title "删除网络: $NETWORK_NAME"
        if sudo docker network ls --format '{{.Name}}' | grep -q "^${NETWORK_NAME}$"; then
            # 检查是否有容器仍在使用该网络）
            sudo docker network rm "$NETWORK_NAME" >/dev/null 2>&1 && success "网络已删除" ||  error "无法删除网络，可能仍有容器连接或需手动删除"
        else
            warn "网络不存在: $NETWORK_NAME"
        fi

        title "删除 Docker 数据卷...${NC}"
        for v in "${VOLUMES[@]}"; do
            if sudo docker volume ls --format '{{.Name}}' | grep -q "^${v}$"; then
                success "删除卷: $v"
                sudo docker volume rm "$v" >/dev/null 2>&1 && success "已删除" || error "删除卷 $v 失败，可能仍有容器引用"
            else
                warn "卷不存在: $v"
            fi
        done

        title "删除生成的配置文件目录"
        if [ -d "$BASE_DIR" ]; then
            warn "删除配置目录: $BASE_DIR"
            sudo rm -rf "$BASE_DIR"
            success "目录已删除"
        else
            warn "配置目录不存在: $BASE_DIR"
        fi

        success "✅ 卸载完成！"



    else
        error "Docker安装失败。"
        
    fi
}

node_exporter_install(){

    warn "打开浏览器访问https://github.com/prometheus/node_exporter/releases/"
    # 输入下载链接
    while true; do
        read -p "请输入 Node Exporter 文件的下载链接: " NODE_URL
        if [ -z "$NODE_URL" ]; then
            warn "错误：未提供下载链接"
            continue
        fi
        break
    done

    # 下载文件到临时目录
    TEMP_DIR=$(mktemp -d)
    cd "$TEMP_DIR"
    curl -L -o node_exporter.tar.gz "$NODE_URL"

    # 解压文件
    success "正在解压..."
    tar xzf node_exporter.tar.gz

    # 查找 node_exporter 二进制文件（可能位于子目录中）
    BIN_PATH=$(sudo find . -name "node_exporter" -type f -executable | head -n 1)
    if [ -z "$BIN_PATH" ]; then
        error "错误：解压后未找到 node_exporter 二进制文件"
        return
    fi

    # 移动二进制文件到系统路径
    success "安装二进制文件到 /usr/local/bin ..."
    sudo cp "$BIN_PATH" /usr/local/bin/node_exporter
    sudo chmod +x /usr/local/bin/node_exporter

    # 创建 systemd 服务文件
    SERVICE_FILE="/etc/systemd/system/node_exporter.service"
    success "创建 systemd 服务: $SERVICE_FILE"
    sudo cat > "$SERVICE_FILE" <<EOF
[Unit]
Description=Node Exporter
After=network.target

[Service]
User=nobody
Group=nogroup
Type=simple
ExecStart=/usr/local/bin/node_exporter
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

    # 重新加载 systemd，启用并启动服务
    success "配置 systemd 服务..."
    sudo systemctl daemon-reload
    sudo systemctl enable node_exporter
    sudo systemctl start node_exporter

    # 清理临时文件
    echo "清理临时文件..."
    cd /
    sudo rm -rf "$TEMP_DIR"

    success "Node Exporter 安装完成并已启动。"
    sudo systemctl status node_exporter --no-pager


}

node_exporter_uninstall(){
    title "卸载 Node Exporter"
    echo "  - 停止并禁用 node_exporter 服务"
    echo "  - 删除 systemd 服务文件"
    echo "  - 删除 /usr/local/bin/node_exporter 二进制文件"
    echo ""
    read -p "确认卸载？[y/N]: " confirm
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        echo "卸载已取消。"
        return

    fi
    sudo systemctl stop node_exporter
    SERVICE_NAME="node_exporter"
    SERVICE_FILE="/etc/systemd/system/node_exporter.service"

    # 停止并禁用服务（如果存在）
    success "停止 ${SERVICE_NAME} 服务..."
    success systemctl stop node_exporter
    success "禁用开机自启..."
    sudo systemctl disable node_exporter

    # 删除 systemd 服务文件
    if [ -f "$SERVICE_FILE" ]; then
        success "删除服务文件: $SERVICE_FILE"
        sudo rm -f "$SERVICE_FILE"
    else
        warn "服务文件 $SERVICE_FILE 不存在，跳过。"
    fi

    # 重新加载 systemd
    success "重新加载 systemd 配置..."
    sudo systemctl daemon-reload

    # 删除二进制文件
    BIN_PATH="/usr/local/bin/node_exporter"
    if [ -f "$BIN_PATH" ]; then
        success "删除二进制文件: $BIN_PATH"
        sudo rm -f "$BIN_PATH"
    else
        warn "二进制文件 $BIN_PATH 不存在，跳过。"
    fi

    success "Node Exporter 卸载完成。"
}



neza_panel(){
    local nezha_status
    while true; do
        check_service "nezha-dashboard"
        case $? in
            0) nezha_status="服务存在且运行中" ;;
            1) nezha_status="服务存在但未运行" ;;
            2) nezha_status=$(check_docker "nezha-dashboard") ;;
        esac
        select_menu "安装哪吒面板（一键安装脚步）状态：$nezha_status" "安装/卸载哪吒面板（国外）" "安装/卸载哪吒面板（国内）" "卸载哪吒Agent" "返回上级菜单"
        choice=$?

        case $choice in
            0) clear;sudo mkdir -p /tmp/nezha/;sudo curl -L https://raw.githubusercontent.com/nezhahq/scripts/refs/heads/main/install.sh -o /tmp/nezha/nezha.sh && chmod +x /tmp/nezha/nezha.sh && sudo /tmp/nezha/nezha.sh;go_back;;
            1) clear;sudo mkdir -p /tmp/nezha/;sudo curl -L https://gitee.com/naibahq/scripts/raw/main/install.sh -o /tmp/nezha/nezha.sh && chmod +x /tmp/nezha/nezha.sh && sudo CN=true /tmp/nezha/nezha.sh;go_back ;;
            2) clear;if check_service "nezha-agent";then sudo mkdir -p /tmp/nezha/;sudo curl -L https://raw.githubusercontent.com/nezhahq/scripts/main/agent/install.sh -o /tmp/nezha/agent.sh && sudo chmod +x /tmp/nezha/agent.sh && sudo bash /tmp/nezha/agent.sh uninstall;sudo rm -rf /tmp/nezha/agent.sh; else error "哪吒Agent未安装";fi ;go_back ;;
            3) return ;;
        esac
    done
    
}

Komari_panel(){
    local komari_status
    while true; do
        check_service "komari"
        case $? in
            0) komari_status="服务存在且运行中" ;;
            1) komari_status="服务存在但未运行" ;;
            2) komari_status=$(check_docker "komari") ;;
        esac
        select_menu "Komari面板安装指南 状态：$komari_status" "安装Komari面板（docker)" "卸载Komari面板（docker)" "Komari面板(安装卸载一键脚本)" "卸载komari面板的Agent" "返回上级菜单"
        choice=$?
        case $choice in
            0) clear;Komari_install_docker;go_back ;;
            1) clear;if sudo docker ps -a --format '{{.Names}}' | grep -qx 'komari'; then sudo docker stop komari;sudo docker rm komari;sudo rm -rf /tmp/komari/data;success "删除komari容器成功";else warn "komari未安装运行" ;fi ;go_back;;
            2) clear;curl -fsSL https://raw.githubusercontent.com/komari-monitor/komari/main/install-komari.sh -o install-komari.sh;chmod +x install-komari.sh;sudo ./install-komari.sh;go_back ;;
            3) clear; check_service "komari-agent"; if [[ $? -ne 2 ]]; then sudo systemctl stop komari-agent; sudo systemctl disable komari-agent; sudo rm /etc/systemd/system/komari-agent.service; sudo systemctl daemon-reload; sudo rm -rf /opt/komari; else warn "komari-agent未安装运行"; fi; go_back;;
            4) return;;
        esac
    done
}



Komari_install_docker(){
    docker_install_sh
    if [ $? -eq 0 ]; then
        # 获取监听端口
        title "进行Komari面板安装（docker)"
        validate_port "25774"
        sudo mkdir -p "/tmp/komari/data"
        sudo docker run -d \
        -p $LISTEN_PORT:25774 \
        -v /tmp/komari/data:/app/data \
        --name komari \
        --restart=always \
        ghcr.io/komari-monitor/komari:latest
        
        success   "启动komari容器成功"
        title "komari面板访问信息"
        success "打开网址http://$(get_public_ip):$LISTEN_PORT 并登录控制面板。登录凭据如下："
        sudo docker logs komari 2>&1 | grep "Default admin account created" | sed -n 's/.*Username: \(.*\) , Password: \(.*\)/Username: \1\nPassword: \2/p'
    else
        error "Docker安装失败。"
        
    fi
}

Beszel_panel(){
    local beszel_status
    while true; do
        check_service "beszel-hub"
        case $? in
            0) beszel_status="服务存在且运行中" ;;
            1) beszel_status="服务存在但未运行" ;;
            2) beszel_status=$(check_docker "beszel") ;;
        esac
        select_menu "Beszel面板安装指南 状态：$beszel_status" "安装Beszel面板（docker)" "卸载Beszel面板（docker)" "Beszel面板(安装一键脚本)" "卸载Beszel面板的" "卸载Beszel面板的Agent" "返回上级菜单"
        choice=$?

        case $choice in
            0) clear;Beszel_install_docker;go_back ;;
            1) clear;if sudo docker ps -a --format '{{.Names}}' | grep -qx 'beszel'; then sudo docker stop beszel;sudo docker rm beszel;sudo rm -rf /tmp/beszel/beszel_data;success "删除Beszel容器成功";else warn "Beszel未安装运行" ;fi ;go_back;;
            2) clear;Beszel_install_sh;go_back ;;
            3) clear;check_service "beszel-hub"; if [[ $? -ne 2 ]]; then sudo mkdir -p /tmp/Beszel/;sudo curl -sL https://get.beszel.dev/hub -o "/tmp/Beszel/install-hub.sh" && chmod +x "/tmp/Beszel/install-hub.sh" &&sudo bash "/tmp/Beszel/install-hub.sh" -u;success "删除Beszel成功"; else warn "Beszel未安装运行"; fi; go_back;;
            4) clear; check_service "beszel-agent"; if [[ $? -ne 2 ]]; then sudo systemctl stop beszel-agent; sudo systemctl disable beszel-agent; sudo rm /etc/systemd/system/beszel-agent.service; sudo systemctl daemon-reload; sudo rm -rf /tmp/install-agent.sh; else warn "komari-agent未安装运行"; fi; go_back;;
            5) return ;;
        esac
    done
}

Beszel_install_sh(){
    title "Beszel面板(安装一键脚本)"
    validate_port "8090"
    read -p "是否启用每日自动更新？(y/n，默认n): " auto_update
    if [[ "$change_port" =~ ^[Yy]$ ]]; then
        sudo mkdir -p /tmp/Beszel/;sudo curl -sL https://get.beszel.dev/hub -o /tmp/Beszel/install-hub.sh && chmod +x /tmp/Beszel/install-hub.sh && sudo bash /tmp/Beszel/install-hub.sh -p $LISTEN_PORT --auto-update
    else
        sudo mkdir -p /tmp/Beszel/;sudo curl -sL https://get.beszel.dev/hub -o /tmp/Beszel/install-hub.sh && chmod +x /tmp/Beszel/install-hub.sh && sudo bash /tmp/Beszel/install-hub.sh -p $LISTEN_PORT
    fi
    
    title "Beszel面板访问信息"
    success "打开网址http://$(get_public_ip):$LISTEN_PORT 进行登录凭据的创建。"
    warn "卸载agent面板，在安装agent的参数后面加入-u的参数进行卸载。"
}
Beszel_install_docker(){
    docker_install_sh
    if [ $? -eq 0 ]; then
        title "进行Beszel面板安装（docker)"
        
        validate_port "8090"
        sudo mkdir -p "/tmp/beszel/beszel_data"
        sudo docker run -d \
        --name beszel \
        --restart=unless-stopped \
        --volume /tmp/beszel/beszel_data:/beszel_data \
        -e APP_URL=http://$(get_public_ip):$LISTEN_PORT \
        -p $LISTEN_PORT:8090 \
        henrygd/beszel
        
        success   "启动Beszel容器成功"
        title "Beszel面板访问信息"
        success "打开网址http://$(get_public_ip):$LISTEN_PORT 进行登录凭据的创建。"
    else
        error "Docker安装失败,请手动安装"
        
    fi
}




# ------------- 子菜单功能5 -------------

submenu5() {
    while true; do
        select_menu "VPN搭建工具" "安装3x-ui面板" "安装winguard异地组网" "返回主菜单"
        choice=$?
        case $choice in
            0) clear;3xui-panel;;
            1) clear;wireguard_panel ;;
            2) return ;;
        esac
    done
}

3xui-panel(){
    local xui_status
    while true; do
        check_service "x-ui"
        case $? in
            0) xui_status="服务存在且运行中" ;;
            1) xui_status="服务存在但未运行" ;;
            2) xui_status=$(check_docker "3xui_app") ;;
        esac
        
        select_menu "3x-ui面板安装 状态：$xui_status" "安装3x-ui面板(docker)" "卸载3x-ui面板(docker)" "安装3x-ui面板(sh脚步)" "卸载3x-ui面板(sh脚步)"  "返回上级菜单"
        choice=$?
        case $choice in
            0) clear;3xui_docker_install;go_back;;
            1) clear;if sudo docker ps -a --format '{{.Names}}' | grep -qx '3xui_app'; then sudo docker compose -f "/tmp/panel/3xui_compose.yml" down;sudo docker system prune -a;sudo rm -rf "/tmp/panel";success "删除3x-ui容器成功";else warn "3x-ui未安装运行" ;fi ;go_back;;
            2) clear;curl -Ls https://raw.githubusercontent.com/mhsanaei/3x-ui/master/install.sh | sudo bash ;go_back;;
            3) clear;check_service "x-ui" ; if [[ $? -ne 2 ]]; then sudo x-ui uninstall ; else warn "3x-ui未安装运行"; fi; go_back;;
            4) return ;;
        esac
    done
}

3xui_docker_install(){
    docker_install_sh
    if [ $? -eq 0 ]; then
        sudo mkdir -p "/tmp/panel"
        sudo tee "/tmp/panel/3xui_compose.yml" > /dev/null << 'EOF'
services:
  3xui:
    image: ghcr.io/mhsanaei/3x-ui:latest
    container_name: 3xui_app
    # hostname: yourhostname <- optional
    volumes:
      - /tmp/panel/db/:/etc/x-ui/
      - /tmp/panel/cert/:/root/cert/
    environment:
      XRAY_VMESS_AEAD_FORCED: "false"
      XUI_ENABLE_FAIL2BAN: "true"
    tty: true
    network_mode: host
    restart: unless-stopped
EOF
        success "创建docker_compose文件完成"
        sudo docker compose -f "/tmp/panel/3xui_compose.yml" up -d
        get_public_ip
        success   "启动容器成功"
        title "3xui面板访问信息"
        success "打开网址http://$(get_public_ip):2053并登录控制面板。登录凭据如下："
        success "👤 用户名：admin"
        success "🔑 密码：admin"
        warn "登录后，立即在面板设置中更改管理员凭据（Panel Settings > Authentication）"
    else
        error "Docker安装失败。"
        
    fi

}
wireguard_panel(){
    local wg_status
    while true; do
        check_service "wg-quick@"
        case $? in
            0) wg_status="服务存在且运行中" ;;
            1) wg_status="服务存在但未运行" ;;
            2) wg_status=$(check_docker "wg-easy") ;;
        esac
        select_menu "wireguard面板安装 状态：$wg_status" "安装wireguard的WebUI面板(docker)" "卸载wireguard的WebUI面板(docker)"  "安装wireguard的面板(CLI)" "卸载wireguard的面板(CLI)"  "返回主菜单"
        choice=$?
        case $choice in
            0) clear;wireguard_docker_install;go_back;;
            1) clear;if sudo docker ps -a --format '{{.Names}}' | grep -qx 'wg-easy'; then sudo docker compose -f "/tmp/wg-easy/docker-compose.yml" down;sudo docker system prune -a;sudo rm -rf "/tmp/wg-easy";success "删除wg-easy容器成功";else warn "wg-easy未安装运行" ;fi ;go_back;;
            2) clear;wireguard_install;go_back;;
            3) clear;check_service "wg-quick@" ; if [[ $? -ne 2 ]]; then wireguard_uninstall ; else warn "wireguard未安装运行"; fi ; go_back;;
            4) return ;;
        esac
    done
}

wireguard_docker_install(){
    docker_install_sh
    if [ $? -eq 0 ]; then
        sudo mkdir -p "/tmp/wg-easy"
        sudo curl -o "/tmp/wg-easy/docker-compose.yml" https://raw.githubusercontent.com/wg-easy/wg-easy/master/docker-compose.yml
        success "docker_compose文件下载完成"
        sudo docker compose -f "/tmp/wg-easy/docker-compose.yml" up -d
        success   "启动容器成功"
        title "wireguard的WebUI面板访问信息"
        success "打开网址http://$(get_public_ip):51821并登录控制面板。"
        warn "需要设置Nginx的反向代理设置HTTPS才能访问登录"

    else
        echo -e "${RED}Docker安装失败。${NC}"
        
    fi
}
# 获取默认外网接口（用于 NAT）
get_default_interface() {
    local iface
    iface=$(sudo ip route show default | awk '/default/ {print $5; exit}')
    if [[ -z "$iface" ]]; then
        error "无法获取默认路由的外网接口，请手动设置 PostUp/PostDown 中的接口名称。"
    fi
    echo "$iface"
}

# 添加客户端 Peer 到服务器配置（同时写入文件并动态加载）
add_client_peer() {
    local client_index=$1
    local client_public_key=$2
    local client_ip=$3

    # 清理公钥（无换行）
    local clean_pubkey=$(printf "%s" "$client_public_key" | tr -d '\n')

    # 写入配置文件（追加到 /etc/wireguard/wg0.conf）
    sudo cat >> /etc/wireguard/wg0.conf <<EOF

[Peer]
PublicKey = $clean_pubkey
AllowedIPs = $client_ip/32
EOF

    # 动态添加到当前运行的 WireGuard 接口
    sudo wg set wg0 peer "$clean_pubkey" allowed-ips "$client_ip/32"
    success "客户端 $client_index 已添加到服务器配置，IP: $client_ip"
}
# 生成服务器基础配置并返回公钥（不包含 Peer）
generate_server_base_config() {
    local server_ip_cidr=$1
    local listen_port=$2
    local server_private_key=$(sudo wg genkey)
    local server_public_key=$(printf "%s" "$server_private_key" | wg pubkey | tr -d '\n')

    sudo mkdir -p /etc/wireguard
    local config_file="/etc/wireguard/wg0.conf"

    # 获取外网接口
    local ext_iface=$(get_default_interface)

    # 写入配置，PostUp/PostDown 使用正确的 NAT 规则
    sudo cat > "$config_file" <<EOF
[Interface]
Address = $server_ip_cidr
ListenPort = $listen_port
PrivateKey = $server_private_key
PostUp = iptables -A FORWARD -i %i -j ACCEPT; iptables -A FORWARD -o %i -j ACCEPT; iptables -t nat -A POSTROUTING -s ${server_ip_cidr%/*}/24 -o $ext_iface -j MASQUERADE
PostDown = iptables -D FORWARD -i %i -j ACCEPT; iptables -D FORWARD -o %i -j ACCEPT; iptables -t nat -D POSTROUTING -s ${server_ip_cidr%/*}/24 -o $ext_iface -j MASQUERADE
EOF

    sudo echo "$server_public_key" > /etc/wireguard/server_public.key
    sudo echo "$server_private_key" > /etc/wireguard/server_private.key
    sudo chmod 600 /etc/wireguard/*.key

    success "服务器配置文件已生成: $config_file"
    success "服务器公钥: $server_public_key"

    # 只输出公钥到 stdout（无换行符）
    printf "%s" "$server_public_key" | tr -d '\n'
}
# 启动 WireGuard 接口（如果已存在则先关闭）
start_wireguard() {
    if sudo wg show wg0 &>/dev/null; then
        warn "WireGuard 接口 wg0 已存在，正在关闭..."
        sudo wg-quick down wg0 || true
    fi
    info "正在启动 WireGuard 接口..."
    sudo wg-quick up wg0 || error "启动 wg0 失败，请检查配置。"
    sudo systemctl enable wg-quick@wg0 2>/dev/null || true
    success "WireGuard 接口已启动。"
}
# 生成客户端配置（包含二维码），并返回客户端公钥
generate_client_config() {
    local client_index=$1
    local client_ip=$2
    local server_public_key=$3
    local server_endpoint=$4
    local server_port=$5
    local dns=$6

    local client_private_key=$(sudo wg genkey)
    local client_public_key=$(printf "%s" "$client_private_key" | sudo wg pubkey | tr -d '\n')
    local config_file="client${client_index}.conf"
    local png_file="client${client_index}.png"

    # 清理服务器公钥
    local clean_server_pubkey=$(printf "%s" "$server_public_key" | tr -d '\n')

    sudo cat > "$config_file" <<EOF
[Interface]
PrivateKey = $client_private_key
Address = $client_ip/32
DNS = $dns

[Peer]
PublicKey = $clean_server_pubkey
Endpoint = $server_endpoint:$server_port
AllowedIPs = 0.0.0.0/0
EOF

    success "客户端 $client_index 配置已生成: $config_file"

    if command -v qrencode &>/dev/null; then
        success "客户端 $client_index 二维码已生成\n"
        qrencode -t ansiutf8 < "$config_file" >&2
    else
        warn "未找到 qrencode，跳过二维码生成。"
    fi

    # 返回客户端公钥（无换行）
    printf "%s" "$client_public_key" | tr -d '\n'
}



# ------------- 子菜单功能6 -------------
submenu6() {
    while true; do
        select_menu "网络安全工具" "信息收集" "网站防御" "返回主菜单"
        choice=$?
        case $choice in
            0) clear;sleep 1;;
            1) clear;submenu6-2 ;;
            2) return ;;
        esac
    done
}

submenu6-2(){
    while true; do
        select_menu "网站防御" "Cloudflare + Nginx + fail2ban  静态IP封禁(外防御)" "Cloudflare + Nginx + Lua + Redis 动态IP封禁(内防御)" "返回上级菜单"
        choice=$?
        case $choice in
            0) clear;cf_fail2ban_panel;;
            1) clear;cf_lua_redis_panel;;
            2) return ;;
        esac
    done
}

cf_fail2ban_panel(){
    local cf_fail2ban_status
    while true; do
        check_service "fail2ban"
        case $? in
            0) cf_fail2ban_status="服务存在且运行中" ;;
            1) cf_fail2ban_status="服务存在但未运行" ;;
            2) cf_fail2ban_status=$(check_docker "fail2ban") ;;
        esac
        select_menu "Cloudflare + Nginx + fail2ban防御 状态：$cf_fail2ban_status" "安装并运行" "查看监狱小黑屋" "解封IP地址" "卸载清理"  "返回上级菜单"
        choice=$?
        case $choice in
            0) clear;cf_fail2ban_install;go_back;;
            1) clear;if check_cmd "fail2ban-client"; then  title "查看特定监狱的封禁状态"; sudo fail2ban-client status nginx-limit  ;else warn "fail2ban未安装运行" ;fi ;go_back;;
            2) clear;if check_cmd "fail2ban-client"; then unblock_ip ;else warn "fail2ban未安装运行" ;fi ;go_back;;
            3) clear;if check_cmd "fail2ban-client"; then cf_fail2ban_uninstall ;else warn "fail2ban未安装运行" ;fi ;go_back;;
            4) return ;;
        esac
    done
}

cf_fail2ban_install(){
    if check_cmd "nginx" && check_cmd "fail2ban" && check_cmd "jq" && check_cmd "curl"  ; then
        success "所需的依赖工具已存在"
    else
        local -A MY_PKG_MAP=(
            ["nginx"]="nginx"
            ["fail2ban-client"]="fail2ban"
            ["jq"]="jq"
            ["curl"]="curl"
        )
        check_and_install_tools MY_PKG_MAP "nginx" "fail2ban-client" "jq" "curl"
    fi
    
    info "正在获取 Cloudflare IP 列表..."
    CF_IPV4=$(curl -s https://www.cloudflare.com/ips-v4)
    CF_IPV6=$(curl -s https://www.cloudflare.com/ips-v6)
    if [[ -z "$CF_IPV4" ]]; then
        error "无法获取 Cloudflare IP，请检查网络连接"
    
    else
        info "正在配置 Nginx Real IP 模块 (开启递归模式)..."
        NGINX_CONF="/etc/nginx/nginx.conf"
        if sudo grep -q "real_ip_header CF-Connecting-IP" "$NGINX_CONF"; then
            warn "Nginx 似乎已配置 Cloudflare real_ip，跳过修改"
        else
            # 备份
            sudo cp "$NGINX_CONF" "${NGINX_CONF}.bak"

            # 生成配置内容
            REAL_IP_CONF="    # Cloudflare Real IP Configuration\n"
            for ip in $CF_IPV4; do REAL_IP_CONF+="    set_real_ip_from $ip;\n"; done
            for ip in $CF_IPV6; do REAL_IP_CONF+="    set_real_ip_from $ip;\n"; done
            REAL_IP_CONF+="    real_ip_header CF-Connecting-IP;\n"
            REAL_IP_CONF+="    real_ip_recursive on;\n"

            # 检查是否已存在配置，存在则先清理
            sudo sed -i '/Cloudflare IP ranges/,/real_ip_recursive/d' "$NGINX_CONF"
            
            # 插入到 http 模块内
            sudo sed -i "/http {/a $REAL_IP_CONF" "$NGINX_CONF"
            
            sudo nginx -t && sudo nginx -s reload
            success "Nginx 配置更新成功并已重启"
        fi
        # 获取 CF API 凭证
        warn "请输入 Cloudflare API Token (需 Firewall 权限):"
        read -p "Token: " CF_API_TOKEN
        echo
        echo -e "${YELLOW}请输入防御域名的 Zone ID:${NC}"
        read -p "Zone ID: " CF_ZONE_ID
        
        # 简单验证
        if [[ ${#CF_API_TOKEN} -lt 10 || ${#CF_ZONE_ID} -lt 10 ]]; then
            error "凭证格式似乎不正确"

        else
            info "正在配置 Fail2ban 动作与白名单..."
            #创建 Action
            sudo cat > /etc/fail2ban/action.d/cloudflare.conf <<EOF
[Definition]
actionban = curl -s -o /dev/null -X POST "https://api.cloudflare.com/client/v4/zones/$CF_ZONE_ID/firewall/access_rules/rules" \\
            -H "Authorization: Bearer $CF_API_TOKEN" \\
            -H "Content-Type: application/json" \\
            --data '{"mode":"block","configuration":{"target":"ip","value":"<ip>"},"notes":"Fail2ban"}'

actionunban = RULE_ID=\$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones/$CF_ZONE_ID/firewall/access_rules/rules?configuration_target=ip&configuration_value=<ip>" \\
              -H "Authorization: Bearer $CF_API_TOKEN" \\
              -H "Content-Type: application/json" | jq -r '.result[0].id') && \\
              if [ "\$RULE_ID" != "null" ]; then \\
              curl -s -o /dev/null -X DELETE "https://api.cloudflare.com/client/v4/zones/$CF_ZONE_ID/firewall/access_rules/rules/\$RULE_ID" \\
              -H "Authorization: Bearer $CF_API_TOKEN" \\
              -H "Content-Type: application/json"; fi
EOF

            # 准备白名单 (ignoreip)
            # 将所有的 CF IP 转换为空格分隔的一行
            WHITELIST=$(sudo echo $CF_IPV4 $CF_IPV6 | tr '\n' ' ')
            
            # 写入 jail.local
            JAIL_CONF="/etc/fail2ban/jail.local"
            # 确保 [DEFAULT] 存在并设置 ignoreip
            if ! grep -q "\[DEFAULT\]" "$JAIL_CONF" 2>/dev/null; then
                echo -e "[DEFAULT]\n" > "$JAIL_CONF"
                success "$JAIL_CONF文件创建完成"
            fi
            
            # 更新 ignoreip，包含本地 IP 和 CF 所有节点
            sudo sed -i "/^ignoreip =/d" "$JAIL_CONF"
            sudo sed -i "/\[DEFAULT\]/a ignoreip = 127.0.0.1/8 ::1 $WHITELIST" "$JAIL_CONF"

            # 添加针对 Nginx 的 Jail
            sudo cat >> "$JAIL_CONF" <<EOF

[nginx-limit]
enabled = true
filter = nginx-limit
action = cloudflare
         iptables-multiport[name=nginx, port="http,https"]
logpath = /var/log/nginx/access.log
backend = polling
findtime = 600
maxretry = 10
bantime = 3600
EOF

            #创建过滤器
            sudo cat > /etc/fail2ban/filter.d/nginx-limit.conf <<EOF
[Definition]
failregex = ^<HOST> -.*"(GET|POST|PUT|DELETE|HEAD).*HTTP.*" (400|403|404|444|429) .*$
ignoreregex =
EOF

            sudo systemctl restart fail2ban
            success "Fail2ban 配置已完成，Cloudflare IP 已加入白名单保护"
        fi


    fi

}


unblock_ip(){
    while true; do
        title "解封Fail2ban监狱中IP地址"
        read -p "请输入要解封IP地址，回车确认/跳过: " unblock
        if [[ -z "$unblock" ]]; then
            break
        fi

        # IPv4 格式校验
        if [[ ! "$unblock" =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
            error "无效IP地址格式: $unblock"
            continue
        fi

        # 执行解封命令
        if sudo fail2ban-client set nginx-limit unbanip "$unblock" >/dev/null 2>&1; then
            success "解封的IP地址：$unblock"
        else
            error "解封失败，IP地址可能不在监狱中或命令执行错误: $unblock"
        fi
    done
}
cf_fail2ban_uninstall(){
    title "卸载Fail2ban"
    info "正在还原 Nginx 配置..."
    local nginx_conf="/etc/nginx/nginx.conf"
    # 备份
    sudo cp "$nginx_conf" "${nginx_conf}.uninstall.bak"
    info "已备份到 ${nginx_conf}.uninstall.bak"

    info "删除Cloudflare地址段内容"
    sudo sed -i '/# Cloudflare Real IP Configuration/,/real_ip_recursive on;/d' "$nginx_conf"

    info "Nginx 配置已还原并重载"
    sudo nginx -s reload
    

    info "停止 Fail2ban服务..."
    systemctl stop fail2ban 2>/dev/null || true
    systemctl disable fail2ban 2>/dev/null || true

    info "卸载 Fail2ban软件"
    sudo apt-get purge fail2ban -y

    info "删除残留目录"
    sudo rm -rf /etc/fail2ban /var/lib/fail2ban /var/log/fail2ban

    info "清理 iptables 中的 fail2ban 残留规则..."
    if ! check_cmd iptables &>/dev/null; then
        info "iptables 未安装，跳过"
    
    else
        local chains=$(sudo iptables -L 2>/dev/null | grep -E '^Chain fail2ban-' | awk '{print $2}')
        if [[ -z "$chains" ]]; then
            info "未发现残留的 fail2ban 链"

        else
            for chain in $chains; do
                info "刷新并删除链: $chain"
                sudo iptables -F "$chain" 2>/dev/null || true
                sudo iptables -X "$chain" 2>/dev/null || true
            done
            # 删除可能存在的引用规则（从 INPUT 链中）
            sudo iptables -L INPUT -n --line-numbers 2>/dev/null | grep fail2ban | awk '{print $1}' | sort -r | while read num; do
                sudo iptables -D INPUT "$num" 2>/dev/null || true
            done
        fi
    fi

    success "卸载完成"

}

cf_lua_redis_panel(){
    local cf_lua_redis_status
    while true; do
        if redis-cli ping > /dev/null 2>&1 && \
        [ -f "/etc/nginx/lua/ip_ban.lua" ] && \
        [ -f "/etc/nginx/lua/config.lua" ]; then
            cf_lua_redis_status="服务运行中"
        else
            cf_lua_redis_status="不存在"
        fi
        select_menu "Cloudflare + Nginx + Lua + Redis 动态IP封禁 状态：$cf_lua_redis_status" "安装并运行" "查看监狱小黑屋" "解封IP地址" "卸载清理"  "返回上级菜单"
        choice=$?
        case $choice in
            0) clear;cf_lua_redis_install;go_back;;
            1) clear;if redis-cli ping > /dev/null 2>&1 && [ -f "/etc/nginx/lua/ip_ban.lua" ] && [ -f "/etc/nginx/lua/config.lua" ]; then redis-cli KEYS "ban:*";else warn "未安装" ;fi ;go_back;;
            2) clear;if redis-cli ping > /dev/null 2>&1 && [ -f "/etc/nginx/lua/ip_ban.lua" ] && [ -f "/etc/nginx/lua/config.lua" ]; then unblock_lua_redis_ip;else warn "未安装" ;fi ;go_back;;
            3) clear;if redis-cli ping > /dev/null 2>&1 && [ -f "/etc/nginx/lua/ip_ban.lua" ] && [ -f "/etc/nginx/lua/config.lua" ]; then cf_lua_redis_uninstall;else warn "未安装" ;fi ;go_back;;
            4) return ;;
        esac
    done
}



cf_lua_redis_install(){
    local NGINX_MAIN_CONF="/etc/nginx/nginx.conf"
    local NGINX_CONF_DIR="/etc/nginx/conf.d"
    local LUA_DIR="/etc/nginx/lua"
    local LUA_LIB_DIR="$LUA_DIR/resty"
    local LUA_FILE="$LUA_DIR/ip_ban.lua"
    local LUA_CONFIG="$LUA_DIR/config.lua"
    local CF_CONF="$LUA_DIR/cloudflare_realip.conf"
    local WHITELIST_CONF="$LUA_DIR/whitelist.txt"
    # 封禁策略 (可根据实际调整)
    local FAST_LIMIT=20          # 短窗口阈值 (2秒)
    local SLOW_LIMIT=30          # 长窗口阈值 (60秒)
    local BAN_TTL=3600           # 封禁时长 (秒)
    local CACHE_TTL=60           # 本地缓存黑名单时间 (秒)
    # 降级开关 (Redis故障时仅依赖本地缓存)
    local REDIS_FAIL_OPEN=true   # true=Redis故障时放行，false=则拒绝所有请求(保守)
    local install_status=false
    #安装依赖
    title "安装依赖"
    case "$(detect_os)" in
        debian|ubuntu)
            local -A MY_PKG_MAP=(
                ["nginx-extras"]="nginx-extras"
                ["redis-server"]="redis-server"
            )
            check_and_install_tools MY_PKG_MAP "nginx-extras" "redis-server"
            sudo systemctl enable redis-server nginx
            NGINX_SERVICE="nginx"
            REDIS_SERVICE="redis-server"
            REDIS_CONF="/etc/redis/redis.conf"
            install_status=true
            ;;
        centos|rhel|rocky|almalinux)
            local INSTALL="sudo yum install -y"
            # 安装 EPEL
            $INSTALL epel-release
            
            # 检测 CentOS 版本
            if [[ "$OS_VERSION_ID" =~ ^7 ]]; then
                $INSTALL https://openresty.org/package/centos/7/openresty.repo
            elif [[ "$OS_VERSION_ID" =~ ^8 ]]; then
                $INSTALL https://openresty.org/package/centos/8/openresty.repo
            elif [[ "$OS_VERSION_ID" =~ ^9 ]]; then
                $INSTALL https://openresty.org/package/centos/9/openresty.repo
            else
                warn "未知 CentOS 版本，尝试使用 CentOS 7 仓库"
                $INSTALL https://openresty.org/package/centos/7/openresty.repo
            fi
            
            $INSTALL openresty redis wget curl
            
            # 尝试安装 lua-resty-redis，失败则手动下载
            if ! $INSTALL lua-resty-redis 2>/dev/null; then
                warn "yum 安装 lua-resty-redis 失败，将手动下载"
            fi
            
            sudo systemctl enable redis openresty
            NGINX_SERVICE="openresty"
            REDIS_SERVICE="redis"
            REDIS_CONF="/etc/redis.conf"
            if [ ! -f "$REDIS_CONF" ] && [ -f /etc/redis/redis.conf ]; then
                REDIS_CONF="/etc/redis/redis.conf"
            fi
            
            # 创建软链接以便使用 nginx 命令（可选）
            if [ ! -f /usr/sbin/nginx ] && [ -f /usr/local/openresty/nginx/sbin/nginx ]; then
                sudo ln -sf /usr/local/openresty/nginx/sbin/nginx /usr/sbin/nginx
            fi
            install_status=true
            ;;
        *)
            error "不支持的操作系统: $(detect_os)"
            ;;
    esac
    if [ "$install_status" = true ];then
        info "部署 lua-resty-redis 库..."
        sudo mkdir -p "$LUA_LIB_DIR"
        if [ ! -f "$LUA_LIB_DIR/redis.lua" ]; then
            sudo wget -qO "$LUA_LIB_DIR/redis.lua" \
                https://raw.githubusercontent.com/openresty/lua-resty-redis/master/lib/resty/redis.lua
        fi

        info "生成 Lua 配置文件..."
        sudo cat > "$LUA_CONFIG" <<EOF
-- IP 封禁 Lua 配置文件
local _M = {}
_M.fast_limit = $FAST_LIMIT
_M.slow_limit = $SLOW_LIMIT
_M.ban_ttl = $BAN_TTL
_M.cache_ttl = $CACHE_TTL
_M.whitelist_file = "$WHITELIST_CONF"
_M.redis_fail_open = $([ "$REDIS_FAIL_OPEN" = true ] && echo "true" || echo "false")
return _M
EOF
        info "需要修改封禁策略，请修改$LUA_CONFIG的文件"

        if [ ! -f "$WHITELIST_CONF" ]; then
        info "创建白名单模板文件: $WHITELIST_CONF"
        sudo cat > "$WHITELIST_CONF" <<EOF
# 白名单IP列表，每行一个 (支持CIDR，如 192.168.1.0/24)
# 127.0.0.1
EOF
        fi

        info "生成 Lua 拦截脚本 (支持白名单、降级、子请求过滤)..."
        sudo cat > "$LUA_FILE" <<'LUAEOF'
local config = require "config"
local redis = require "resty.redis"
local bit = require "bit"  -- 引入位运算库

local cache = ngx.shared.ip_ban_cache
local client_ip = ngx.req.get_headers()["CF-Connecting-IP"] or ngx.var.remote_addr

-- 过滤子请求和内部重定向
if ngx.is_subrequest or ngx.req.is_internal() then
    return
end

-- 简单的 IP/CIDR 白名单匹配
local function ip_in_cidr(ip, cidr)
    local cidr_parts = {}
    for part in string.gmatch(cidr, "[^/]+") do
        table.insert(cidr_parts, part)
    end
    if #cidr_parts ~= 2 then return ip == cidr end
    
    local cidr_ip = cidr_parts[1]
    local mask = tonumber(cidr_parts[2])
    if not mask then return ip == cidr end
    
    local function ip_to_bits(ip_str)
        local bits = {}
        for octet in string.gmatch(ip_str, "%d+") do
            local num = tonumber(octet)
            for i = 7, 0, -1 do
                -- 修改此处：使用 bit.band 和 bit.rshift 代替 & 和 >>
                table.insert(bits, bit.band(bit.rshift(num, i), 1))
            end
        end
        return bits
    end
    
    local ip_bits = ip_to_bits(ip)
    local cidr_bits = ip_to_bits(cidr_ip)
    
    for i = 1, mask do
        if ip_bits[i] ~= cidr_bits[i] then
            return false
        end
    end
    return true
end

local function is_whitelisted(ip)
    local whitelist = config.whitelist
    if not whitelist then
        local file = io.open(config.whitelist_file, "r")
        if file then
            whitelist = {}
            for line in file:lines() do
                line = line:match("^%s*(.-)%s*$")
                if line and not line:match("^#") and line ~= "" then
                    table.insert(whitelist, line)
                end
            end
            file:close()
            config.whitelist = whitelist
        else
            config.whitelist = {}
        end
    end
    for _, entry in ipairs(config.whitelist) do
        if entry:find("/") then
            if ip_in_cidr(ip, entry) then return true end
        elseif entry == ip then
            return true
        end
    end
    return false
end

if is_whitelisted(client_ip) then
    return
end

-- 本地缓存检查
if cache:get(client_ip) == 1 then
    ngx.exit(403)
end

local red = redis:new()
red:set_timeouts(200, 200, 200)
local ok, err = red:connect("127.0.0.1", 6379)

if not ok then
    ngx.log(ngx.WARN, "[BAN] Redis connection failed: ", err)
    if not config.redis_fail_open then
        ngx.exit(403)
    end
    return
end

local is_banned, _ = red:get("ban:" .. client_ip)
if is_banned ~= ngx.null then
    cache:set(client_ip, 1, config.cache_ttl)
    red:set_keepalive(10000, 100)
    ngx.exit(403)
end

local fast_key = "f_cnt:" .. client_ip
local slow_key = "s_cnt:" .. client_ip
local fast_val, _ = red:incr(fast_key)
local slow_val, _ = red:incr(slow_key)

if fast_val == 1 then red:expire(fast_key, 2) end
if slow_val == 1 then red:expire(slow_key, 60) end

local banned = false
if fast_val > config.fast_limit then
    banned = true
    ngx.log(ngx.ERR, "[BAN] BURST (", fast_val, "/", config.fast_limit, ") ", client_ip)
elseif slow_val > config.slow_limit then
    banned = true
    ngx.log(ngx.ERR, "[BAN] SUSTAINED (", slow_val, "/", config.slow_limit, ") ", client_ip)
end

if banned then
    red:setex("ban:" .. client_ip, config.ban_ttl, "1")
    cache:set(client_ip, 1, config.cache_ttl)
    red:set_keepalive(10000, 100)
    ngx.exit(403)
end

red:set_keepalive(10000, 100)
LUAEOF
        info "生成 Cloudflare 真实IP配置文件..."
        sudo cat > "$CF_CONF" <<EOF
# Cloudflare IP 列表 (由脚本每日更新)
set_real_ip_from 103.21.244.0/22;
set_real_ip_from 103.22.200.0/22;
set_real_ip_from 103.31.4.0/22;
set_real_ip_from 104.16.0.0/13;
set_real_ip_from 104.24.0.0/14;
set_real_ip_from 108.162.192.0/18;
set_real_ip_from 131.0.72.0/22;
set_real_ip_from 141.101.64.0/18;
set_real_ip_from 162.158.0.0/15;
set_real_ip_from 172.64.0.0/13;
set_real_ip_from 173.245.48.0/20;
set_real_ip_from 188.114.96.0/20;
set_real_ip_from 190.93.240.0/20;
set_real_ip_from 197.234.240.0/22;
set_real_ip_from 198.41.128.0/17;
set_real_ip_from 2400:cb00::/32;
set_real_ip_from 2606:4700::/32;
real_ip_header CF-Connecting-IP;
EOF
        info "注入全局拦截钩子到 Nginx 主配置..."
        sudo sed -i '/lua_shared_dict/d' "$NGINX_MAIN_CONF"
        sudo sed -i '/lua_package_path/d' "$NGINX_MAIN_CONF"
        sudo sed -i '/access_by_lua_file/d' "$NGINX_MAIN_CONF"
        sudo sed -i "/cloudflare_realip.conf/d" "$NGINX_MAIN_CONF"
        sudo sed -i "/http {/a \    lua_package_path \"$LUA_DIR/?.lua;;\";\n    lua_shared_dict ip_ban_cache 20m;\n    include $CF_CONF;\n    access_by_lua_file $LUA_FILE;" "$NGINX_MAIN_CONF"
        info "配置 Redis 内存限制 (200MB, LRU)..."
        if [ -f "$REDIS_CONF" ]; then
            if ! grep -q "maxmemory 200mb" "$REDIS_CONF"; then
                echo "maxmemory 200mb" >> "$REDIS_CONF"
                echo "maxmemory-policy allkeys-lru" >> "$REDIS_CONF"
                sudo systemctl restart "$REDIS_SERVICE"
            fi
        else
            warn "未找到 Redis 配置文件，跳过内存限制设置"
        fi
        info "配置 Cloudflare IP 每日自动更新 (cron job)..."
        sudo cat > /usr/local/bin/update_cf_ips.sh <<EOF
#!/bin/bash
CF_IPV4_URL="https://www.cloudflare.com/ips-v4"
CF_IPV6_URL="https://www.cloudflare.com/ips-v6"
CF_CONF="$CF_CONF"
TMP_CONF="\${CF_CONF}.tmp"

echo "# Cloudflare IP list - Updated \$(date)" > \$TMP_CONF
for url in \$CF_IPV4_URL \$CF_IPV6_URL; do
    curl -s \$url | while read ip; do
        echo "set_real_ip_from \$ip;" >> \$TMP_CONF
    done
done
echo "real_ip_header CF-Connecting-IP;" >> \$TMP_CONF

if [ -s \$TMP_CONF ]; then
    mv \$TMP_CONF \$CF_CONF
    systemctl reload $NGINX_SERVICE
    echo "\$(date): Cloudflare IPs updated" >> /var/log/cf_ip_updater.log
else
    rm -f \$TMP_CONF
    echo "ERROR: Failed to fetch CF IPs" >> /var/log/cf_ip_updater.log
fi
EOF
        sudo chmod +x /usr/local/bin/update_cf_ips.sh
        sudo crontab -l 2>/dev/null | grep -v update_cf_ips.sh | crontab - 2>/dev/null || true
        (sudo crontab -l 2>/dev/null; echo "0 3 * * * /usr/local/bin/update_cf_ips.sh") | crontab -
        /usr/local/bin/update_cf_ips.sh
        info "启动并验证服务..."
        sudo systemctl restart "$REDIS_SERVICE"
        if nginx -t 2>/dev/null || /usr/local/openresty/nginx/sbin/nginx -t 2>/dev/null; then
            sudo systemctl restart "$NGINX_SERVICE"
            success "✅ 部署成功！"
            echo "------------------------------------------------"
            echo "策略: 2秒内超过${FAST_LIMIT}次 或 60秒内超过${SLOW_LIMIT}次 -> 封禁${BAN_TTL}秒"
            echo "白名单文件: $WHITELIST_CONF"
            echo "封禁管理: redis-cli -> KEYS \"ban:*\" , DEL \"ban:<IP>\""
            echo "------------------------------------------------"
        else
            error "Nginx 配置测试失败，回滚中..."
            sudo sed -i '/lua_package_path/d' "$NGINX_MAIN_CONF"
            sudo sed -i '/lua_shared_dict/d' "$NGINX_MAIN_CONF"
            sudo sed -i '/access_by_lua_file/d' "$NGINX_MAIN_CONF"
            sudo systemctl restart "$NGINX_SERVICE"
        fi
    else
        warn "安装依赖有问题"
    fi


}

unblock_lua_redis_ip(){
    while true; do
        title "解封redis监狱中IP地址"
        read -p "请输入要解封IP地址，回车确认/跳过: " unblock
        if [[ -z "$unblock" ]]; then
            break
        fi

        # IPv4 格式校验
        if [[ ! "$unblock" =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
            error "无效IP地址格式: $unblock"
            continue
        fi

        # 执行解封命令
        if sudo redis-cli DEL "ban:$unblock" 2>&1; then
            success "解封的IP地址：$unblock"
        else
            error "解封失败，IP地址可能不在监狱中或命令执行错误: $unblock"
        fi
    done
}

cf_lua_redis_uninstall(){
    local NGINX_MAIN_CONF="/etc/nginx/nginx.conf"
    local LUA_DIR="/etc/nginx/lua"
    local CF_CONF="$LUA_DIR/cloudflare_realip.conf"
    warn "开始卸载 IP 封禁系统..."
    # 1. 恢复 Nginx 配置
    info "移除 Nginx 配置注入..."
    sudo sed -i '/lua_package_path/d' "$NGINX_MAIN_CONF"
    sudo sed -i '/lua_shared_dict/d' "$NGINX_MAIN_CONF"
    sudo sed -i '/access_by_lua_file/d' "$NGINX_MAIN_CONF"
    sudo sed -i "/cloudflare_realip.conf/d" "$NGINX_MAIN_CONF"
    
    # 2. 删除生成的文件
    info "删除 Lua 脚本、配置文件..."
    sudo rm -rf "$LUA_DIR" "$CF_CONF"
    
    # 3. 移除定时任务
    info "移除 Cloudflare IP 更新定时任务..."
    sudo crontab -l 2>/dev/null | grep -v update_cf_ips.sh | crontab - 2>/dev/null || true
    sudo rm -f /usr/local/bin/update_cf_ips.sh
    
    # 4. 询问是否移除软件包
    read -p "是否移除 redis-server 和 nginx-extras? (y/N): " -r
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        if [ "$OS_FAMILY" = "debian" ]; then
            sudo apt-get remove --purge -y nginx-extras redis-server
            sudo apt-get autoremove -y
        else
            sudo yum remove -y openresty redis
            sudo yum autoremove -y
        fi
    else
        info "保留软件包，仅移除封禁配置"
    fi
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        sudo apt-get remove --purge -y redis-server nginx-extras
        sudo apt-get autoremove -y
    else
        info "保留 redis-server 和 nginx-extras，可手动管理"
    fi
    
    systemctl restart nginx
    info "✅ 卸载完成。"
}





# ------------- 子菜单功能7 -------------

submenu7() {
    while true; do
        select_menu "其他扩展工具" "API密钥管理相关" "返回主菜单"
        choice=$?
        case $choice in
            0) clear;submenu7-1;;
            1) return ;;
        esac
    done
}

submenu7-1(){
    while true; do
        select_menu "API密钥管理相关" "CLIProxyAPI" "返回主菜单"
        choice=$?
        case $choice in
            0) clear;cliproxyapi_panel;;
            1) return ;;
        esac
    done
}

cliproxyapi_panel(){
    local cliproxyapi_status
    while true; do
        if systemctl --user is-active --quiet cliproxyapi; then
            cliproxyapi_status="运行中"
        elif systemctl --user list-unit-files | grep -q '^cliproxyapi.service'; then
            cliproxyapi_status="已停止"
        else
            cliproxyapi_status="未安装"
        fi
        select_menu "CLIProxyAPI 状态：$cliproxyapi_status" "安装并运行(一键脚本)"  "卸载cliproxyapi(sh)" "返回上级菜单"
        choice=$?
        case $choice in
            0) clear; cliproxyapi_install_sh ;go_back;;
            1) clear;if systemctl --user is-active --quiet cliproxyapi; then  cliproxyapi_uninstall_sh ;else warn "cliproxyapi未安装运行" ;fi ;go_back;;
            2) return ;;
        esac
    done
}

cliproxyapi_install_sh(){
    title "安装 cliproxyapi ..." 
    curl -fsSL https://raw.githubusercontent.com/brokechubb/cliproxyapi-installer/refs/heads/master/cliproxyapi-installer | bash 
    clear
    title "设置管理密钥"
    CONFIG_FILE="$PWD/cliproxyapi/config.yaml"
    # 检查文件是否存在
    if [ ! -f "$CONFIG_FILE" ]; then
        error "错误: 配置文件 $CONFIG_FILE 不存在"
    
    else
        local BACKUP_FILE="${CONFIG_FILE}.backup.$(date +%Y%m%d_%H%M%S)"
        sudo cp "$CONFIG_FILE" "$BACKUP_FILE"
        success "已备份原配置到 $BACKUP_FILE"
        
        while true; do
            read -p "请输入访问 管理密钥: " SECRET_KEY
            if [ -z "$SECRET_KEY" ]; then
                # 如果留空，设置为空字符串（即 secret-key: ""）
                error "如果不设置管理密钥，是无法访问呃（不可留空）"
                continue
            else
                ESCAPED_KEY=$(printf '%s\n' "$SECRET_KEY" | sed 's/[&/\]/\\&/g')
                sed -i 's/^\([[:space:]]*secret-key:\) ".*"$/\1 "'"$ESCAPED_KEY"'"/' "$CONFIG_FILE"
                success "已设置 secret-key"
                break
            fi
        done

        sed -i 's/^\([[:space:]]*allow-remote:\) false$/\1 true/' "$CONFIG_FILE"
        success "已设置 allow-remote: true"
        success "配置文件修改完成！"

        info "设置服务开机自启动"
        systemctl --user enable cliproxyapi.service
        info "启动cliproxyapi服务"
        systemctl --user start cliproxyapi.service
        success "访问Web UI的IP地址为：http://$(get_public_ip):8317/management.html#/login"
    fi


}

cliproxyapi_uninstall_sh(){
    title "卸载 cliproxyapi ..." 

    curl -fsSL https://raw.githubusercontent.com/brokechubb/cliproxyapi-installer/refs/heads/master/cliproxyapi-installer | bash -s uninstall

    info "停止服务"
    systemctl --user stop cliproxyapi.service
    info "禁用服务"
    systemctl --user disable cliproxyapi.service
    info "删除服务文件"
    sudo rm -f ~/.config/systemd/user/cliproxyapi.service
    sudo rm -rf $PWD/cliproxyapi
    info "重新加载 systemd 配置"
    systemctl --user daemon-reload
    success "卸载完成"
}




#----------------------------------------

wireguard_install(){

    check_service "wg-quick@"

    if [[ $? -eq 2 ]]; then
        local -A MY_PKG_MAP=(
            ["wg"]="wireguard"
            ["qrencode"]="qrencode"
            ["wireguard-tools"]="wireguard-tools"
        )
        check_and_install_tools MY_PKG_MAP "wg" "qrencode" "wireguard-tools"
    fi

    # 开启 IP 转发
    enable_ip_forward() {
        if sudo sysctl net.ipv4.ip_forward | grep -q "= 0"; then
            warn "IP 转发未开启，正在开启..."
            sudo echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf
            sudo sysctl -p
            success "IP 转发已开启并持久化。"
        else
            success "IP 转发已开启。"
        fi
    }

    title "请输入 WireGuard 服务器配置信息"
    enable_ip_forward
    while true; do
        read -p "请输入服务器 IP 地址段 (CIDR 格式，例如 10.0.0.0/24，回车默认10.10.10.0/24): " server_cidr
        server_cidr=${server_cidr:-10.10.10.0/24}
        # 验证 CIDR 格式
        if ! [[ $server_cidr =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}/[0-9]{1,2}$ ]]; then
            error "IP 地址段格式错误，应为 CIDR 格式，如 10.0.0.0/24"
            continue
        else
            break
        fi
    done
    read -p "请输入服务器公网 IP 或域名 (用于客户端连接-回车默认$(get_public_ip)): " server_endpoint
    server_endpoint=${server_endpoint:-$(get_public_ip)}
    while true; do
        read -p "请输入服务器监听端口 (例如 10086(回车默认))：" server_port
        server_port=${server_port:-10086}
        # 验证端口
        if ! [[ $server_port =~ ^[0-9]+$ ]] || (( server_port < 1 || server_port > 65535 )); then
            error "端口号必须是 1-65535 之间的数字。"
            continue
        else
            break
        fi
    done
    read -p "请输入DNS 服务器 (回车默认 8.8.8.8)：" server_dns
    server_dns=${server_dns:-8.8.8.8}
    while true; do
        read -p "需要生成的客户端数量(回车默认1)：" client_num
        client_num=${client_num:-1}

        # 验证客户端数量
        if ! [[ $client_num =~ ^[0-9]+$ ]] || (( client_num < 1 )); then
            error "客户端数量必须是正整数。"
            continue
        else
            break
        fi
    done

    # 计算可用 IP 范围
    IFS='/' read -r network cidr <<< "$server_cidr"
    IFS='.' read -r a b c d <<< "$network"
    mask=$(( 0xffffffff << (32 - cidr) & 0xffffffff ))
    net=$(( (a<<24) + (b<<16) + (c<<8) + d ))
    net=$(( net & mask ))
    max_hosts=$(( (1 << (32 - cidr)) - 2 ))
    if (( client_num > max_hosts )); then
        error "子网 $server_cidr 最多支持 $max_hosts 个客户端，但您请求了 $client_num 个。"
    fi

    server_ip_int=$(( net + 1 ))
    server_ip="$(( (server_ip_int >> 24) & 255 )).$(( (server_ip_int >> 16) & 255 )).$(( (server_ip_int >> 8) & 255 )).$(( server_ip_int & 255 ))"
    server_ip_cidr="$server_ip/$cidr"
    success "服务器将使用 IP: $server_ip_cidr"

    # 生成服务器基础配置并获取公钥
    server_public_key=$(generate_server_base_config "$server_ip_cidr" "$server_port" | tr -d '\n')
    echo "$server_public_key"

    # 启动 WireGuard
    start_wireguard

    # 生成客户端配置并添加到服务器
    title "生成客户端配置..."
    for (( i=1; i<=client_num; i++ )); do
        client_ip_int=$(( net + 1 + i ))
        client_ip="$(( (client_ip_int >> 24) & 255 )).$(( (client_ip_int >> 16) & 255 )).$(( (client_ip_int >> 8) & 255 )).$(( client_ip_int & 255 ))"
        client_pubkey=$(generate_client_config "$i" "$client_ip" "$server_public_key" "$server_endpoint" "$server_port" "$server_dns" | tr -d '\n')
        add_client_peer "$i" "$client_pubkey" "$client_ip"
    done

    title "所有客户端配置已生成完毕。"
    echo -e "${YELLOW}请确保防火墙已开放 UDP 端口 $server_port，否则客户端无法连接。${NC}" >&2
    echo -e "您可以使用以下命令查看服务器状态：" >&2
    echo -e "  wg show" >&2
    echo -e "  wg-quick up wg0   # 启动接口（如果尚未启动）" >&2
    echo -e "客户端配置文件为 client*.conf。" >&2
    warn "如果wireguard无法联通，请重新安装更换端口试一下。"


}

wireguard_uninstall(){
    title "开始彻底清理 WireGuard 环境..."

    # 停止并禁用所有 WireGuard 接口
    if command -v wg &>/dev/null; then
        interfaces=$(sudo wg show interfaces)
        for iface in $interfaces; do
            warn "正在停止接口: $iface"
            sudo wg-quick down "$iface" 2>/dev/null || true
            sudo systemctl disable "wg-quick@$iface" 2>/dev/null || true
        done
    fi

    # 删除所有配置文件和密钥
    info "清理配置文件和密钥..."
    sudo rm -rf /etc/wireguard/
    sudo rm -f client*.conf client*.png  # 清理当前目录下生成的客户端文件

    # 清理 IPTables 转发规则 (针对常见 NAT 配置)
    info "检查并清理残留的 IPTables 转发规则..."
    sudo iptables -t nat -F 2>/dev/null || true
    sudo iptables -F FORWARD 2>/dev/null || true

    # 卸载软件包
    info "正在检测系统并卸载软件..."
    case "$(detect_os)" in
        ubuntu|debian|kali)
            apt-get remove --purge -y wireguard wireguard-tools qrencode
            apt-get autoremove -y
            ;;
        centos|rhel|fedora)
            yum remove -y wireguard-tools qrencode
            ;;
        arch)
            pacman -Rs --noconfirm wireguard-tools qrencode
            ;;
        *)
            error "未能识别的系统类型，请手动卸载 wireguard-tools。"
            ;;
    esac
    
    success "清理完成！系统已恢复至 WireGuard 安装前的状态。"

}


# 运行主菜单
main_menu





