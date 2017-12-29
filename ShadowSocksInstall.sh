#!/bin/bash

#This is a simple script for install shadowsocks on Centos 

PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

#Clear the screen
clear;

echo "####################################";
echo "#           Happy Coding           #";
echo "# MyGithub:                        #";
echo "# Author:   NoOne                  #";
echo "####################################";

#Get current folder
curFolder=`pwd`
#Show the encrpty method
encrptyMethod=(
aes-256-cfb
aes-256-ctr
camellia-256-cfb
aes-192-gcm
aes-192-ctr
aes-192-cfb
camellia-192-cfb
aes-128-gcm
aes-128-ctr
aes-128-cfb
camellia-128-cfb
rc4-md5
chacha20-ietf-poly1305
chacha20-ietf
chacha20
)
#Define some color to has a nice prompt
red='\033[31m'
plain='\033[0m'
blue='\033[36m'
green='\033[42m'

#First to check the user ID
if [ $EUID -ne 0 ];then
  echo -e "[${red}ERROR${plain}] Please change to root then run this script" && exit 1
fi

#In order to avoid the problem caused by selinux, close it
closeSelinux(){
  if [ -f /etc/selinux/config ];then
    sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
    setenforce 0
  fi
}
#Get the public IP information about your server
ipInfo(){
 #Search for the public IP of your machine
 [ -z ${IP} ] && IP=$(wget -qO- -t1 -T2 ipv4.icanhazip.com); 
 [ -z ${IP} ] && IP=$(wget -qO- -t1 -T2 ipinfo.io/ip)
 [ ! -z ${IP} ] && echo ${IP}
 #If we can't get the server Ip address
 if [ -z ${IP} ];then
 	 read -p "We can't get your server IP address, please enter your Ip address: " IP
   [ ! -z ${IP} ] && echo ${IP}
 fi
}
#Check system stuff
checkSystemStuff(){
  local packageManager=""
  local systemDistribution=""
  
  if [ -f /etc/redhat-release ];then
    packageManager="yum"
    systemDistribution="centos"
  elif lsb_release -a | grep -Eqi "CentOS";then
    packageManager="yum"
    systemDistribution="centos"
  elif cat /proc/version | grep -Eqi "centos|red hat|redhat"; then
    packageManager="yum"
    systemDistribution="centos"
  else
    echo -e "[${red}ERROR${plain}]The script only support centos or red-hat distribution" && exit 1
  fi
}

#Get the version of your centos
checkVersion(){
 if [ -s /etc/redhat-release ];then
   local version=$(grep -oE "[0-9.]+" /etc/redhat-release)
   local MainVersion=${version%%.*}
   #If this version is less than 5, the script is not working well
   if [ "$MainVersion" == "5" ]; then
     echo -e "[${red}ERROR${plain}]The script only support version 6 or higher " && exit 1
   fi  
 fi  
}

