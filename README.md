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

本项目采用 **GNU Affero General Public License v3.0** 开源协议。

## ✨ 特性 | Features

### 🖥️ 智能窗口信息展示
- **实时监控**：自动获取并显示当前活动窗口的标题、图标和进程信息。

### 🎵 媒体播放集成
- **媒体元数据**：支持显示当前播放的音乐/视频标题、艺术家、专辑封面等信息。
- **播放状态同步**：实时同步播放/暂停状态。

### 🎨 现代化 UI 设计
- **玻璃拟态风格**：采用精美的 Acrylic/Glassmorphism 视觉效果，完美融入系统环境。
- **胶囊菜单**：独特的交互式胶囊菜单，提供便捷的窗口控制（关闭、最小化、置顶）。
- **流畅动画**：基于 GSAP 的丝滑交互动画体验。

### 🌐 跨平台架构设计
虽然目前主要针对 macOS 进行了深度优化，但 ShikenMatrix 的底层架构（`platform` 模块）采用了面向接口的设计，预留了 **Windows** 和 **Linux** 的支持接口。这意味着它并非仅为 macOS 设计，未来可以轻松扩展到其他操作系统。

## 🛠️ 技术栈 | Tech Stack

- **Frontend**: Vue 3, TypeScript, SCSS, GSAP
- **Backend**: Rust, Tauri 2.0
- **Platform Integration**: Native system APIs (via Rust)

## 📦 安装与构建 | Build & Install

```bash
# 安装依赖
pnpm install

# 开发模式运行
pnpm tauri dev

# 构建生产版本
pnpm tauri build
```

## 📄 许可证 | License

本项目基于 [GNU Affero General Public License v3.0](LICENSE) 授权。

## 👨‍💻 开发者 | Developer

Developed by **TNXG**.
GitHub: [https://github.com/TNXG](https://github.com/TNXG)
