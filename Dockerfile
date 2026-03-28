# 1. 使用 Node 18 (LTS) 版本，兼顾稳定性和新特性
# bullseye (Debian 11) 比 slim 更稳定，包含更多编译工具，避免 python/g++ 报错
FROM node:18-bullseye

MAINTAINER bygavin <bygavin>

ENV LANG C.UTF-8
WORKDIR /ws-scrcpy

# 2. 安装系统依赖
# 清理 apt 缓存以减小镜像层体积
RUN apt-get update && apt-get install -y \
    android-tools-adb \
    git \
    python3 \
    make \
    g++ \
    && rm -rf /var/lib/apt/lists/*

# 3. 优先复制依赖定义文件
COPY package.json package-lock.json* ./

# 4. 安装依赖
# 使用 npm ci 代替 npm install，确保依赖版本一致性，防止浮动版本导致报错
RUN npm ci --legacy-peer-deps

# 5. 复制项目代码
# 使用 COPY 代替 git clone，这样 Actions 检出的代码才会被构建进去
RUN git clone https://github.com/gavinliuisme/ws-scrcpy.git .

# 6. 关键修复：增加内存限制并构建
# 增大 Node 内存限制，防止构建过程中 "JavaScript heap out of memory"
RUN NODE_OPTIONS="--max-old-space-size=4096" npm run dist

EXPOSE 8000

CMD ["node","dist/index.js"]
