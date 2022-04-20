#!/bin/bash

# 屏幕显示，运行环境检查
echo "运行环境检查："
# 运行环境检查函数

function env_check(){
        pi="Pi-Network"
        docker="Docker-Desktop"
        l_nmap="nmap"
        l_dos2unix="dos2unix"
        l_txt2heml="txt2html"
        nginx="nginx"
        c_pi=`powershell.exe Get-Process "Pi*Network" |awk '/Pi/{print $8"-"$9}' |head -1`
        c_docker=`powershell.exe Get-Process "Docker*Desktop" |awk '/Docker/{print $8"-"$9}' |head -1`
        c_nmap=`dpkg -l |grep "nmap" |head -1 |awk '{print $2}'`
        c_dos2unix=`dpkg -l |grep "dos2unix" |head -1 |awk '{print $2}'`
        c_nginx=` docker ps |awk '/nginx/{print $2}'`

        echo -n "Docker Desktop:   "
        if [ "$c_docker" == "$docker" ];then
                echo -e "\033[1;32m[ OK ]\033[0m"
                echo "OK" >check_env.log
        else
                echo -e "\033[1;31m[ None ]\033[0m"
                echo "None" >check_env.log
        fi
        sleep 1
        echo -n "Pi Network Node:  "
        if [ "$c_pi" == "$pi" ];then
                echo -e "\033[1;32m[ OK ]\033[0m"
                echo "OK" >>check_env.log
        else
                echo -e "\033[1;31m[ None ]\033[0m"
                echo "None" >>check_env.log
        fi
        sleep 1
        echo -n "Linux nmap:       "
        if [ "$c_nmap" == "$l_nmap" ];then
                echo -e "\033[1;32m[ OK ]\033[0m"
                echo "OK" >>check_env.log
        else
                echo -e "\033[1;31m[ None ]\033[0m"
                echo "None" >>check_env.log
        fi
        sleep 1
        echo -n "Linux dos2unix:   "
        if [ "$c_dos2unix" == "$l_dos2unix" ];then
                echo -e "\033[1;32m[ OK ]\033[0m"
                echo "OK" >>check_env.log
        else
                echo -e "\033[1;31m[ None ]\033[0m"
                echo "None" >>check_env.log
        fi
        sleep 1
        echo -n "Linux txt2html:   "
        if [ "$c_dos2unix" == "$l_dos2unix" ];then
                echo -e "\033[1;32m[ OK ]\033[0m"
                echo "OK" >>check_env.log
        else
                echo -e "\033[1;31m[ None ]\033[0m"
                echo "None" >>check_env.log
        fi
        sleep 1
        echo -n "nginx container:  "
        if [ "$c_nginx" == "$nginx" ];then
                echo -e "\033[1;32m[ OK ]\033[0m"
                echo "OK" >>check_env.log
        else
                echo -e "\033[1;31m[ None ]\033[0m"
                echo "None" >>check_env.log
        fi
        sleep 1
}

env_check
# 环境检查结果判断，满足则程序开始运行，不满足退出。
function check_out(){
        for n  in `cat check_env.log`
        do
                if [ "$n" == "None" ];then
                        echo "检查未全部通过，程序退出！"
                        exit 0
                fi
        done
}

check_out

# 监控程序开始运行
echo "Pi node monitor is running "
date "+%H:%M:%S  %Y/%m/%d"
echo "脚本将一直运行，想要停止，请按 Ctrl + C"

ip=`curl http://ifconfig.me 2> /dev/null`
Web="web_information.txt"

for ((i=0;i<1;i++))
do
        echo "System's IP Address:  $ip" >$Web
        powershell.exe Get-WmiObject -Class win32_OperatingSystem  FreePhysicalMemory |awk '/FreePhysicalMemory/{print $3}' >.memory_txt
        dos2unix .memory_txt &>/dev/null
        free_mem=`cat .memory_txt`
        F_M=`echo "scale=2;$free_mem/1024/1024" |bc`
        echo "System_FreePhysicalMemory: ${F_M}GB" >>$Web

        powershell.exe wmic cpu get loadpercentage |head -2 |tail -1 |awk '{print "System_CPU_LoadPercentage: "$1"%\n" }' >>$Web


        nmap -Pn -p 31400-31409 $ip |grep "PORT" -A11 >>$Web
        echo "docker container stats pi-consensus" >> $Web
        docker container stats pi-consensus --no-stream >>$Web
        echo "" >>$Web


        docker exec pi-consensus stellar-core http-command info |grep "default INFO] {" -A60 >>$Web

        date >>$Web
        uptime -p >>$Web

        txt2html $Web --title "Pi Node infomation" --append_head header_css --body_deco ' class="home"' --outfile index.html -p 2
        cp index.html index.htm
        let i-=1
        sleep 0.314
done
