#!/bin/bash

RED="\\033[31m"
GREEN="\\033[32m"
YELLOW="\\033[33m"
BLACK="\\033[0m"
POS="\\033[94G"

Green_background="\033[42;37m" 
Red_background="\033[41;37m" 
Font_color_suffix="\033[0m"

log(){
	echo -e ""
	echo -e "-------------- ${YELLOW}$1${BLACK} ---------------"
	echo -e ""
}

version(){
	log "iptables  快捷通用脚本 v 1.0.1"
	echo -e "	注意：该版本仅适用 ${RED}CentOS 6.x.x ${BLACK}版本"
}

help(){
	log  "菜单"
	echo -e " ${GREEN} 0.${BLACK} 展示iptables语法规则"
	echo -e " ${GREEN} 1.${BLACK} 展开所有规则链"
	echo -e " ${GREEN} 2.${BLACK} 打开 INPUT 端口，同时指定tcp udp，并保存配置重启防火墙"
	echo -e " ${GREEN} 3.${BLACK} 删除 INPUT 端口，同时指定tcp udp，并保存配置重启防火墙"
	echo -e " ${GREEN} 4.${BLACK} 保存防火墙配置"
	echo -e " ${GREEN} 5.${BLACK} 重启防火墙"
	echo -e " ${GREEN} 6.${BLACK} 产看某端口占用情况"
	echo -e " ${GREEN} 7.${BLACK} 查看系统端口占用情况"
	echo -e " ${GREEN} 8.${BLACK} 查看所有的进程和端口使用情况"
	echo -e " ${GREEN} 9.${BLACK} 指定删除已添加的iptables规则"
	echo -e " ${GREEN}10.${BLACK} 屏避IP"
	echo -e " ${GREEN}11.${BLACK} 退出应用"
	echo -e ""
}

