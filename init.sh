#########################################################################
# File Name:    configs.sh
# Author:       weikunkun
# mail:         kongwiki@163.com
# Created Time: Tue 16 Nov 2021 04:20:09 PM CST
#########################################################################
#!/bin/bash

echo ""
echo " ========================================================= "
echo " |            Linux init.sh 环境部署脚本 V 1.1           | "
echo " ========================================================= "
echo "                      author：weikunkun                    "
echo "                 https://github.com/Winniekun              "
echo -e "\n"

# 由于学艺不精，经常把自己的服务器搞崩，并且定位不到root case
# 所以经常会重装系统，痛定思痛，决定写一个一劳永逸的初始化安装配置脚本
# LEVEL=base/dev/hacker/full
#       base: 基础配置（zsh、vim、git、wget、curl等）
#       dev: 开发环境配置（Java、Go、Kafka、MySQL、Redis等）
#       hacker: 常见的网络安全工具（sqlmap、nmap、httpx、xray等）
#       full: 一把梭哈
LEVEL='full'
CUR_PATH=$(pwd)
# zsh & oh-my-zsh安装
install_zsh() {
    apt install -y zsh >/dev/null 2>&1
    echo -e "开始配置oh-my-zsh"
    sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    chsh -s /bin/zsh
    sed -i 's@ZSH_THEME="robbyrussell"@ZSH_THEME="awesomepanda"@g' ~/.zshrc 
    sed -i 's@plugins=(.*)@plugins=(git extract zsh-syntax-highlighting autojump zsh-autosuggestions)@g' ~/.zshrc
    {
        echo 'alias cat="/usr/bin/bat"' # 使用bat替代cat
        echo 'alias myip="curl ifconfig.io/ip"'
        echo 'alias c=clear'
    } >> ~/.zshrc 
    echo -e "下载安装zsh-syntax-highlighting"
    git clone git://github.com/zsh-users/zsh-syntax-highlighting $ZSH_CUSTOM/plugins/zsh-syntax-highlighting >/dev/null 2>&1
    echo -e "下载安装zsh-autosuggestions"
    git clone https://github.com/zsh-users/zsh-autosuggestions.git $ZSH_CUSTOM/plugins/zsh-autosuggestions >/dev/null 2>&1
    echo -e "下载安装autojump"
    apt install -y autojump

    # 重载配置
    source ~/.zshrc 
}

# Vim 安装 & 配置
install_vim() {
    git clone https://github.com/youngyangyang04/PowerVim.git
    VIM_PATH=$CUR_PATH/PowerVim
    sh $VIM_PATH/install.sh
}

# Git 安装 & 配置
intall_git() {
    if command -v git >/dev/null 2>&1
    then 
        # 配置
        echo -e "检测到已经安装Git，开始Git配置"
        config_git
    else
        # 安装 
        apt install -y git >/dev/null 2>&1
        # 配置
        echo -e "开始Git配置"
        config_git
}
# git相关的配置
config_git() {
    # 用户信息
    git config --global user.name "weikunkun"
    git config --global user.emai "kongwiki@163.com"
    # core
    git config --global core.editor vim   
    # color
    git config --global color.ui true
    git config --global color.status "auto"
    git config --global color.branch "auto"
    # merge
    git config --global merge.tool "vimdiff"
    # alias
    git config --global alias.co "checkout"
    git config --global alias.br "branch"  
    git config --global alias.ci "commit"
    git config --global alias.st "status"
    git config --global alias.last "log -1 HEAD"
}

# python3 配置
install_python3() {
    mkdir ~/.pip/
    echo -e "[global]\n" >~/.pip/pip.conf
    # 替换PIP源 速度更快
    echo -e "index-url = https://pypi.tuna.tsinghua.edu.cn/simple" >>~/.pip/pip.conf
    echo -e "开始安装Python常见库"
    pip3 install lxml >/dev/null 2>&1
    pip3 install ipaddress >/dev/null 2>&1
    pip3 install python-dateutil >/dev/null 2>&1
    pip3 install apscheduler >/dev/null 2>&1
    pip3 install mycli >/dev/null 2>&1
    pip3 install aiohttp >/dev/null 2>&1
    pip3 install datetime >/dev/null 2>&1
    pip3 install timeit >/dev/null 2>&1
    pip3 install docker-compose >/dev/null 2>&1
    pip3 install chardet >/dev/null 2>&1
    pip3 install supervisor >/dev/null 2>&1
    pip3 install python-dateutil >/dev/null 2>&1
    pip3 install requests >dev/null 2>&1
}


# Java 配置
install_java() {
    echo -e "开始配置Java环境"
    if command -v java >dev/null 2>&1 
    then
        # 已经配置，不做操作
        test 
    else 
        echo -e "手动配置Java环境"
        if [ ! -d "jdk-11_linux-x64_bin.tar.gz" ]
        then
            wget https://repo.huaweicloud.com/java/jdk/11+28/jdk-11_linux-x64_bin.tar.gz
            tar -xzvf jdk-11_linux-x64_bin.tar.gz
            mv jdk-11_linux-x64_bin /opt/jdk11
        else
            test
        echo "export JAVA_HOME=/opt/jdk11" >> ~/.zshrc 
        echo "export PATH-${JAVA_HOME}/bin:$PATH" >> ~/.zshrc 
        source ~/.zshrc 

    fi
}

