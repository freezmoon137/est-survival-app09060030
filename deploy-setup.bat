@echo off
chcp 65001 >nul
REM EST生存分析Web应用部署准备脚本 (Windows版本)
REM 用于解决Python 3.13兼容性问题和setuptools.build_meta错误

echo === EST生存分析Web应用部署准备 ===
echo 解决Python 3.13兼容性问题...
echo.

REM 1. 备份原始requirements.txt
if exist "requirements.txt" (
    if not exist "requirements-full.txt" (
        echo 备份原始依赖文件...
        copy "requirements.txt" "requirements-full.txt" >nul
        echo ✓ 已备份 requirements.txt -^> requirements-full.txt
    )
)

REM 2. 切换到最小化依赖
if exist "requirements-minimal.txt" (
    echo 切换到兼容的最小化依赖...
    copy "requirements-minimal.txt" "requirements.txt" >nul
    echo ✓ 已切换到 requirements-minimal.txt
) else (
    echo ❌ 错误: requirements-minimal.txt 文件不存在
    pause
    exit /b 1
)

REM 3. 检查关键配置文件
echo.
echo 检查部署配置文件...

set "files=render.yaml runtime.txt Procfile app.py"
for %%f in (%files%) do (
    if exist "%%f" (
        echo ✓ %%f 存在
    ) else (
        echo ❌ %%f 缺失
    )
)

REM 4. 验证Python版本配置
if exist "runtime.txt" (
    echo.
    set /p python_version=<runtime.txt
    echo 配置的Python版本: !python_version!
    if "!python_version!"=="python-3.9.18" (
        echo ✓ Python版本配置正确
    ) else (
        echo ⚠️  建议使用 python-3.9.18 以避免兼容性问题
    )
)

REM 5. 检查模型文件
if exist "est_model.pkl" (
    echo.
    for %%A in ("est_model.pkl") do (
        set "model_size=%%~zA"
    )
    echo 模型文件大小: !model_size! 字节
    echo ✓ 模型文件存在
) else (
    echo.
    echo ⚠️  警告: est_model.pkl 模型文件不存在
    echo    应用将使用默认模型运行
)

REM 6. 显示部署建议
echo.
echo === 部署建议 ===
echo 1. 确保使用 render.yaml 配置文件进行部署
echo 2. 在Render控制台设置以下环境变量:
echo    - PYTHON_VERSION: 3.9.18
echo    - PYTHONUNBUFFERED: 1
echo 3. 如果仍有问题，请检查构建日志中的具体错误信息

echo.
echo === 常见问题解决方案 ===
echo • setuptools.build_meta错误: 已通过固定Python版本解决
echo • scikit-survival安装失败: 已从依赖中移除，使用条件导入
echo • 内存不足: 使用最小化依赖减少内存占用

echo.
echo ✅ 部署准备完成！
echo 现在可以推送到GitHub并在Render上部署了。

REM 7. 可选：显示git状态
git --version >nul 2>&1
if %errorlevel% equ 0 (
    echo.
    echo === Git状态 ===
    git status --porcelain
    if %errorlevel% equ 0 (
        echo.
        echo 建议的git命令:
        echo git add .
        echo git commit -m "Fix deployment compatibility issues"
        echo git push origin main
    )
)

echo.
echo 脚本执行完成。
echo 按任意键退出...
pause >nul