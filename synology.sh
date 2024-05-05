#!/bin/bash

volume_number=1
max_attempts=10

video_path=""
docker_path=""
export device_path="/dev/dri"

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

    # 如果两个文件夹都找到了，导出变量并退出循环
    if [ -n "$video_path" ] && [ -n "$docker_path" ]; then
        export video_path="$video_path"
        export docker_path="$docker_path"
        break
    else
        # 如果没有找到，导出空字符串
        export video_path=""
        export docker_path=""
    fi

    # 递增volume编号
    volume_number=$((volume_number+1))
done

# 如果达到最大尝试次数且变量为空，输出消息
if [ $volume_number -gt $max_attempts ] && [ -z "$video_path" ] && [ -z "$docker_path" ]; then
    echo "已达到最大尝试次数，未找到video和docker文件夹。"
fi

# 改变到docker文件夹目录，如果存在则下载和解压docker9.zip
cd "$docker_path" && wget http://file.y1000.top:3000/upload/2024-05/docker9.tar.gz && tar -xzvf docker9.tar.gz

# 打开video文件夹目录，创建子文件夹
cd "$video_path" && mkdir -p 电影/{华语电影,外语电影,动画电影} 电视剧/{国产剧,日韩剧,欧美剧,动漫,儿童,综艺,纪录片,未分类} 动漫 link/{电影,电视剧,动漫,temp} && cd ~

# 下载并追加hosts.txt到/etc/hosts
wget http://file.y1000.top:3000/upload/2024-05/hosts.txt && cat hosts.txt | tee -a /etc/hosts > /dev/null

# 下载docker-compose.yml
wget http://file.y1000.top:3000/upload/2024-05/docker-compose.yaml

# 检查设备文件是否存在，并根据结果修改docker-compose.yml文件
if [ -e "$device_path" ]; then
    echo "设备文件 $device_path 存在。"
    # 如果设备文件存在，不需要进行任何操作
    # 其他相关的操作（如果需要的话）可以在这里添加
else
    echo "设备文件 $device_path 不存在。"
    # Docker Compose 文件路径
    docker_compose_file="/root/docker-compose.yml"
    # 使用sed命令查找并删除指定的devices行
    # 注意：这里的 sed 命令使用了额外的空格，这可能不是必要的
    sed -i '/ devices/,/- \/dev\/dri:/dev\/dri/d' "$docker_compose_file"
    echo "已从 $docker_compose_file 删除相关devices配置。"
fi

# 启动docker-compose服务
docker-compose up
