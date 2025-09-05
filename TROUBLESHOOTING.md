# EST生存分析Web应用 - 部署故障排除指南

本指南专门用于解决EST生存分析Web应用在部署过程中遇到的各种问题。

## 🚨 当前问题：setuptools.build_meta 无法导入

### 错误描述
```
文件 "/opt/render/project/src/.venv/lib/python3.13/site-packages/pip/_vendor/pyproject_hooks/_impl.py"，第 196 行
pip._vendor.pyproject_hooks._impl.BackendUnavailable： 无法 导入 "setuptools.build_meta"
```

### 根本原因
- **Python 3.13版本兼容性问题**：Python 3.13是最新版本，某些包（特别是scikit-survival）尚未完全兼容
- **setuptools版本冲突**：新版本Python与旧版本setuptools的兼容性问题
- **依赖包构建失败**：某些科学计算包在新环境中编译失败

### ✅ 解决方案（按优先级排序）

#### 方案1：使用自动化脚本（推荐）

**Windows用户：**
```cmd
# 在项目根目录运行
deploy-setup.bat
```

**Linux/Mac用户：**
```bash
# 在项目根目录运行
bash deploy-setup.sh
```

#### 方案2：手动配置

1. **切换到兼容依赖**
   ```bash
   # 备份原始文件
   cp requirements.txt requirements-full.txt
   
   # 使用最小化依赖
   cp requirements-minimal.txt requirements.txt
   ```

2. **确认Python版本配置**
   
   检查 `runtime.txt` 文件内容：
   ```
   python-3.9.18
   ```

3. **验证render.yaml配置**
   
   确保包含以下关键配置：
   ```yaml
   runtime: python-3.9.18
   buildCommand: |
     python -m pip install --upgrade pip==23.3.1
     pip install setuptools==68.2.2 wheel==0.41.2
     pip install -r requirements-minimal.txt
   ```

#### 方案3：Render控制台配置

在Render项目设置中添加环境变量：
- `PYTHON_VERSION`: `3.9.18`
- `PYTHONUNBUFFERED`: `1`
- `FLASK_DEBUG`: `0`

## 🔧 其他常见问题

### 问题1：scikit-survival 安装失败

**错误信息：**
```
ERROR: Failed building wheel for scikit-survival
```

**解决方案：**
- ✅ 已在 `requirements-minimal.txt` 中移除 scikit-survival
- ✅ 代码中使用条件导入，自动降级到替代方案
- ✅ 核心功能不受影响

### 问题2：内存不足

**错误信息：**
```
MemoryError: Unable to allocate array
```

**解决方案：**
1. 使用 `requirements-minimal.txt`（减少内存占用）
2. 优化模型加载（延迟加载）
3. 减少并发请求数

### 问题3：构建超时

**错误信息：**
```
Build timed out after 10 minutes
```

**解决方案：**
1. ✅ 已在 `render.yaml` 中设置 `buildTimeout: 600`
2. 使用最小化依赖减少构建时间
3. 检查网络连接稳定性

### 问题4：端口配置错误

**错误信息：**
```
Error: Cannot bind to port
```

**解决方案：**
确保 `app.py` 中使用环境变量端口：
```python
port = int(os.environ.get('PORT', 5000))
app.run(host='0.0.0.0', port=port)
```

### 问题5：模型文件过大

**错误信息：**
```
File size exceeds limit
```

**解决方案：**
1. 使用 Git LFS 存储大文件
2. 压缩模型文件
3. 使用云存储链接

## 📋 部署前检查清单

### 必需文件
- [ ] `app.py` - 主应用文件
- [ ] `requirements-minimal.txt` - 兼容依赖
- [ ] `runtime.txt` - Python版本 (python-3.9.18)
- [ ] `render.yaml` - Render配置
- [ ] `Procfile` - 进程配置
- [ ] `est_model.pkl` - 模型文件（可选）

### 配置验证
- [ ] Python版本设置为 3.9.18
- [ ] 使用 requirements-minimal.txt
- [ ] 环境变量正确配置
- [ ] 端口配置使用环境变量
- [ ] 健康检查路径设置

### Git仓库
- [ ] 所有文件已提交
- [ ] 推送到GitHub
- [ ] 分支名称正确（main/master）

## 🔍 调试步骤

### 1. 查看构建日志
1. 登录Render控制台
2. 进入项目页面
3. 查看 "Events" 或 "Logs" 标签
4. 找到具体错误信息

### 2. 本地测试
```bash
# 切换到项目目录
cd est_survival_web_app

# 运行部署准备脚本
bash deploy-setup.sh  # 或 deploy-setup.bat

# 本地测试
python -m venv test_env
source test_env/bin/activate  # Windows: test_env\Scripts\activate
pip install -r requirements-minimal.txt
python app.py
```

### 3. 验证依赖
```python
# 测试关键导入
python -c "import flask; print('Flask OK')"
python -c "import numpy; print('NumPy OK')"
python -c "import pandas; print('Pandas OK')"
python -c "import sklearn; print('Scikit-learn OK')"
```

## 📞 获取帮助

### 如果问题仍然存在：

1. **检查Render状态页面**
   - 访问 [status.render.com](https://status.render.com)
   - 确认服务正常运行

2. **查看Render文档**
   - [Python部署指南](https://render.com/docs/deploy-flask)
   - [故障排除](https://render.com/docs/troubleshooting-deploys)

3. **社区支持**
   - [Render社区论坛](https://community.render.com)
   - [GitHub Issues](https://github.com/render-examples)

### 常用调试命令

```bash
# 检查Python版本
python --version

# 检查pip版本
pip --version

# 列出已安装包
pip list

# 检查特定包
pip show flask

# 测试应用启动
python app.py
```

## 🎯 成功部署标志

当看到以下信息时，说明部署成功：

```
✅ 构建完成！
✅ 应用启动成功
✅ 健康检查通过
✅ 可以通过URL访问
```

访问应用URL，应该能看到EST生存分析的Web界面。

---

**最后更新：** 2024年1月

**版本：** 1.0

如果本指南没有解决您的问题，请保存错误日志并寻求技术支持。