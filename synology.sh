#!/bin/bash

volume_number=1
max_attempts=10

video_path=""
docker_path=""
export device_path="/dev/dri"
export docker_compose_file="/root/docker-compose.yml"

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

# 检查设备文件是否存在
if [ ! -e "$device_path" ]; then
    # 使用sed命令删除指定的devices配置块
    # 注意：这里假设docker-compose.yaml文件中的devices部分是独立的
    # 如果devices部分跨越了多个服务，或者与其他服务共享，那么这个命令可能需要调整
    sed -i '/#1/,/#2/d' "$docker_compose_file"
    
    echo "已从 $docker_compose_file 删除相关devices配置。"
else
    echo "设备文件 $device_path 存在，无需修改。"
fi

# 启动docker-compose服务
docker-compose up