# 系统配置
base_config() {
    echo -e "apt install ag ..."
    apt install -y silversearcher-ag >/dev/null 2>&1
    ulimit -n 10240
    echo -e "开始配置随机SSH 端口"
    SSH_PORT=$(cat /etc/ssh/sshd_config | ag -o '(?<=Port )\d+')
    if [ $SSH_PORT -eq 22 ] 
    then
        SSH_NEW_PORT=$(shuf -i 10000-30000 -n1)
        echo -e "SSHD Port: ${SSH_NEW_PORT}" | tee -a ssh_port.txt
        sed -E -i "s/(Port|#\sPort|#Port)\s.{1,5}$/Port ${SSH_NEW_PORT}/g" /etc/ssh/sshd_config
    fi
    
    # apt更新
    echo -e "apt update ..."
    apt update >/dev/null 2>&1
    
    # 常用软件安装
    cmdline=(
        "which lsof"
        "which man"
        "which tmux"
        "which htop"
        "which autojump"
        "which iotop"
        "which ncdu"
        "which jq"
        "which telnet"
        "which p7zip"
        "which axel"
        "which rename"
        "which vim"
        "which sqlite3"
        "which lrzsz"
        "which unzip"
        "which git"
        "which curl"
        "which wget"
    )
    for prog in "${cmdline[@]}"; do
        soft=$($prog)
        if [ "$soft" ] >/dev/null 2>&1; then
            echo -e "$soft 已安装！"
        else
            name=$(echo -e "$prog" | ag -o '[\w-]+$')
            apt install -y ${name} >/dev/null 2>&1
            echo -e "${name} 安装中......"
        fi
    done
    
    # vim/cur/wget配置
    echo -e "正在配置vim"
    install_vim
    echo -e "正在配置curl"
    curl https://raw.githubusercontent.com/al0ne/vim-for-server/master/.curlrc >~/.curlrc >/dev/null 2>&1
    echo -e "正在配置wget"
    curl https://raw.githubusercontent.com/al0ne/vim-for-server/master/.wgetrc >~/.wgetrc >/dev/null 2>&1
    echo -e "正在配置Git"
    config_git
    if command -v zsh >/dev/null 2>&1
    then
        echo -e "检测到zsh 已安装，将跳过！ "
    else
        echo -e "zsh 安装中..."
        install_zsh
    fi

}

#  开发环境配置
dev_config() {
    # 常见库配置
    echo -e "apt-get install -y libgeoip1"
    apt-get install -y libgeoip1 >/dev/null 2>&1
    echo -e "apt-get install -y libgeoip-dev"
    apt-get install -y libgeoip-dev >/dev/null 2>&1
    echo -e "apt-get install -y openssl"
    apt-get install -y openssl >/dev/null 2>&1
    echo -e "apt-get install -y libcurl3-dev"
    apt-get install -y libcurl3-dev >/dev/null 2>&1
    echo -e "apt-get install -y libssl-dev"
    apt-get install -y libssl-dev >/dev/null 2>&1
    echo -e "apt-get install -y php"
    apt-get install -y php >/dev/null 2>&1
    echo -e "apt-get install -y net-tools"
    apt-get install -y net-tools >/dev/null 2>&1
    echo -e "apt-get install -y ifupdown"
    apt-get install -y ifupdown >/dev/null 2>&1
    echo -e "apt-get install -y tree"
    apt-get install -y tree >/dev/null 2>&1
    echo -e "apt-get install -y cloc"
    apt-get install -y cloc >/dev/null 2>&1
    echo -e "apt-get install -y python3-pip"
    apt-get install -y python3-pip >/dev/null 2>&1
    echo -e "apt-get install -y gcc"
    apt-get install -y gcc >/dev/null 2>&1
    echo -e "apt-get install -y gdb"
    apt-get install -y gdb >/dev/null 2>&1
    echo -e "apt-get install -y g++"
    apt-get install -y g++ >/dev/null 2>&1
    echo -e "apt-get install -y locate"
    apt-get install -y locate >/dev/null 2>&1
    echo -e "apt-get install -y shellcheck"
    apt-get install -y shellcheck >/dev/null 2>&1
    echo -e "apt-get install -y redis-cli"
    apt-get install -y redis-cli >/dev/null 2>&1
    echo -e "apt-get install -y redis-server"
    apt-get install -y redis-server >/dev/null 2>&1
    
    install_java
    install_python3

    if command -v docker >/dev/null 2>&1
    then
        echo "检测到已经安装docker 将跳过Docker的安装"
    else 
        echo -e "开始安装Docker"
        curl -fsSL https://get.docker.com -o get-docker.sh
    fi

    # Go 安装和配置
    if command -v go >/dev/null 2>&1
    then
        echo -e "检测到已经安装Go 将跳过Go的安装"
    else 
        echo -e "开始安装Go"
        sh -c "$(wget -O- https://raw.githubusercontent.com/canha/golang-tools-install-script/master/goinstall.sh)"
    fi

    # Nodejs 配置
    if command -v node >/dev/null 2>&1; then
        echo -e "检测到已安装Nodejs 将跳过！"
    else
        echo -e "开始安装Nodejs"
        curl -fsSL https://deb.nodesource.com/setup_10.x -o nodesource_setup.sh
        apt install -y nodejs >/dev/null 2>&1

    fi 
}

