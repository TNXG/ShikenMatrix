//
//  ContentView.swift
//  ShikenMatrix
//
//  Created by tianxiang on 2026/1/11.
//

import SwiftUI
import AppKit

struct ContentView: View {
    @State private var config = ReporterConfig(enabled: false, wsUrl: "", token: "")
    @State private var reporterHandle: UnsafeMutableRawPointer?
    @State private var isRunning = false
    @State private var isConnected = false
    @State private var statusMessage = "Stopped"
    @State private var lastError: String?
    @State private var showAlert = false
    @State private var alertMessage = ""

    // Log viewer state
    @State private var logs: [LogEntry] = []
    @State private var autoScroll = true

    // Timer for status updates
    @State private var statusTimer: Timer?

    // App delegate reference
    private let appDelegate = NSApp.delegate as? AppDelegate

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 16) {
                    connectionSection
                    statusSection
                    logViewerSection
                }
                .padding()
            }

            Divider()
            footerView
        }
        .frame(minWidth: 500, minHeight: 400)
        .onAppear {
            loadConfig()
            startStatusUpdates()
            addLog("应用已启动", level: .info)
        }
        .onDisappear {
            stopStatusUpdates()
        }
        .alert("错误", isPresented: $showAlert) {
            Button("确定", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
    }

    // MARK: - View Components

    private var connectionSection: some View {
        GroupBox(label: Text("连接配置").fontWeight(.semibold)) {
            VStack(alignment: .leading, spacing: 12) {
                Toggle("启用上报", isOn: $config.enabled)

                HStack {
                    Text("WebSocket 地址:")
                    TextField("ws://", text: $config.wsUrl)
                        .textFieldStyle(.roundedBorder)
                        .disabled(isRunning)
                }

                HStack {
                    Text("令牌:")
                    SecureField("输入令牌", text: $config.token)
                        .textFieldStyle(.roundedBorder)
                        .disabled(isRunning)
                }
                
                HStack {
                    Spacer()
                    Button("保存配置") {
                        if saveConfig() {
                            // Success feedback already shown in saveConfig
                        }
                    }
                    .buttonStyle(.bordered)
                    .disabled(isRunning)
                }
            }
            .padding(8)
        }
    }

    private var statusSection: some View {
        GroupBox(label: Text("运行状态").fontWeight(.semibold)) {
            VStack(alignment: .leading, spacing: 12) {
                statusControlRow

                if isRunning {
                    Divider()
                    connectionDetailsView
                }
            }
            .padding(8)
        }
    }

    private var statusControlRow: some View {
        HStack {
            Circle()
                .fill(statusIndicatorColor)
                .frame(width: 12, height: 12)

            Text(statusMessage)
                .foregroundColor(.secondary)

            Spacer()

            Button(action: toggleReporter) {
                Text(isRunning ? "停止" : "启动")
                    .frame(minWidth: 80)
            }
            .buttonStyle(.borderedProminent)
            .disabled(config.wsUrl.isEmpty || config.token.isEmpty)
        }
    }

    private var connectionDetailsView: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "network")
                    .foregroundColor(.secondary)
                Text("服务器:")
                Text(config.wsUrl)
                    .foregroundColor(.secondary)
            }
            .font(.caption)

            if let error = lastError {
                HStack {
                    Image(systemName: "exclamationmark.triangle")
                        .foregroundColor(.orange)
                    Text(error)
                        .foregroundColor(.orange)
                }
                .font(.caption)
            }
        }
    }

    private var logViewerSection: some View {
        GroupBox(label: HStack {
            Text("运行日志").fontWeight(.semibold)
            Spacer()
            Toggle("自动滚动", isOn: $autoScroll)
                .toggleStyle(.switch)
                .controlSize(.small)
        }) {
            VStack(alignment: .leading, spacing: 0) {
                logScrollView
                clearLogsButton
            }
            .padding(8)
        }
    }

    private var logScrollView: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 4) {
                    ForEach(logs) { log in
                        logEntryRow(log)
                    }
                }
                .padding(.vertical, 8)
            }
            .frame(height: 200)
            .onChange(of: logs) { _, newLogs in
                if autoScroll, let lastLog = newLogs.last {
                    withAnimation {
                        proxy.scrollTo(lastLog.id, anchor: .bottom)
                    }
                }
            }
        }
    }

    private func logEntryRow(_ log: LogEntry) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Text(log.timestamp, style: .time)
                .font(.system(.caption, design: .monospaced))
                .foregroundColor(.secondary)
                .frame(width: 60, alignment: .leading)

            Image(systemName: log.icon)
                .foregroundColor(log.level.color)
                .frame(width: 16)

            Text(log.message)
                .font(.system(.caption, design: .monospaced))
                .textSelection(.enabled)

            Spacer()
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 2)
        .id(log.id)
    }

    private var clearLogsButton: some View {
        HStack {
            Spacer()
            Button("清空日志") {
                logs.removeAll()
            }
            .buttonStyle(.borderless)
            .controlSize(.small)
        }
    }

    private var footerView: some View {
        VStack(spacing: 4) {
            HStack {
                Text("关闭窗口将隐藏到托盘 • 点击托盘图标重新显示")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
            }
            
            HStack {
                Link("ShikenMatrix", destination: URL(string: "https://github.com/TNXG/ShikenMatrix")!)
                    .font(.caption2)
                    .foregroundColor(.blue)
                Spacer()
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color(nsColor: .controlBackgroundColor))
    }

    private var statusIndicatorColor: Color {
        if isRunning {
            return isConnected ? .green : .orange
        }
        return .red
    }

    // MARK: - Configuration

    private func loadConfig() {
        if let cfg = RustBridge.loadConfig() {
            config = cfg
            statusMessage = "配置已加载"
            addLog("配置已加载", level: .info)
        } else {
            statusMessage = "未找到配置"
            addLog("未找到现有配置", level: .warning)
        }
    }

    private func saveConfig() -> Bool {
        if RustBridge.saveConfig(config) {
            statusMessage = "配置已保存"
            addLog("配置已保存", level: .info)
            return true
        } else {
            alertMessage = "保存配置失败"
            showAlert = true
            addLog("保存配置失败", level: .error)
            return false
        }
    }

    // MARK: - Reporter Control

    private func toggleReporter() {
        if isRunning {
            stopReporter()
        } else {
            startReporter()
        }
    }

    private func startReporter() {
        guard saveConfig() else { return }

        guard let handle = RustBridge.startReporter(config: config) else {
            alertMessage = "启动上报失败，请检查配置。"
            showAlert = true
            addLog("启动上报失败", level: .error)
            return
        }

        reporterHandle = handle
        isRunning = true
        statusMessage = "启动中..."
        addLog("上报已启动", level: .info)

        // Update status bar
        updateStatusBar()
    }

    private func stopReporter() {
        if let handle = reporterHandle {
            _ = RustBridge.stopReporter(handle)
            reporterHandle = nil
        }
        isRunning = false
        isConnected = false
        statusMessage = "已停止"
        lastError = nil
        addLog("上报已停止", level: .info)

        // Update status bar
        updateStatusBar()
    }

    // MARK: - Status Updates

    private func startStatusUpdates() {
        statusTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            updateStatus()
        }
    }

    private func stopStatusUpdates() {
        statusTimer?.invalidate()
        statusTimer = nil
    }

    private func updateStatus() {
        guard isRunning, let handle = reporterHandle else { return }

        let status = RustBridge.getStatus(handle)
        let wasConnected = isConnected
        isConnected = status.isConnected

        // Update message
        if status.isConnected {
            statusMessage = "已连接"
        } else {
            statusMessage = "连接中..."
        }

        // Handle errors
        if let error = status.lastError, error != lastError {
            lastError = error
            addLog("错误: \(error)", level: .error)
        }

        // Log connection state changes
        if status.isConnected != wasConnected {
            addLog(status.isConnected ? "已连接到服务器" : "与服务器断开连接", level: .info)
        }

        // Update status bar
        updateStatusBar()
    }

    private func updateStatusBar() {
        appDelegate?.updateStatusBarStatus(isRunning: isRunning, isConnected: isConnected)
    }

    // MARK: - Logging

    private func addLog(_ message: String, level: LogLevel) {
        let log = LogEntry(
            id: UUID(),
            timestamp: Date(),
            message: message,
            level: level
        )
        logs.append(log)

        // Keep only last 500 logs
        if logs.count > 500 {
            logs.removeFirst(logs.count - 500)
        }
    }
}

// MARK: - Log Models

struct LogEntry: Identifiable, Equatable {
    let id: UUID
    let timestamp: Date
    let message: String
    let level: LogLevel

    var icon: String {
        switch level {
        case .info: return "info.circle"
        case .warning: return "exclamationmark.triangle"
        case .error: return "xmark.circle"
        }
    }
}

enum LogLevel: Equatable {
    case info
    case warning
    case error

    var color: Color {
        switch self {
        case .info: return .blue
        case .warning: return .orange
        case .error: return .red
        }
    }
}

#Preview {
    ContentView()
        .frame(width: 500, height: 400)
}
