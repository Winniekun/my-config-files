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
echo "         https://github.com/Winniekun/my-config-files      "
echo -e "\n"
# 所以经常会重装系统，痛定思痛，决定写一个一劳永逸的初始化安装配置脚本
# LEVEL=base/dev/hacker/full
#       base: 基础配置（zsh、vim、git、wget、curl等）
#       dev: 开发环境配置（Java、Go、Kafka、MySQL、Redis等）
#       hacker: 常见的网络安全工具（sqlmap、nmap、httpx、xray等）
#       full: 一把梭哈

: ${LEVEL:='dev'}
CUR_PATH=$(pwd)

# zsh & oh-my-zsh安装
config_zsh() {
    if command -v zsh >/dev/null 2>&1
    then
        echo -e "检测到zsh 已安装"
    else
        apt install -y zsh >/dev/null 2>&1
    fi
    if [ ! -d "$HOME/.oh-my-zsh/" ]
    then
        echo -e "开始安装oh-my-zsh"
	install_ohmyzsh
    fi
    chsh -s $(which zsh)
    echo -e "开始配置oh-my-zsh"
    # 设置主题，新增插件
    sed -i 's@ZSH_THEME="robbyrussell"@ZSH_THEME="awesomepanda"@g' ~/.zshrc
    sed -i 's@plugins=(.*)@plugins=(git extract zsh-syntax-highlighting autojump zsh-autosuggestions)@g' ~/.zshrc
   
   {
        # 使用bat替代cat
        echo 'alias cat="/usr/bin/batcat"'
        echo 'alias myip="curl ifconfig.io/ip"'
        echo 'alias c=clear'
    } >> ~/.zshrc

    if [ -d "$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting" ]
    then
        echo -e "zsh-highlighting 已经安装"
    else
        echo -e "下载安装zsh-highlighting"
 	git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
    fi

    if [ -d "$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions" ]
    then
        echo -e "zsh-autosuggestions 已经安装"
    else
        echo -e "下载安装zsh-autosuggestions"
    	git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
    fi
    sed -i '/export TERM=xterm-256color/d' ~/.zshrc
    sed -i '/ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE/d' ~/.zshrc
    # 声明终端类型
    echo "export TERM=xterm-256color" >> ~/.zshrc
    # 设置建议命令的颜色
    echo "ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=10'" >> ~/.zshrc
    # 重载配置
    zsh
    source ~/.zshrc
}

# oh-my-zsh安装
install_ohmyzsh() {
    echo -e "开始安装oh-my-zsh"
    if [ -e "install.sh" ]
    then
        rm install.sh
    	# 修改为国内镜像
    	wget wget https://gitee.com/mirrors/oh-my-zsh/raw/master/tools/install.sh
    	sed -i 's@REPO=${REPO:-ohmyzsh/ohmyzsh}@REPO=${REPO:-mirrors/oh-my-zsh}@g' install.sh
    	sed -i 's@REMOTE=${REMOTE:-https://github.com/${REPO}.git}@REMOTE=${REMOTE:-https://gitee.com/${REPO}.git}@g' install.sh
    	sh install.sh
    	cd $CUR_PATH
    fi
    echo -e "oh-my-zsh安装成功，请重新执行init.sh"
}

# Vim 安装 & 配置
install_vim() {
    if [ ! -d "$CUR_PATH/PowerVim" ]
    then
        git clone https://github.com/youngyangyang04/PowerVim.git
    else
        VIM_PATH=$CUR_PATH/PowerVim
        cd $VIM_PATH && sh install.sh
        # 一些问题修复 （语言问题、ctag等）
        fix_powervim
    fi
    cd $CUR_PATH
}

# PowerVim的一些小问题修复
fix_powervim() {
    # 系统中添加中文包
    echo -e "修复PowerVim一些小问题ing"
    LOCAL_FILE=/var/lib/locales/supported.d/local
    if [ ! -e "$LOCAL_FILE" ]
    then
        echo -e "创建 $LOCAL_FILE"
        touch $LOCAL_FILE
    else
        rm $LOCAL_FILE
    fi
    {
        echo "en_US.UTF-8 UTF-8"
        echo "zh_CN.UTF-8 UTF-8"
        echo "zh_CN.GBK GBK"
        echo "zh_CN GB2312"
    } >> $LOCAL_FILE
    # 重新生成系统语言
    sudo locale-gen
    # 删除重复内容
    sed -i '/let Tlist_Show_One_File=1/d' ~/.vimrc
    sed -i '/let Tlist_Exit_OnlyWindow=1/d' ~/.vimrc
    sed -i '/let Tlist_Ctags_Cmd=/d' ~/.vimrc


    {
    echo 'let Tlist_Show_One_File=1 "不同时显示多个文件的tag，只显示当前文件的'
    echo 'let Tlist_Exit_OnlyWindow=1 "如果taglist窗口是最后一个窗口，则退出vim'
    echo 'let Tlist_Ctags_Cmd="/usr/bin/ctags" "将taglist与ctags关联'
    } >> ~/.vimrc

    echo -e "修复成功"
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
    fi
}

