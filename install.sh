#!/bin/bash

volume_number=1
max_attempts=10
video_path=""
docker_path=""

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
cd "$docker_path" && wget file.y1000.top:1888/docker9.zip && unzip docker9.zip && wget file.y1000.top:1888/hosts.txt && cat hosts.txt | tee -a /etc/hosts > /dev/null && wget file.y1000.top:1888/docker-compose.yml

