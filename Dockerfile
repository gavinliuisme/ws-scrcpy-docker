# 1. 升级基础镜像版本，Node 16 对应的 Debian 已过旧，容易导致 apt 源失效
FROM node:20-slim

MAINTAINER bygavin <bygavin>

ENV LANG C.UTF-8
WORKDIR /ws-scrcpy

# 2. 优化 apt 命令
# 使用 && 连接，确保 update 成功后才执行 install
# 安装必要的编译工具，ws-scrcpy 需要编译原生模块
RUN apt-get update && apt-get install -y \
    android-tools-adb \
    git \
    python3 \
    make \
    g++ \
    && rm -rf /var/lib/apt/lists/*

# 3. 全局安装 node-gyp (通常包含在 node 镜像中，但显式安装确保版本兼容)
RUN npm install -g node-gyp

# 4. 克隆代码
RUN git clone https://github.com/gavinliuisme/ws-scrcpy.git .

# 5. 安装依赖并构建
RUN npm install
RUN npm run dist

EXPOSE 8000

CMD ["node","dist/index.js"]
