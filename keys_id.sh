#!/bin/bash

# 配置信息
PASSWORD="123456"                # 目标主机密码
USER="root"                      # 目标主机用户名（根据实际情况修改）
HOSTS=("192.168.32.167" "192.168.32.168" "192.168.32.169" "192.168.32.150" "192.168.32.151")  # 目标主机列表


# 生成SSH密钥对（如果不存在）
if [ ! -f ~/.ssh/id_rsa ]; then
    echo "生成SSH RSA密钥对..."
    ssh-keygen -t rsa -N "" -f ~/.ssh/id_rsa
fi

# 配置SSH密钥认证
for HOST in "${HOSTS[@]}"; do
    echo "正在为 $USER@$HOST 配置密钥认证..."
    
    # 禁用首次连接确认提示
    sshpass -p "$PASSWORD" ssh -o StrictHostKeyChecking=no $USER@$HOST "exit" 2>/dev/null
    
    # 复制公钥到目标主机
    if ! sshpass -p "$PASSWORD" ssh-copy-id $USER@$HOST &>/dev/null; then
        echo "错误：无法向 $HOST 复制公钥，请检查："
        echo "1. 网络连通性"
        echo "2. SSH服务状态（端口22）"
        echo "3. 用户名/密码是否正确"
        echo "4. 目标主机是否允许密码认证"
        exit 1
    fi
    
    echo "成功为 $HOST 配置密钥认证"
done

echo "所有目标主机密钥认证配置完成！"