#Do some pre-install operation
pre_install(){
  
  #Install software slove dependencies problem
  yum install -y python python-devel python-setuptools openssl openssl-devel curl wget unzip gcc automake autoconf make lib tool
  cd ${curFolder}
  pip -V &> /dev/null
  #Check if you install pip
  if [ $? -ne 0 ];then
    curl "https://bootstrap.pypa.io/get-pip.py" -o "get-pip.py"
    python get-pip.py 
  fi
  clear 
  #Set some config info for your shadowsocks
  echo -e "${blue}Please enter your password:${plain}"
  read -p "[Default password:noone]" password
  [ -z "${password}" ] && password="Noone"
  
  echo "Password is configing......."
  #Set the port for your shadowsocks
  while true
  do
    echo -e "${blue}Please enter a port for shadowsocks [1-65535]:${plain}"
    read -p "[Default port: 8989]:" port
    [ -z "$port" ] && port="8989"
    expr ${port} + 1 &>/dev/null
    if [ $? -eq 0 ]; then
        if [ ${port} -ge 1 ] && [ ${port} -le 65535 ] && [ ${port:0:1} != 0 ]; then
          echo "Port is configing....."  
          break
        fi  
    fi  
    echo -e "[${red}Error${plain}] Please enter a correct number [1-65535]"
  done 
 
  #Choose a encrypt method
  while true
  do 
    echo -e "${blue}Please choose a encrypt method for shadowsocks from the following options:${plain}"
    for (( i=1;i<=${#encrptyMethod[*]};i++))do
    	method="${encrptyMethod[$i-1]}"
      echo -e "${green}${i} ${method}${plain}"
    done   
  read -p "Which one you choose[Default method ${encrptyMethod[0]}]:" num
  [ -z "$num" ] && num=1
  #Check if it is a number
  expr ${num} + 1 &>/dev/null
  if [ $? -ne 0 ];then
    echo -e "[${red}Error${plain} Please enter the number]"
    continue
  fi
  if [[ "$num" -lt 1  || "$num" -gt "${#encrptyMethod[*]}" ]];then 
    echo -e "The Please a number between 1 and ${#encrptyMethod[*]} "
    continue
  fi
  
  method="${encrptyMethod[$num-1]}"
  echo "Encrpty method is configing..."
  break;
  done

  echo -e "[${green}INFO${plain}]The install is starting..."
  echo -e "[${green}INFO${plain}]Reading the configuration..."  
}   

#Install the shadowsocks for pip
install(){
  pip install shadowsocks
}
#Config the shadowsocks
config(){
  cat > /etc/shadowsocks.json<<-EOF
{
    "server":"$(ipInfo)",
    "server_port":${port},
    "local_address":"127.0.0.1",
    "local_port":1080,
    "password":"${password}",
    "timeout":300,
    "method":"${method}",
    "fast_open":false
}
EOF
}
#Print the info
printInfo(){
  echo -e "${green}We will display the config information about your shadowsocks${plain}"
  echo -e "${green}You can go to /etc/shadowsocks.json find more config details${plain}"
  echo 
  echo -e "########################################################################"
  echo -e "#   Shadowsocks has been successfully installed on you centos Server   #"
  echo -e "########################################################################"
  echo -e "    Server IP:                         \033[41;37m $(ipInfo) \033[0m    "
  echo -e "    Password:                          \033[41;37m ${password}\033[0m   "
  echo -e "    Encrypt Method                     \033[41;37m ${method} \033[0m    "
  echo -e "    Port                               \033[41;37m ${port} \033[0m      "
  echo -e "########################################################################"
  echo -e "########################################################################"
  echo -e "#                              Happy Coding                           ##"
  echo -e "########################################################################"
  
} 
#Start the service
start(){
  ssserver -c "/etc/shadowsocks.json" -d start 
  echo -e "[${blue}INFO${plain}] Right now the shadowsocks is runing on you machine !"
}
stop(){
  ssserver -c "/etc/shadowsocks.json" -d stop
  echo -e "[${green}INFO${plain}]The shadowsocks has been Stopped".
}
#Uninstall the ss
uninstall(){
  stop
  pip uninstall -y shadowsocks
  if [ -f /etc/shadowsocks.json ];then
    rm  /etc/shadowsocks.json
  fi
  echo -e "[${green}INFO${plain}]The shadowsocks has been uninstall".
}
#Install and run
action=$1
[ -z $1 ] && action="installandstart"
#Check if you want to install and run
if [ ${action} == "installandstart" ];then
 closeSelinux
 checkSystemStuff
 checkVersion
 ipInfo 
 pre_install
 install
 config
 printInfo
 start 
elif [ ${action} == "stop" ];then
   stop
elif [ ${action} == "uninstall" ];then
   uninstall
elif [ ${action} == "start" ];then
  start
else
  echo -e "The script only support option [${green}start${plain}] [${green}stop${plain}] [${green}installandstart${plain}] and [${green}uninstall${plain}]"
fi












