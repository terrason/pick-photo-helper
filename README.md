# 挑挑拣拣 — Pick Photo Helper

[![AUR](https://img.shields.io/aur/version/pick-photo-helper)](https://aur.archlinux.org/packages/pick-photo-helper)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![GNOME](https://img.shields.io/badge/GNOME-✓-4a86cf?logo=gnome&logoColor=white)](https://apps.gnome.org/Loupe/)
[![Arch Linux](https://img.shields.io/badge/Arch_Linux-✓-1793D1?logo=arch-linux&logoColor=white)](PKGBUILD)

> 📷 **照片多轮筛选助手** — 在 Loupe 中浏览，全局快捷键一键收藏，逐轮精炼选出你最爱的照片。

---

**为什么会有这个工具？**

拿到一批照片——少则几十，多则几百——你需要在里面选出最好的那几张。

这个过程通常不是一次完成的：先快速划掉明显不行的，再在同风格组里挑最有代表性的，然后跟家人商量一下，再筛一轮，最后留下的才是你想要的。

大部分 macOS 照片管理和专业图库软件都有类似的多轮筛选功能。但在 Linux（尤其是 Arch Linux + GNOME）上，自带图库要么太轻量没有这个功能，要么得装一套 heavy 的解决方案（digiKam、Shotwell……），而且很多时候你并不想为了一个需求装一整个照片管理套件。

**这个工具就是为此而生。**

同时也是一次学习实践——通过这个项目深入了解了 Linux 桌面生态中的 dconf/gsettings 全局快捷键、systemd scope 进程管理、AT-SPI 无障碍接口、FIFO 跨进程通信、AUR 打包发布……等等。

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

每层只保留指向原图的**相对符号链接**，不复制文件，不占额外空间。

---

## ✨ 特性

- 🖼️ **多格式支持** — `jpg` / `jpeg` / `png` / `webp` / `avif` / `heic` / `heif` / `tiff` / `bmp` / `gif`
- ⌨️ **全局快捷键** — 无需切换窗口，在 Loupe 中按 `Ctrl+Space` 直接收藏
- 📂 **多轮筛选** — 逐层精炼，每层结果独立文件夹保存，随时回溯
- 🔗 **符号链接，零拷贝** — 收藏即创建指向原图的符号链接，不复制文件
- 🖥️ **双击友好** — 双击脚本自动打开终端，无需手敲命令行
- 🔔 **桌面通知** — 每次操作桌面即时反馈
- 🧹 **自动化清理** — 退出自动移除全局快捷键和临时文件，不留痕迹

---

## 🖼️ 效果预览

```
  ┌──────────────────────────────────────────────────┐
  │  📷 挑挑拣拣 — 照片多轮筛选助手                    │
  ├──────────────────────────────────────────────────┤
  │  层级 1 | 总数: 43 | 已选: 12                     │
  │  当前: DSC_0821.jpg                              │
  ├──────────────────────────────────────────────────┤
  │  Ctrl+Space 收藏/放回    Ctrl+A 全收藏            │
  │  Ctrl+Down 往下筛    Ctrl+Up 回头看               │
  └──────────────────────────────────────────────────┘
```

---

## 📦 依赖

> 所有依赖在主流 Linux 发行版中均可安装，**唯一要求是 GNOME 桌面环境**（因为依赖 Loupe 和 AT-SPI）。

| 包 | Arch Linux | Fedora | Ubuntu/Debian | 用途 |
|----|:----------:|:------:|:-------------:|------|
| Loupe | `loupe` | `loupe` | `gnome-loupe` | 图片查看器 |
| systemd | 系统自带 | 系统自带 | 系统自带 | scope 进程生命周期管理 |
| Python | `python` | `python3` | `python3` | 运行脚本 |
| PyGObject | `python-gobject` | `python3-gobject` | `python3-gi` | AT-SPI Python 绑定 |
| AT-SPI2 | `at-spi2-core` | `at-spi2-core` | `at-spi2-core` | GNOME 无障碍接口 |
| libnotify | `libnotify` | `libnotify` | `libnotify` | 桌面通知 |
| zenity | `zenity` | `zenity` | `zenity` | 可选 — 无终端时的 GUI 错误提示 |

---

## 🚀 安装

### AUR（Arch Linux）

```bash
pikaur -S pick-photo-helper
```

### 其他发行版（手动运行）

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

脚本会自动扫描当前目录中所有支持的图片文件，打开 Loupe 开始浏览。

---

## ⌨️ 快捷键

| 快捷键 | 操作 |
|--------|------|
| `Ctrl+Space` | ❤️ 收藏当前图片 / 💔 放回 |
| `Ctrl+A` | ❤️ 一键全收藏 |
| `Ctrl+Down` | ✨ 进入下一层（往下筛） |
| `Ctrl+Up` | 🔙 返回上一层（回头看） |
| 关闭 Loupe | ✕ 退出程序 |

所有快捷键在运行时自动注册为 GNOME 全局快捷方式，退出时自动清理。

---

## 🔧 工作原理

1. **启动** — 扫描当前目录中的图片作为第 0 轮，通过 gsettings/dconf 注册全局快捷键，创建 FIFO 命令管道
2. **浏览** — 自动打开 Loupe 显示图片，通过 AT-SPI（GNOME 无障碍接口）读取 Loupe 窗口标题获得文件名
3. **收藏** — `Ctrl+Space` → 脚本从 FIFO 收到信号 → 通过 AT-SPI 获取当前文件名 → 在 `layer{N+1}/` 创建相对符号链接
4. **推进** — `Ctrl+Down` → 杀死当前 Loupe（systemd scope） → 在下一层打开第一张图片继续筛选
5. **回溯** — `Ctrl+Up` → 返回上一层，之前的收藏全部保留
6. **退出** — 关闭 Loupe → 脚本监测到 systemd scope 停止 → 自动清理快捷键和 FIFO

脚本内部以 `select.poll()` 500ms 间隔轮询 FIFO 和 Loupe 进程状态，实现轻量级事件循环。

### 架构一览

```
┌──────────────┐     FIFO (/tmp/image_filter_cmd)    ┌──────────────────┐
│  Global Keys │────── Ctrl+Space/Ctrl+Down ─────────▶│  pick_photo_     │
│  (dconf)     │                                      │  helper.py       │
│              │     ┌──── systemd scope ──────┐      │  (poll loop)     │
│  python3     │────▶│  Loupe (image viewer)   │      │                  │
│  --cmd T     │     │  ─ AT-SPI ─ window title│◀─────│  get_loupe_      │
└──────────────┘     └─────────────────────────┘      │  filename()      │
                                                      └──────────────────┘
                                                               │
                                                               ▼
                                                      ┌──────────────────┐
                                                      │  layer{N}/       │
                                                      │  (symlinks)      │
                                                      └──────────────────┘
```

---

## 📄 License

MIT © [terrason](https://github.com/terrason)
