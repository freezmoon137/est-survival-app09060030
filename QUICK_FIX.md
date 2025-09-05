# 🚀 EST生存分析Web应用 - 快速修复指南

## ❌ 问题描述
您遇到的错误：
```
pip._vendor.pyproject_hooks._impl.BackendUnavailable： 无法 导入 "setuptools.build_meta"
```

## ✅ 一键解决方案

### Windows用户（推荐）
```cmd
# 在 est_survival_web_app 文件夹中运行
deploy-setup.bat
```

### Linux/Mac用户
```bash
# 在 est_survival_web_app 文件夹中运行
bash deploy-setup.sh
```

## 🔧 手动解决步骤

如果自动脚本无法运行，请按以下步骤操作：

### 1. 切换依赖文件
```bash
# 备份原始文件
cp requirements.txt requirements-full.txt

# 使用兼容版本
cp requirements-minimal.txt requirements.txt
```

### 2. 确认配置文件

确保以下文件内容正确：

**runtime.txt:**
```
python-3.9.18
```

**render.yaml:** ✅ 已更新
**requirements-minimal.txt:** ✅ 已准备
**TROUBLESHOOTING.md:** ✅ 详细指南

### 3. 推送到GitHub
```bash
git add .
git commit -m "Fix deployment compatibility issues"
git push origin main
```

### 4. 在Render重新部署
1. 登录 [render.com](https://render.com)
2. 进入您的项目
3. 点击 "Manual Deploy" 或等待自动部署

## 🎯 解决原理

- **Python版本降级**：从3.13降到3.9.18（稳定版本）
- **正确的版本配置**：使用PYTHON_VERSION环境变量和.python-version文件，而不是runtime字段
- **依赖文件清理**：删除旧的requirements.txt，只使用requirements-minimal.txt
- **版本配置文件清理**：删除冲突的runtime.txt文件，避免与PYTHON_VERSION环境变量和.python-version文件产生配置冲突
- **依赖文件重定向**：创建requirements.txt作为重定向文件，确保Render使用render.yaml配置而不是默认构建命令
- **模板路径修复**：明确指定Flask应用的template_folder和static_folder绝对路径，解决Render部署环境中的模板文件找不到问题
- **依赖版本兼容**：修复Flask与Werkzeug的版本冲突（Werkzeug 2.3.6 → 2.3.7）
- **依赖简化**：移除problematic包（如scikit-survival）
- **构建工具固定**：使用兼容的setuptools和pip版本
- **详细日志**：增加构建过程可见性

## 📋 验证清单

部署前确认：
- [ ] 运行了部署准备脚本
- [ ] requirements.txt已切换到minimal版本
- [ ] 所有文件已推送到GitHub
- [ ] Render项目已连接到正确的仓库

## 🆘 如果仍有问题

1. 查看 `TROUBLESHOOTING.md` 获取详细指南
2. 检查Render构建日志中的具体错误
3. 确认GitHub仓库中的文件是最新的

---

**预期结果：** 部署成功，应用可通过Render提供的URL访问

**估计时间：** 5-10分钟