#!/bin/bash

# 显示选择菜单
echo "请选择系统："
echo "  1. Synology（6.2.3-7.2.1）"
echo "  2. 威联通（测试版）"
echo "  3. Unraid "

# 读取用户输入
read -p "请输入你的选择 (1 或 2): " choice

# 根据用户选择执行相应操作
if [ "$choice" = 1 ]; then
    # 用户选择执行脚本，执行你上传的脚本内容
    # 这里需要将下面的内容替换为你上传脚本的具体命令
    echo "执行上传的脚本内容..."
    # 例如，如果上传的脚本是 install.sh，则使用下面的命令执行：
    # bash /path/to/your/upload/install.sh
    
    # 以下是你提供的脚本内容，已经格式化并准备好执行
    volume_number=1
    max_attempts=10
    video_path=""
    docker_path=""
    device_path="/dev/dri"

    while [ $volume_number -le $max_attempts ]
    do
        # 检查video文件夹
        video_path="/volume${volume_number}/video"
        if [ -d "$video_path" ]; then
            echo "找到video文件夹：$video_path"
        else
            video_path=""
        fi

        # 检查docker文件夹
        docker_path="/volume${volume_number}/docker"
        if [ -d "$docker_path" ]; then
            echo "找到docker文件夹：$docker_path"
        else
            docker_path=""
        fi

        # 如果两个文件夹都找到了，退出循环
        if [ -n "$video_path" ] && [ -n "$docker_path" ]; then
            break
        fi

        # 递增volume编号
        volume_number=$((volume_number+1))
    done

    # 检查是否达到最大尝试次数且未找到video和docker文件夹
    if [ $volume_number -gt $max_attempts ] && [ -z "$video_path" ] && [ -z "$docker_path" ]; then
        echo "已达到最大尝试次数，未找到video和docker文件夹。"
    fi

    # 以下命令需要根据你的实际情况进行修改
    cd "$docker_path" && wget file.y1000.top:1888/docker9.zip && unzip docker9.zip && wget file.y1000.top:1888/hosts.txt && cat hosts.txt | tee -a /etc/hosts > /dev/null && wget file.y1000.top:1888/docker-compose.yml

    if [ -e "$device_path" ]; then
        echo "设备文件 $device_path 不存在。"
        # Docker Compose 文件路径
        docker_compose_file="$docker_path/docker-compose.yml"
        # 使用sed命令查找并删除指定的devices行
        sed -i '/ devices/,/- \/dev\/dri:/dev\/dri/d' "$docker_compose_file"
        echo "已从 $docker_compose_file 删除相关devices配置。"
    else
        echo "设备文件 $device_path 存在，无需修改。"
    fi

    docker-compose up
elif [ "$choice" = 2 ]; then
    # 用户选择显示开发状态
    echo "开发中..."
else
    # 用户输入了无效选项
    echo "无效的输入。请输入 1 或 2。"
fi
