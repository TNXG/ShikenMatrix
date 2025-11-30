# ShikenMatrix

<div align="center">

![License](https://img.shields.io/badge/license-AGPL%20v3.0-blue.svg)
![Tauri](https://img.shields.io/badge/Tauri-2.0-orange.svg)
![Vue](https://img.shields.io/badge/Vue-3.0-green.svg)

**A Modern Cross-Platform Desktop Window and Media Information Display Tool**

[English](./README_EN.md) | [简体中文](./README.md)

</div>

## 📖 Introduction

ShikenMatrix is a desktop application built on Tauri, designed to provide an elegant window management and media information display experience. Adopting a modern **Glassmorphism** design, it displays detailed information about the current foreground window and playing media content in real-time.

This project is the successor to the [**Kizuna**](https://github.com/AlienFamilyHub/Kizuna) project. It has undergone comprehensive refactoring and feature enhancements based on the original functionality to provide a more modern and cross-platform user experience.

This project is licensed under the **GNU Affero General Public License v3.0**.

## ✨ Features

### 🖥️ Intelligent Window Information Display

- **Real-time Monitoring**: Automatically retrieves and displays the title, icon, and process information of the current active window.
- **Application Icon Display**: Dynamically loads and displays the icon of the foreground application.
- **Window Title Tracking**: Updates window title changes in real-time.

### 🎵 Media Playback Integration

- **Media Metadata**: Supports displaying the title, artist, and album information of currently playing music/video.
- **Album Art Display**: Automatically retrieves and displays high-quality album artwork.
- **Playback Status Synchronization**: Real-time synchronization of play/pause states; media information is shown only during playback.
- **Cross-Application Support**: Supports system-level media controls (uses **MediaRemote** on macOS and **SMTC** on Windows).

### 🎨 Modern UI Design

- **Glassmorphism Style**: Features exquisite Acrylic/Glassmorphism visual effects that blend perfectly with the system environment.
- **Adaptive Theme**: Automatically adapts to system Light/Dark modes for a consistent visual experience.
- **Adaptive Window**: Window size adjusts automatically based on content to ensure optimal display.
- **Fluid Animations**: All interactions are equipped with carefully designed transition animations.

### 🎮 Interactive Window Control

- **Drag to Move**: Hold the top drag area to move the window.
- **Capsule Menu**: Double-click or long-press the top area to open the interactive capsule menu.
- **Window Operations**: Supports common operations such as Close, Minimize, and Pin to Top.
- **Visual Feedback**: All interactions provide clear visual and animated feedback.

### 🌐 Cross-Platform Support

- **macOS**: Deeply optimized with full support for all features.
- **Windows**: Adapted, supports window information and media control.
- **Architecture Design**: Adopts a platform abstraction layer (`platform` module) to facilitate extension to other operating systems.

## 🚀 Quick Start

### Prerequisites

- **Node.js**: 18.x or higher
- **pnpm**: 8.x or higher
- **Rust**: 1.70 or higher (install via [rustup](https://rustup.rs/))

### Installation and Running

```bash
# Clone the repository
git clone https://github.com/TNXG/ShikenMatrix.git
cd ShikenMatrix

# Install dependencies
pnpm install

# Run in development mode
pnpm tauri dev

# Build for production
pnpm tauri build
```

### Permissions Configuration

#### macOS

Upon the first run, the application will request **Accessibility Permissions**. This is required to fetch foreground window information:

1.  Open **System Settings** > **Privacy & Security** > **Accessibility**.
2.  Find `shikenmatrix` and enable the toggle.
3.  Restart the application.

> If you encounter "Cannot be opened because it is from an unidentified developer", allow the program to run in "System Settings → Privacy & Security", or execute the following in the terminal:

```bash
xattr -d com.apple.quarantine /Applications/shikenmatrix.app
```

#### Windows

Windows has relatively looser permission management regarding window information access, so it generally works without additional configuration.

## 💡 Usage

### Basic Operations

- **Move Window**: Click and hold the top drag area (indicated by a three-dot line) and drag.
- **Open Menu**: Double-click or long-press the top drag area to pop up the capsule menu.
- **Close Window**: Click the red close button in the capsule menu.
- **Minimize**: Click the yellow minimize button in the capsule menu.
- **Pin to Top**: Click the blue pin button in the capsule menu (click again to unpin).

### Interface Overview

The interface is divided into two main sections:

1.  **Foreground Window Information Card** (Always visible)
    - Displays the application icon of the current active window.
    - Displays the application name and window title.

2.  **Media Playback Information Card** (Visible only during playback)
    - Displays album artwork.
    - Displays song title, artist, and album information.
    - Auto-hides when media pauses or there is no content playing.

## 🏗️ Project Structure

```
ShikenMatrix/
├── src/                      # Vue Frontend Code
│   ├── app.vue               # Main App Component (Window control, Dragging)
│   ├── pages/                # Page Components
│   │   └── index.vue         # Main Page (Data fetching, Window resizing)
│   ├── components/           # UI Components
│   │   ├── ForegroundWidget.vue  # Foreground Window Info Component
│   │   └── MediaWidget.vue       # Media Playback Info Component
│   └── assets/               # Styles and Assets
│       └── main.css          # Global Styles and CSS Variables
├── src-tauri/                # Rust Backend Code
│   ├── src/
│   │   ├── lib.rs            # Tauri Command Definitions
│   │   ├── main.rs           # App Entry Point
│   │   └── platform/         # Platform Abstraction Layer
│   │       ├── mod.rs        # Platform Interface Definitions
│   │       ├── macos/        # macOS Implementation
│   │       └── windows/      # Windows Implementation
│   └── Cargo.toml            # Rust Dependency Config
├── AGENTS.md                 # Design Guidelines
└── README.md                 # Project Documentation
```

## 🔧 Development Guide

### Technical Architecture Overview

**Frontend (Vue 3 + TypeScript)**

- Uses Composition API and `<script setup>` syntax.
- Modular styling system based on SCSS.
- Theme switching implemented via CSS variables.
- Fluid animation system driven by GSAP.

**Backend (Rust + Tauri)**

- Platform abstraction layer design with unified interface definitions.
- Exposes system-level functionality using `#[tauri::command]`.
- Asynchronous task processing (based on tokio).
- Platform-specific implementations (Objective-C bindings for macOS, WinAPI for Windows).

### Adding New Features

1.  **Backend Features**: Add platform interfaces and implementations in `src-tauri/src/platform/`.
2.  **Frontend Components**: Create new Vue components in `src/components/`.
3.  **Design Guidelines**: Refer to `AGENTS.md` to ensure compliance with the design language.

### Design Guidelines

For detailed design specifications, please refer to [`AGENTS.md`](./AGENTS.md), including:

- UI layout and responsiveness strategies.
- Color system and theme adaptation.
- Animation design principles.
- Component development standards.

## 🛠️ Tech Stack

**Frontend**

- Vue 3 - Progressive JavaScript Framework
- TypeScript - Type-safe JavaScript Superset
- Nuxt 3 - The Vue.js Framework
- GSAP - Professional Grade Animation Library
- SCSS - CSS Preprocessor

**Backend**

- Rust - Systems Programming Language
- Tauri 2.0 - Lightweight Desktop Application Framework
- tokio - Asynchronous Runtime

**Platform Integration**

- macOS: Core Foundation, AppKit, MediaRemote
- Windows: WinAPI, Windows Media Control

## ❓ FAQ

### 💻 macOS Related

### Q: Why can't I get window information on macOS?

A: Please ensure you have granted Accessibility permissions to the app. Go to **System Settings** > **Privacy & Security** > **Accessibility**, and check `shikenmatrix`.

### 💻 Windows Related

A: Netease Cloud Music (and some other domestic Chinese music players) do not report media information via Microsoft's official media channels (i.e., Windows System Media Transport Controls Integration). Since Windows 10 version 1607, UWP apps that use the `MediaPlayer` class or `AudioGraph` class to play media are automatically integrated with SMTC by default. Developers simply need to instantiate a new `MediaPlayer` and assign a `MediaSource`, `MediaPlaybackItem`, or `MediaPlaybackList` to the player's `Source` property. Users will then see the app name in SMTC and can use SMTC controls to play, pause, and navigate playlists. -- Windows Documentation

Therefore, other methods are needed to make this program's media reporting structure effective. You can use plugins to force reporting via SMTC.
For Netease Cloud Music, try using `MicroCBer/BetterNCM` combined with `BetterNCM/InfinityLink`.

> **TL;DR:**
>
> Domestic music players (like Netease Cloud Music) do not use the standard Windows Media Control Interface (SMTC), resulting in the inability to display media info. This can be resolved by installing specific plugins (e.g., `BetterNCM` + `InfinityLink` for Netease Cloud Music).

### ❓ General Questions

### Q: What if media information is not showing?

A: Media information is only displayed when music/video is currently playing. Please ensure:

- Media is playing on the system.
- The player supports system-level media controls (e.g., Apple Music, Spotify, Chrome, etc.).

### Q: Can I resize the window?

A: The window size automatically adjusts based on content to ensure the best display effect. Manual resizing is not supported in the current version.

### Q: Which operating systems are supported?

A: Currently, macOS and Windows are fully supported. Linux support is under development.

### Q: How can I contribute code?

A: Pull Requests are welcome! Please ensure:

- Follow the project's code style and design guidelines (refer to `AGENTS.md`).
- Add appropriate comments for new features.
- Test compatibility on different platforms.

## 📄 License

This project is licensed under the [GNU Affero General Public License v3.0](LICENSE.md).

## 👨‍💻 Developer

Developed by **TNXG**
GitHub: [https://github.com/TNXG](https://github.com/TNXG)

## 🙏 Acknowledgments

- [Tauri](https://tauri.app/) - Powerful framework for building desktop apps
- [Vue.js](https://vuejs.org/) - Progressive JavaScript Framework
- [GSAP](https://greensock.com/gsap/) - Professional Animation Library
- [mediaremote-rs](https://crates.io/crates/mediaremote-rs) - macOS Media Control Library (also developed by me)