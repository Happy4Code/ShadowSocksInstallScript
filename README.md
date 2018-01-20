# 这是一键式安装ss的脚本

## 你只需要下载该脚本，并运行它，在运行期间脚本会要求你输入一系列配置信息（当然可以直接回车采用默认值），目前该脚本只支持linux的centos版本。

## 该脚本除了提供安装ss，也提供了暂停、运行和卸载的相关服务，只需要搭配相应的参数即可，用户只需要根据需求粘贴每一部分的命令就可以了

## Tutorial

### 安装ss

#### 第一步：  
wget --no-check-certificate -O ss-script.sh https://raw.githubusercontent.com/Happy4Code/ShadowSocksInstallScript/master/ShadowSocksInstall.sh  

#### 第二步：
chmod +x ss-script.sh

#### 第三步：
./ss-script.sh 2>&1 | tee ss-script.log

### 停止ss
./ss-script.sh stop

### 卸载
./ss-script.sh uninstall

**Hope you can enjoy this script**!