iptables_help(){
	log "展示iptables语法规则 开始"
	echo -e	"	Usage: iptables -[AD] chain rule-specification [options]
       		iptables -I chain [rulenum] rule-specification [options]
       		iptables -R chain rulenum rule-specification [options]
       		iptables -D chain rulenum [options]
       		iptables -[LS] [chain [rulenum]] [options]
       		iptables -[FZ] [chain] [options]
       		iptables -[NX] chain
       		iptables -E old-chain-name new-chain-name
       		iptables -P chain target [options]
       		iptables -h (print this help information)
	常用命令：
		-t<表>：指定要操纵的表；
		-A：向规则链中添加条目；
		-D：从规则链中删除条目；
		-i：向规则链中插入条目；
		-R：替换规则链中的条目；
		-L：显示规则链中已有的条目；
		-F：清楚规则链中已有的条目；
		-Z：清空规则链中的数据包计算器和字节计数器；
		-N：创建新的用户自定义规则链；
		-P：定义规则链中的默认目标；
		-h：显示帮助信息；
		-p：指定要匹配的数据包协议类型；
		-s：指定要匹配的数据包源ip地址；
		-j<目标>：指定要跳转的目标；
		-i<网络接口>：指定数据包进入本机的网络接口；
		-o<网络接口>：指定数据包要离开本机所使用的网络接口。
	Commands:
	Either long or short options are allowed.
		--append  -A chain            	Append to chain
		--delete  -D chain            	Delete matching rule from chain
		--delete  -D chain rulenum 		Delete rule rulenum (1 = first) from chain
		--insert  -I chain [rulenum]	Insert in chain as rulenum (default 1=first)
		--replace -R chain rulenum		Replace rule rulenum (1 = first) in chain
		--list    -L [chain [rulenum]]	List the rules in a chain or all chains
		--list-rules -S [chain [rulenum]] Print the rules in a chain or all chains
		--flush   -F [chain]          	Delete all rules in  chain or all chains
		--zero    -Z [chain [rulenum]]	Zero counters in chain or all chains
		--new     -N chain            	Create a new user-defined chain
		--delete-chain 	-X [chain]      Delete a user-defined chain
		--policy  -P chain target		Change policy on chain to target
		--rename-chain	-E old-chain new-chain 	Change chain name, (moving any references
	简略一览表： 命令(iptables)  表(-t)  链(...)  数量(-n)  协议(-p)  控制类型(-j)		
 	 查看 iptables -t raw/mangle/nat/filter -nL  INPUT/OUTPUT/FORWARD/POSTROUTING/PREROUNING					
 	 添加 iptables -t raw/mangle/nat/filter -I/  INPUT/OUTPUT/FORWARD/POSTROUTING/PREROUNING	-p tcp/icmp/udp -j ACCEPT/DROP/REJECT/LOG
 	 插入 iptables -t raw/mangle/nat/filter -I	 NPUT/OUTPUT/FORWARD/POSTROUTING/PREROUNING -n  -p tcp/icmp/udp -j ACCEPT/DROP/REJECT/LOG
	 删除 iptables -t raw/mangle/nat/filter -D	 NPUT/OUTPUT/FORWARD/POSTROUTING/PREROUNING -n				
 	 清除 iptables -t raw/mangle/nat/filter -F" 					

	log "展示iptables语法规则 按任意键结束"
	read ok
	return	
}

iptables_L(){
	log "展开所有规则链 开始"
	iptables -L -n  -v
	log "展开所有规则链 结束"
	read ok
	return
}

iptables_open_port(){
	log "打开 INPUT 端口，同时指定tcp udp，并保存配置重启防火墙 开始"
	read -p "Please enter port: " option
	# iptables -I INPUT -p tcp --dport $option -j ACCEPT
	# iptables -I INPUT -p udp --dport $option -j ACCEPT
	iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport $option -j ACCEPT
	iptables -I INPUT -m state --state NEW -m udp -p udp --dport $option -j ACCEPT
	/etc/rc.d/init.d/iptables save
	/etc/rc.d/init.d/iptables restart
	log "打开 INPUT 端口，同时指定tcp udp，并保存配置重启防火墙 按任意键结束结束"
	read ok
	return
}

iptables_close_port(){
	log "删除 INPUT 端口，同时指定tcp udp，并保存配置重启防火墙 开始"
	read -p "Please enter port: " option
	# iptables -I INPUT -p tcp --dport $option -j DROP
	# iptables -I INPUT -p tcp --dport $option -j DROP
	iptables -D INPUT -m state --state NEW -m tcp -p tcp --dport $option -j ACCEPT
	iptables -D INPUT -m state --state NEW -m udp -p udp --dport $option -j ACCEPT
	/etc/rc.d/init.d/iptables save
	/etc/rc.d/init.d/iptables restart
	log "关闭 INPUT 端口，同时指定tcp udp，并保存配置重启防火墙 按任意键结束结束"
	read ok
	return
}

iptables_save(){
	log "保存防火墙配置 开始"
	/etc/rc.d/init.d/iptables save
	log "保存防火墙配置 按任意键结束结束"
	read ok
	return
}

iptables_restart(){
	log "重启防火墙 开始"
 	/etc/rc.d/init.d/iptables restart
	 log "重启防火墙 按任意键结束结束"
	 read ok
	return
}

lsof_i_port(){
	log "产看某端口占用情况 开始"
	read -p "Please enter port: " option
	echo ""
	echo -e ">>>------- lsof -i:$option -------------------->>>"
	lsof -i:$option
	echo ""
	echo -e ">>>------- netstat -anp|grep $option --------->>>"
	netstat -anp|grep $option 
	log "产看某端口占用情况 按任意键结束结束"
	read ok
	return
}

netstat_tunlp(){
	log "查看系统端口占用情况 开始"
	netstat -tunlp
	log "查看系统端口占用情况 按任意键结束结束"
	read ok
	return
}

netstat_apn(){
	log "查看所有的进程和端口使用情况 开始"
	netstat -apn
	log "查看所有的进程和端口使用情况 按任意键结束结束"
	read ok
	return
}

iptables_del_port(){
	log "删除已添加的iptables规则 开始"
	iptables -L -n --line-numbers
	read -p "Please enter numbers: " option
	iptables -D INPUT $option
	log "删除已添加的iptables规则 按任意键结束结束"
	read ok
	return
}

block_ip(){
	log "屏避IP 开始"
	read -p "Please enter IP: " option
	iptables -I INPUT -s $option -j DROP
	log "屏避IP 按任意键结束结束"
	read ok
	return
}

version

while true
do
	help
	read -p "Please enter your slect: " option
	case "$option" in
	0)
		iptables_help
		;;
	1)
		iptables_L
		;;
	2)
		iptables_open_port
		;;
	3)
		iptables_close_port
		;;
	4)
		iptables_save
		;;
	5)
		iptables_restart
		;;
	6)
		lsof_i_port
		;;
	7)
		netstat_tunlp
		;;
	8)
		netstat_apn
		;;
	9)
		iptables_del_port
		;;
	10)
		block_ip
		;;
	11)
		echo "iptables 通用脚本即将退出"
		exit
		;;
	*)
		echo  "选项不存在"
		;;
    esac

done