# 网安配置
hacker_config() {
    echo -e "正在安装 nmap ..."
    apt install -y nmap >/dev/null 2>&1
    echo -e "正在安装 netcat ..."
    apt install -y netcat >/dev/null 2>&1
    echo -e "正在安装 masscan ..."
    apt install -y masscan >/dev/null 2>&1
    echo -e "正在安装 zmap ..."
    apt install -y zmap >/dev/null 2>&1
    echo -e "正在安装 dnsutils ..."
    apt install -y dnsutils >/dev/null 2>&1
    echo -e "正在安装 wfuzz ..."
    pip install wfuzz >/dev/null 2>&1
    # 安装 weevely3
    if [ -d "/opt/weevely3" ]; then
        echo -e "检测到weevely3已安装将跳过"
    else
        echo -e "正在克隆 weevely3 ..."
        cd /opt && git clone https://github.com/epinna/weevely3.git >/dev/null 2>&1
        echo 'alias weevely=/opt/weevely3/weevely.py' >>~/.zshrc
    fi
    # 安装 whatweb
    if [ -d "/opt/whatweb" ]; then
        echo -e "检测到whatweb已安装将跳过"
    else
        echo -e "正在克隆 whatweb ..."
        cd /opt && git clone https://github.com/urbanadventurer/WhatWeb.git >/dev/null 2>&1
        echo 'alias whatweb=/opt/WhatWeb/whatweb' >>~/.zshrc
    fi
    # 安装 OneForAll
    if [ -d "/opt/OneForAll" ]; then
        echo -e "检测到OneForAll已安装将跳过"
    else
        echo -e "正在克隆 OneForAll ..."
        cd /opt && git clone https://github.com/shmilylty/OneForAll.git >/dev/null 2>&1
    fi
    # 安装 dirsearch
    if [ -d "/opt/dirsearch" ]; then
        echo -e "检测到dirsearch已安装将跳过"
    else
        echo -e "正在克隆 dirsearch ..."
        cd /opt && git clone https://github.com/shmilylty/OneForAll.git >/dev/null 2>&1
    fi
    # 安装 httpx
    if command -v httpx >/dev/null 2>&1; then
        echo -e "检测到已安装httpx 将跳过！"
    else
        echo -e "开始安装Httpx"
        GO111MODULE=on go get -u -v github.com/projectdiscovery/httpx/cmd/httpx >/dev/null 2>&1

    fi
    # 安装 subfinder
    if command -v subfinder >/dev/null 2>&1; then
        echo -e "检测到已安装subfinder 将跳过！"
    else
        echo -e "开始安装subfinder"
        GO111MODULE=on go get -u -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder >/dev/null 2>&1

    fi
    # 安装 nuclei
    if command -v nuclei >/dev/null 2>&1; then
        echo -e "检测到已安装nuclei 将跳过！"
    else
        echo -e "开始安装nuclei"
        GO111MODULE=on go get -u -v github.com/projectdiscovery/nuclei/v2/cmd/nuclei >/dev/null 2>&1

    fi
    # 安装 naabu
    if command -v naabu >/dev/null 2>&1; then
        echo -e "检测到已安装 naabu 将跳过！"
    else
        echo -e "开始安装 naabu"
        GO111MODULE=on go get -u -v github.com/projectdiscovery/naabu/v2/cmd/naabu >/dev/null 2>&1

    fi
    # 安装 dnsx
    if command -v dnsx >/dev/null 2>&1; then
        echo -e "检测到已安装 dnsx 将跳过！"
    else
        echo -e "开始安装 dnsx"
        GO111MODULE=on go get -u -v github.com/projectdiscovery/dnsx/cmd/dnsx >/dev/null 2>&1

    fi
    # 安装 subjack
    if command -v subjack >/dev/null 2>&1; then
        echo -e "检测到已安装 subjack 将跳过！"
    else
        echo -e "开始安装 subjack"
        go get github.com/haccer/subjack >/dev/null 2>&1

    fi
    # 安装 ffuf
    if command -v ffuf >/dev/null 2>&1; then
        echo -e "检测到已安装 ffuf 将跳过！"
    else
        echo -e "开始安装 ffuf"
        go get -u github.com/ffuf/ffuf >/dev/null 2>&1

    fi

}

CUR_USER=$(whoami)
if [ $CUR_USER != 'root' ]
then
    echo "请切换到root用户再执行该脚本"
fi

if [ $LEVEL = 'base' ] 
then
    base_config
fi

if [ $LEVEL = 'dev' ]
then
    base_config
    dev_config
fi

if [ $LEVEL = 'hacker' ] 
then
    hacker_config
fi

if [ $LEVEL = 'full'  ]
then
    base_config
    dev_config
    hacker_config
fi

