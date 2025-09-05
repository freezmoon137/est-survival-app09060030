#!/bin/bash
# EST生存分析Web应用部署准备脚本
# 用于解决Python 3.13兼容性问题和setuptools.build_meta错误

echo "=== EST生存分析Web应用部署准备 ==="
echo "解决Python 3.13兼容性问题..."

# 1. 备份原始requirements.txt
if [ -f "requirements.txt" ] && [ ! -f "requirements-full.txt" ]; then
    echo "备份原始依赖文件..."
    cp requirements.txt requirements-full.txt
    echo "✓ 已备份 requirements.txt -> requirements-full.txt"
fi

# 2. 切换到最小化依赖
if [ -f "requirements-minimal.txt" ]; then
    echo "切换到兼容的最小化依赖..."
    cp requirements-minimal.txt requirements.txt
    echo "✓ 已切换到 requirements-minimal.txt"
else
    echo "❌ 错误: requirements-minimal.txt 文件不存在"
    exit 1
fi

# 3. 检查关键配置文件
echo "\n检查部署配置文件..."

files_to_check=("render.yaml" "runtime.txt" "Procfile" "app.py")
for file in "${files_to_check[@]}"; do
    if [ -f "$file" ]; then
        echo "✓ $file 存在"
    else
        echo "❌ $file 缺失"
    fi
done

# 4. 验证Python版本配置
if [ -f "runtime.txt" ]; then
    python_version=$(cat runtime.txt)
    echo "\n配置的Python版本: $python_version"
    if [[ "$python_version" == "python-3.9.18" ]]; then
        echo "✓ Python版本配置正确"
    else
        echo "⚠️  建议使用 python-3.9.18 以避免兼容性问题"
    fi
fi

# 5. 检查模型文件
if [ -f "est_model.pkl" ]; then
    model_size=$(du -h est_model.pkl | cut -f1)
    echo "\n模型文件大小: $model_size"
    echo "✓ 模型文件存在"
else
    echo "\n⚠️  警告: est_model.pkl 模型文件不存在"
    echo "   应用将使用默认模型运行"
fi

# 6. 显示部署建议
echo "\n=== 部署建议 ==="
echo "1. 确保使用 render.yaml 配置文件进行部署"
echo "2. 在Render控制台设置以下环境变量:"
echo "   - PYTHON_VERSION: 3.9.18"
echo "   - PYTHONUNBUFFERED: 1"
echo "3. 如果仍有问题，请检查构建日志中的具体错误信息"

echo "\n=== 常见问题解决方案 ==="
echo "• setuptools.build_meta错误: 已通过固定Python版本解决"
echo "• scikit-survival安装失败: 已从依赖中移除，使用条件导入"
echo "• 内存不足: 使用最小化依赖减少内存占用"

echo "\n✅ 部署准备完成！"
echo "现在可以推送到GitHub并在Render上部署了。"

# 7. 可选：显示git状态
if command -v git &> /dev/null; then
    echo "\n=== Git状态 ==="
    git status --porcelain
    if [ $? -eq 0 ]; then
        echo "\n建议的git命令:"
        echo "git add ."
        echo "git commit -m \"Fix deployment compatibility issues\""
        echo "git push origin main"
    fi
fi

echo "\n脚本执行完成。"