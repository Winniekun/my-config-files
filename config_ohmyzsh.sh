#! /bin/bash

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
		install_ohmyzsh
	else
		echo -e "已经安装了oh-my-zsh，开始配置"
		chsh -s $(which zsh)
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
	        git clone git://github.com/zsh-users/zsh-syntax-highlighting $ZSH_CUSTOM/plugins/zsh-syntax-highlighting >/dev/null 2>&1fi
	fi
	if [ -d "$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions" ]
	then
		echo -e "zsh-autosuggestions 已经安装"
	else
	        git clone https://github.com/zsh-users/zsh-autosuggestions.git $ZSH_CUSTOM/plugins/zsh-autosuggestions >/dev/null 2>&1
	fi
	sed -i '/export TERM=xterm-256color/d' ~/.zshrc
	sed -i '/ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE/d' ~/.zshrc
	# 声明终端类型
	echo "export TERM=xterm-256color" >> ~/.zshrc
	# 设置建议命令的颜色
	echo "ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=10'" >> ~/.zshrc
    fi
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
}

config_zsh
