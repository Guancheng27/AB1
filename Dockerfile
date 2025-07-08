# Dockerfile
FROM n8nio/n8n:latest

# 切换到 root 安装 apk 包
USER root

# 安装 poppler-utils（包含 pdftotext）
RUN apk update \
 && apk add --no-cache poppler-utils

# 清理缓存（可选）
RUN rm -rf /var/cache/apk/*

# 切回 n8n 默认用户
USER node
