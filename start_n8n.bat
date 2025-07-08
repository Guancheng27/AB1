@echo off
REM ===============================================================
REM  start_n8n.bat —— 一键启动 n8n 脚本
REM  保存后双击运行即可：启动 Docker → 启动容器 → 打开浏览器
REM ===============================================================

REM 1. 启动 Docker Desktop（根据安装路径调整）
echo [1/4] 启动 Docker Desktop...
start "" "C:\Program Files\Docker\Docker\Docker Desktop.exe"

REM 2. 等待 Docker 引擎就绪
echo [2/4] 等待 Docker 引擎就绪...
:WAIT_DOCKER
docker info >nul 2>&1
if errorlevel 1 (
    timeout /t 5 /nobreak >nul
    goto WAIT_DOCKER
)
echo     Docker 已就绪。

REM 3. 启动或创建 n8n 容器
echo [3/4] 启动 n8n 容器 GC_Automation...
docker start GC_Automation >nul 2>&1
if errorlevel 1 (
    echo     容器 GC_Automation 不存在，正在创建新的容器...
    REM —— 如果你想使用固定密钥，请替换下面的 <YOUR_KEY> —— 
    docker run -d --name GC_Automation --restart unless-stopped ^
      -p 5678:5678 ^
      -e N8N_ENCRYPTION_KEY=3fe7c5c39bde9a778e2f0f5b84c97c1cfd4f3e7712aa54ac8762c6e276f631b9 ^
      -v n8n_data:/home/node/.n8n ^
      n8nio/n8n
    if errorlevel 1 (
      echo [错误] 无法创建容器，请检查命令和网络。
      pause
      exit /b 1
    )
) else (
    echo     容器已启动。
)

REM 4. 打开浏览器访问 n8n
echo [4/4] 打开 n8n 控制台...
start "" "http://localhost:5678"

echo.
echo ✅ 完成：n8n 已启动并打开浏览器！
exit /b 0
