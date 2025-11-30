# ShikenMatrix

<div align="center">

![License](https://img.shields.io/badge/license-AGPL%20v3.0-blue.svg)
![Tauri](https://img.shields.io/badge/Tauri-2.0-orange.svg)
![Vue](https://img.shields.io/badge/Vue-3.0-green.svg)

**一个现代化的跨平台桌面窗口与媒体信息展示工具**

[English](./README_EN.md) | [简体中文](./README.md)

</div>

## 📖 简介 | Introduction

ShikenMatrix 是一个基于 Tauri 构建的桌面应用程序，旨在提供优雅的窗口管理和媒体信息展示体验。它采用现代化的玻璃拟态（Glassmorphism）设计，能够实时显示当前前台窗口的详细信息以及正在播放的媒体内容。

本项目是 [**Kizuna**](https://github.com/AlienFamilyHub/Kizuna) 项目的继任者，在原有功能基础上进行了全面的重构和功能增强，提供更加现代化和跨平台的用户体验。

本项目采用 **GNU Affero General Public License v3.0** 开源协议。

## ✨ 特性 | Features

### 🖥️ 智能窗口信息展示

- **实时监控**：自动获取并显示当前活动窗口的标题、图标和进程信息
- **应用图标展示**：动态加载并显示前台应用的图标
- **窗口标题跟踪**：实时更新窗口标题变化

### 🎵 媒体播放集成

- **媒体元数据**：支持显示当前播放的音乐/视频标题、艺术家、专辑信息
- **专辑封面展示**：自动获取并显示高质量专辑封面
- **播放状态同步**：实时同步播放/暂停状态，仅在播放时显示媒体信息
- **跨应用支持**：支持系统级媒体控制（macOS 使用 MediaRemote，Windows 使用 SMTC）

### 🎨 现代化 UI 设计

- **玻璃拟态风格**：采用精美的 Acrylic/Glassmorphism 视觉效果，完美融入系统环境
- **自适应主题**：自动适配系统亮色/暗色模式，提供一致的视觉体验
- **自适应窗口**：窗口大小根据内容自动调整，确保最佳显示效果
- **流畅动画**：所有交互都配备精心设计的过渡动画

### 🎮 交互式窗口控制

- **拖拽移动**：按住顶部拖拽区域即可移动窗口
- **胶囊菜单**：双击或长按顶部区域打开交互式胶囊菜单
- **窗口操作**：支持关闭、最小化、置顶等常用窗口操作
- **视觉反馈**：所有交互都有清晰的视觉和动画反馈

### 🌐 跨平台支持

- **macOS**：深度优化，完整支持所有功能
- **Windows**：已适配，支持窗口信息和媒体控制
- **架构设计**：采用平台抽象层（`platform` 模块），便于扩展到其他操作系统

## 🚀 快速开始 | Quick Start

### 环境要求

- **Node.js**: 18.x 或更高版本
- **pnpm**: 8.x 或更高版本
- **Rust**: 1.70 或更高版本（通过 [rustup](https://rustup.rs/) 安装）

### 安装与运行

```bash
# 克隆项目
git clone https://github.com/TNXG/ShikenMatrix.git
cd ShikenMatrix

# 安装依赖
pnpm install

# 开发模式运行
pnpm tauri dev

# 构建生产版本
pnpm tauri build
```

### 权限配置

#### macOS

首次运行时，应用会请求**辅助功能权限**，这是获取前台窗口信息所必需的：

1. 打开 **系统设置** > **隐私与安全性** > **辅助功能**
2. 找到 `shikenmatrix` 并勾选启用
3. 重启应用

> 如遇“无法打开，因为它来自身份不明的开发者”，可在“系统设置 → 隐私与安全性”中允许该程序运行，或在终端执行：

```bash
xattr -d com.apple.quarantine /Applications/shikenmatrix.app
```

#### Windows

Windows 系统对窗口信息访问的权限管理相对宽松，通常无需额外配置即可正常使用。

## 💡 使用说明 | Usage

### 基本操作

- **移动窗口**：按住顶部拖拽区域（显示为三点横线指示器）并拖动
- **打开菜单**：双击或长按顶部拖拽区域，会弹出胶囊菜单
- **关闭窗口**：点击胶囊菜单中的红色关闭按钮
- **最小化**：点击胶囊菜单中的黄色最小化按钮
- **窗口置顶**：点击胶囊菜单中的蓝色置顶按钮（再次点击取消置顶）

### 界面说明

应用界面分为两个主要部分：

1. **前台窗口信息卡片**（始终显示）
   - 显示当前活动窗口的应用图标
   - 显示应用名称和窗口标题

2. **媒体播放信息卡片**（仅在播放时显示）
   - 显示专辑封面
   - 显示歌曲名称、艺术家和专辑信息
   - 自动隐藏（当媒体暂停或无播放内容时）

## 🏗️ 项目结构 | Project Structure

```
ShikenMatrix/
├── src/                      # Vue 前端代码
│   ├── app.vue              # 应用主组件（窗口控制、拖拽）
│   ├── pages/               # 页面组件
│   │   └── index.vue        # 主页面（数据获取、窗口调整）
│   ├── components/          # UI 组件
│   │   ├── ForegroundWidget.vue  # 前台窗口信息组件
│   │   └── MediaWidget.vue       # 媒体播放信息组件
│   └── assets/              # 样式和资源
│       └── main.css         # 全局样式和 CSS 变量
├── src-tauri/               # Rust 后端代码
│   ├── src/
│   │   ├── lib.rs          # Tauri 命令定义
│   │   ├── main.rs         # 应用入口
│   │   └── platform/       # 平台抽象层
│   │       ├── mod.rs      # 平台接口定义
│   │       ├── macos/      # macOS 平台实现
│   │       └── windows/    # Windows 平台实现
│   └── Cargo.toml          # Rust 依赖配置
├── AGENTS.md               # 设计规范文档
└── README.md               # 项目说明文档
```

## 🔧 开发指南 | Development Guide

### 技术架构概述

**前端（Vue 3 + TypeScript）**

- 使用 Composition API 和 `<script setup>` 语法
- 基于 SCSS 的模块化样式系统
- 使用 CSS 变量实现主题切换
- GSAP 驱动的流畅动画系统

**后端（Rust + Tauri）**

- 平台抽象层设计，统一的接口定义
- 使用 `#[tauri::command]` 暴露系统级功能
- 异步任务处理（基于 tokio）
- 平台特定实现（macOS 使用 Objective-C 绑定，Windows 使用 WinAPI）

### 添加新功能

1. **后端功能**：在 `src-tauri/src/platform/` 中添加平台接口和实现
2. **前端组件**：在 `src/components/` 中创建新的 Vue 组件
3. **设计规范**：参考 `AGENTS.md` 确保符合设计语言

### 设计规范

详细的设计规范请参阅 [`AGENTS.md`](./AGENTS.md)，包括：

- UI 布局和响应式策略
- 颜色系统和主题适配
- 动画设计原则
- 组件化开发规范

## 🛠️ 技术栈 | Tech Stack

**前端技术**

- Vue 3 - 渐进式 JavaScript 框架
- TypeScript - 类型安全的 JavaScript 超集
- Nuxt 3 - Vue.js 框架
- GSAP - 专业级动画库
- SCSS - CSS 预处理器

**后端技术**

- Rust - 系统级编程语言
- Tauri 2.0 - 轻量级桌面应用框架
- tokio - 异步运行时

**平台集成**

- macOS: Core Foundation, AppKit, MediaRemote
- Windows: WinAPI, Windows Media Control

## ❓ 常见问题 | FAQ

### 💻 macOS 相关

### Q: 为什么 macOS 上无法获取窗口信息？

A: 请确保已授予应用辅助功能权限。前往 **系统设置** > **隐私与安全性** > **辅助功能**，勾选 `shikenmatrix`。

### 💻 Windows 相关

A: 网易云音乐（等国内音乐播放器）不按照微软官方的媒体渠道上报媒体信息（即 Windows System Media Control 集成）。从 Windows 10 版本 1607 开始，默认情况下，使用 `MediaPlayer` 类或 `AudioGraph` 类播放媒体的 UWP 应用会自动与 SMTC 集成。只需实例化 `MediaPlayer` 的新实例，并将 `MediaSource`、`MediaPlaybackItem` 或 `MediaPlaybackList` 分配给播放器的 `Source` 属性，然后用户将在 SMTC 中看到你的应用名称，并且可以使用 SMTC 控件播放、暂停和在播放列表中移动。 -- Windows文档

这时需要其他方法来使本程序的媒体上报结构生效，可以通过插件使其通过 SMTC 上报信息。
对于网易云音乐，可以尝试使用 `MicroCBer/BetterNCM` 和 `BetterNCM/InfinityLink` 搭配使用。

> TL;DR:
>
> 国内音乐播放器（如网易云音乐）未采用 Windows 标准媒体控制接口 (SMTC)，导致无法显示媒体信息。可通过安装特定插件（如网易云音乐的 `BetterNCM` + `InfinityLink`）来解决。

### ❓ 通用问题

### Q: 媒体信息不显示怎么办？

A: 媒体信息仅在有音乐/视频正在播放时显示。请确保：

- 系统中有媒体正在播放
- 播放器支持系统级媒体控制（如 Apple Music、Spotify、Chrome 等）

### Q: 窗口大小可以调整吗？

A: 窗口大小会根据内容自动调整，以确保最佳显示效果。当前版本不支持手动调整大小。

### Q: 支持哪些操作系统？

A: 目前完整支持 macOS 和 Windows。Linux 支持正在开发中。

### Q: 如何贡献代码？

A: 欢迎提交 Pull Request！请确保：

- 遵循项目的代码风格和设计规范（参考 `AGENTS.md`）
- 为新功能添加适当的注释
- 测试在不同平台上的兼容性

## 📄 许可证 | License

本项目基于 [GNU Affero General Public License v3.0](LICENSE.md) 授权。

## 👨‍💻 开发者 | Developer

Developed by **TNXG**
GitHub: [https://github.com/TNXG](https://github.com/TNXG)

## 🙏 致谢 | Acknowledgments

- [Tauri](https://tauri.app/) - 强大的桌面应用框架
- [Vue.js](https://vuejs.org/) - 渐进式 JavaScript 框架
- [GSAP](https://greensock.com/gsap/) - 专业动画库
- [mediaremote-rs](https://crates.io/crates/mediaremote-rs) - macOS 媒体控制库（还是我开发的）
