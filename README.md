# 挑挑拣拣 — Pick Photo Helper

> 📷 照片多轮筛选助手：在 Loupe 图片查看器中浏览，全局快捷键一键收藏/跳过，逐轮精炼选片。

一个使用 GNOME 图片查看器 Loupe 配合全局快捷键的迭代式选片工具。适合从大量照片中快速筛选出满意的那几张，每一轮的结果通过符号链接保存，不做复制，不占额外空间。

---

## ⚡ 工作流程

```
[当前目录]        ← 原始图片 ← 第 0 轮（源目录）
    │
    ├─ Ctrl+Space  收藏喜欢的
    │
    ▼
[layer1/]         ← 符号链接 ← 第 1 轮
    │
    ├─ Ctrl+Space  进一步筛选
    │
    ▼
[layer2/]         ← 符号链接 ← 第 2 轮
    │
    ├─ ...
    │
    ▼
[layerN/]         ← 你最终选出的最爱
```

每层只保留指向原图的符号链接，不会复制图片文件。

---

## ✨ 特性

- 🖼️ **多格式支持** — `jpg` / `jpeg` / `png` / `webp` / `avif` / `heic` / `heif` / `tiff` / `bmp` / `gif`
- ⌨️ **全局快捷键** — 无需切换窗口，在 Loupe 中直接操控
- 📂 **多轮筛选** — 逐层精炼，每层结果独立文件夹保存
- 🔗 **符号链接追踪** — 收藏即创建符号链接，不复制文件
- 🖥️ **双击友好** — 双击脚本自动打开终端，无需手敲命令行
- 🔔 **桌面通知** — 每次操作都有即时反馈

---

## 📦 依赖

| 包名 | 用途 | 必需 |
|------|------|:----:|
| `loupe` | GNOME 图片查看器 | ✅ |
| `systemd` | 进程生命周期管理（`--user --scope`） | ✅ |
| `python` | 运行脚本 | ✅ |
| `python-gobject` | Python 绑定，通过 AT-SPI 读取 Loupe 窗口标题 | ✅ |
| `at-spi2-core` | GNOME 无障碍接口 | ✅ |
| `libnotify` | 桌面通知 | ✅ |
| `zenity` | 未找到终端时的 GUI 错误提示 | ❌ |

---

## 🚀 安装并运行

### AUR（Arch Linux）

```bash
pikaur -S pick-photo-helper
```

### 手动运行（从源码）

```bash
git clone https://github.com/terrason/pick-photo-helper.git
cd pick-photo-helper
python3 pick_photo_helper.py
```

### 📂 使用方法

切入包含图片的目录，然后运行：

```bash
cd /path/to/your/photos
pick-photo-helper       # AUR 安装后
# 或
python3 /path/to/pick_photo_helper.py   # 未安装时
```

脚本会扫描当前目录中所有支持的图片文件，自动打开 Loupe 开始浏览。

---

## ⌨️ 快捷键

| 快捷键 | 操作 |
|--------|------|
| `Ctrl+Space` | ❤️ 收藏当前图片 / 💔 放回 |
| `Ctrl+A` | ❤️ 一键全收藏 |
| `Ctrl+Down` | ✨ 进入下一层 |
| `Ctrl+Up` | 🔙 返回上一层 |
| 关闭 Loupe | ✕ 退出程序 |

所有快捷键在第一次运行脚本时自动注册为 GNOME 全局快捷方式，退出时自动清理。

---

## 🔧 工作原理

1. **启动** — 扫描当前目录中所有支持的图片文件作为第 0 轮，通过 gsettings/dconf 注册全局快捷键，创建 `/tmp/image_filter_cmd` FIFO 管道
2. **浏览** — 自动打开 Loupe 显示当前图片，通过 AT-SPI 读取 Loupe 窗口标题获取文件名
3. **收藏** — 按 `Ctrl+Space` → 脚本收到 FIFO 信号 → 读取 Loupe 标题 → 在 `layer{N+1}/` 中创建指向原图的**相对符号链接**
4. **推进** — 按 `Ctrl+Down` → 杀死当前 Loupe → 在下一层打开第一张图片
5. **回溯** — 按 `Ctrl+Up` → 返回上一层继续筛选
6. **退出** — 关闭 Loupe → 脚本监测到 `systemd scope` 停止 → 自动清理快捷键和 FIFO

脚本通过 `select.poll()` 以 500ms 间隔轮询 FIFO 和 Loupe 进程状态，实现跨进程响应。

---

## 📄 License

MIT © [terrason](https://github.com/terrason)
