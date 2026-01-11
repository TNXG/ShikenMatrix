//
//  ShikenMatrixApp.swift
//  ShikenMatrix
//
//  Created by tianxiang on 2026/1/11.
//

import SwiftUI
import AppKit

@main
struct ShikenMatrixApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        // 使用 Settings 场景，避免多窗口问题
        Settings {
            EmptyView()
        }
    }
}

/// Application delegate to manage startup and status bar
class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate {
    var statusBarManager: StatusBarManager?
    var window: NSWindow?

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Set activation policy to accessory to hide dock icon
        NSApp.setActivationPolicy(.accessory)
        
        // Create status bar manager first
        statusBarManager = StatusBarManager()
        
        // Create and configure the main window manually
        createMainWindow()
        
        // Show notification that app is running in tray
        showStartupNotification()
    }
    
    private func showStartupNotification() {
        let notification = NSUserNotification()
        notification.title = "时刻矩阵 ShikenMatrix"
        notification.informativeText = "应用已在系统托盘启动，点击托盘图标打开设置"
        notification.soundName = nil
        
        NSUserNotificationCenter.default.deliver(notification)
    }
    
    private func createMainWindow() {
        // Create window with ContentView
        let contentView = ContentView()
        let hostingController = NSHostingController(rootView: contentView)
        
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 500, height: 400),
            styleMask: [.titled, .closable, .miniaturizable, .resizable],
            backing: .buffered,
            defer: false
        )
        
        window.title = "时刻矩阵 ShikenMatrix"
        window.contentViewController = hostingController
        window.delegate = self
        window.center()
        
        // Configure window behavior
        window.level = .normal
        window.collectionBehavior = [.canJoinAllSpaces]
        
        // Hide window on startup - start in tray mode
        window.setIsVisible(false)
        
        self.window = window
        statusBarManager?.setWindow(window)
    }

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if !flag {
            showWindow()
        }
        return true
    }
    
    // Intercept window close to hide instead of quit
    func windowShouldClose(_ sender: NSWindow) -> Bool {
        hideWindow()
        return false  // Don't actually close the window
    }

    func showWindow() {
        window?.setIsVisible(true)
        window?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    func hideWindow() {
        window?.setIsVisible(false)
    }

    func updateStatusBarStatus(isRunning: Bool, isConnected: Bool) {
        statusBarManager?.updateStatus(isRunning: isRunning, isConnected: isConnected)
    }
}
