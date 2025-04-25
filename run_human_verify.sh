#!/bin/bash
# 视频管理系统一键启动脚本（最终修复版）

# 配置默认参数
DEFAULT_VIDEO_ROOT="./"
DEFAULT_HOST="0.0.0.0"
DEFAULT_PORT="5000"

export CODE_LIB='_human_verification'

# 解析命令行参数
while [[ $# -gt 0 ]]; do
    case "$1" in
        --video-root)
            VIDEO_ROOT="$2"
            shift 2 ;;
        --host)
            HOST="$2"
            shift 2 ;;
        --port)
            PORT="$2"
            shift 2 ;;
        *) 
            echo "未知参数: $1"
            exit 1 ;;
    esac
done

# 设置绝对路径
VIDEO_ROOT=$(realpath "${VIDEO_ROOT:-$DEFAULT_VIDEO_ROOT}")
HOST=${HOST:-$DEFAULT_HOST}
PORT=${PORT:-$DEFAULT_PORT}

# 依赖检查
check_dependency() {
    if ! command -v "$1" &> /dev/null; then
        echo "错误: 未找到 $1"
        exit 1
    fi
}

check_dependency python3
check_dependency pip3

# 安装依赖
if ! python3 -c "import flask" &> /dev/null; then
    echo "正在安装Flask..."
    pip3 install flask || {
        echo "Flask安装失败，请手动执行：pip3 install flask"
        exit 1
    }
fi

# 创建必要目录
mkdir -p "${VIDEO_ROOT}/_removed_video" || {
    echo "无法创建_removed_video目录"
    exit 1
}

export VIDEO_ROOT=$VIDEO_ROOT

# 启动服务
echo "======================================================"
echo "服务启动信息："
echo "视频根目录：${VIDEO_ROOT}"
echo "扫描到以下视频文件："
find "${VIDEO_ROOT}" -name "*.mp4" -not -path "*_removed_video/*" -printf "  → %p\n"
echo "------------------------------------------------------"
echo "访问地址：http://${HOST}:${PORT}"
echo "操作提示："
echo "1. 勾选视频复选框后点击确认按钮"
echo "2. 被选视频会移动到_removed_video目录"
echo "3. 使用 Ctrl+C 停止服务"
echo "======================================================"

python3 _human_verification/server.py