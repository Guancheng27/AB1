@echo off
REM ===============================================================
REM start_n8n_reset.bat —— 停止、清理、重置并启动全新 n8n 环境
REM ===============================================================

REM 1. 启动 Docker Desktop（根据实际安装路径调整）
echo [1/7] 启动 Docker Desktop...
start "" "C:\Program Files\Docker\Docker\Docker Desktop.exe"

REM 2. 等待 Docker 引擎就绪
echo [2/7] 等待 Docker 引擎就绪...
:WAIT_DOCKER
docker info >nul 2>&1
if errorlevel 1 (
    timeout /t 5 /nobreak >nul
    goto WAIT_DOCKER
)
echo     Docker 已就绪。

REM 3. 停止并删除旧容器
echo [3/7] 停止并删除旧容器 GC_Automation...
docker stop GC_Automation 2>nul
docker rm GC_Automation 2>nul

REM 4. 删除旧数据卷并重建
echo [4/7] 删除并重建数据卷 n8n_data...
docker volume rm n8n_data 2>nul
docker volume create n8n_data

REM 5. 生成新的加密密钥
echo [5/7] 生成新的 N8N_ENCRYPTION_KEY...
for /f "usebackq delims=" %%i in (
  `powershell -NoProfile -Command "[System.BitConverter]::ToString((1..32 | ForEach-Object{Get-Random -Maximum 256}));" ^| %{$_ -replace '-' ,''} ^| %{$_.ToLower()}"`) do set "KEY=%%i"
echo     新密钥： %KEY%

REM 6. 启动全新 n8n 容器
echo [6/7] 启动 n8n 容器 GC_Automation...
docker run -d --name GC_Automation --restart unless-stopped ^
  -p 5678:5678 ^
  -e N8N_ENCRYPTION_KEY=%KEY% ^
  -v n8n_data:/home/node/.n8n ^
  n8nio/n8n

REM 7. 打开浏览器访问 n8n
echo [7/7] 打开 n8n 控制台...
start "" "http://localhost:5678"

echo.
echo ✅ 全新 n8n 环境已启动，浏览器已打开！
exit /b 0