# git相关的配置
config_git() {
    # 用户信息
    echo -e "（Git）请输入你的 username: \c"
    read username
    git config --global user.name "$username"
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

# python3
install_python3() {
    if [ -d "$HOME/.pip" ]
    then
        echo -e "$HOME/.pip 已经创建"
    else
        mkdir ~/.pip/
    fi
    echo -e "[global]\n" >~/.pip/pip.conf
    # 替换PIP源 速度更快
    echo -e "index-url = https://pypi.tuna.tsinghua.edu.cn/simple" >>~/.pip/pip.conf
    echo -e "开始安装Python常见库"
    pip3 install lxml >/dev/null 2>&1
    pip3 install apscheduler >/dev/null 2>&1
    pip3 install mycli >/dev/null 2>&1
    pip3 install aiohttp >/dev/null 2>&1
    pip3 install datetime >/dev/null 2>&1
    pip3 install timeit >/dev/null 2>&1
    pip3 install docker-compose >/dev/null 2>&1
    pip3 install chardet >/dev/null 2>&1
    pip3 install supervisor >/dev/null 2>&1
    pip3 install python-dateutil >/dev/null 2>&1
    pip3 install requests >/dev/null 2>&1
}


# Java 配置
install_java() {
    echo -e "开始配置Java环境"
    if command -v java >/dev/null 2>&1
    then
        # 已经配置，不做操作
        echo -e "Java环境已经配置，即将跳过"
    else
        echo -e "手动配置Java环境"
        if [ ! -e "/opt/jdk-11" ]
        then
	    wget https://repo.huaweicloud.com/java/jdk/11+28/jdk-11_linux-x64_bin.tar.gz
            tar -xzvf jdk-11_linux-x64_bin.tar.gz -C /opt >/dev/null 2>&1
        fi
        sed -i '/export JAVA_HOME=\/opt\/jdk-11/d' /etc/zsh/zprofile
        sed -i '/export PATH=${JAVA_HOME}\/bin:$PATH' /etc/zsh/zprofile
        echo 'export JAVA_HOME=/opt/jdk-11' >> /etc/zsh/zprofile
        echo 'export PATH=${JAVA_HOME}/bin:$PATH' >> /etc/zsh/zprofile
        source /etc/zsh/zprofile
        echo -e "Java环境配置完成"
    fi

}

# Go安装与配置
install_go() {
    if command -v go >/dev/null 2>&1
    then
        echo -e "检测到已经安装Go 将跳过Go的安装"
    else
        if [ ! -e "/usr/local/go" ]; then
		wget https://go.dev/dl/go1.17.3.linux-amd64.tar.gz
                tar -zxvf go1.17.3.linux-amd64.tar.gz -C /usr/local
        fi
        echo -e "开始配置Go环境"
        sed -i '/export PATH=\/usr\/local\/go\/bin:$PATH/d' /etc/zsh/zprofile
        echo 'export PATH=/usr/local/go/bin:$PATH' >> /etc/zsh/zprofile
        echo -e "刷新配置文件"
        source /etc/zsh/zprofile
     fi
}

# 系统配置
base_config() {
    echo -e "apt install ag ..."
    apt install -y silversearcher-ag >/dev/null 2>&1
    echo -e "apt install zh-hans 语言库"
    apt install -y language-pack-zh-hans >/dev/null 2>&1
    ulimit -n 10240
    echo -e "开始配置随机SSH 端口"
    SSH_PORT=$(cat /etc/ssh/sshd_config | ag -o '(?<=Port )\d+')
    if [ $SSH_PORT -eq 22 ]
    then
        SSH_NEW_PORT=$(shuf -i 10000-30000 -n1)
        echo -e "SSHD Port: ${SSH_NEW_PORT}" | tee -a ssh_port.txt
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
        "which curl"
	"which bat"
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

    # git/vim/zsh/cur/wget配置
    echo -e "正在配置git"
    config_git
    echo -e "正在配置vim"
    install_vim
    echo -e "正在配置zsh"
    cd $CUR_PATH
    config_zsh
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
    install_go

    if command -v docker >/dev/null 2>&1
    then
        echo "检测到已经安装docker 将跳过Docker的安装"
    else
        echo -e "开始安装Docker"
        curl -fsSL https://get.docker.com -o get-docker.sh
    fi

    # Nodejs 配置
    if command -v node >/dev/null 2>&1; then
        echo -e "检测到已安装Nodejs 将跳过！"
        curl -fsSL https://deb.nodesource.com/setup_10.x -o nodesource_setup.sh
        apt install -y nodejs >/dev/null 2>&1
    fi
    # TODO Redis、MySQL、Kafka
}

# 网安配置
hacker_config() {
    apt install -y nmap >/dev/null 2>&1
    echo -e "正在安装 netcat ..."
    apt install -y netcat >/dev/null 2>&1
    echo -e "正在安装 masscan ..."
    apt install -y masscan >/dev/null 2>&1
    echo -e "正在安装 zmap ..."
    apt install -y zmap >/dev/null 2>&1
    echo -e "正在安装 wfuzz ..."
    pip install wfuzz >/dev/null 2>&1
    # 安装 weevely3
    if [ -d "/opt/weevely3" ]; then
        echo -e "检测到weevely3已安装将跳过"
    else
        echo 'alias weevely=/opt/weevely3/weevely.py' >>~/.zshrc
    fi
    # 安装 whatweb
    if [ -d "/opt/whatweb" ]; then
        echo -e "检测到whatweb已安装将跳过"
        echo 'alias whatweb=/opt/WhatWeb/whatweb' >>~/.zshrc
    fi
    # 安装 OneForAll
    if [ -d "/opt/OneForAll" ]; then
        echo -e "检测到OneForAll已安装将跳过"
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
    # base_config
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
echo -e "环境全部配置完成, have fun"
