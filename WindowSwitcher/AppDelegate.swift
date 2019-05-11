//
//  AppDelegate.swift
//  WindowSwitcher
//
//  Created by Andrew Magdy on 3/23/19.
//  Copyright © 2019 Andrew Magdy. All rights reserved.
//

import Cocoa
import AppKit
import HotKey


@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    let statusItem = NSStatusBar.system.statusItem(withLength:NSStatusItem.squareLength)
    let popover = NSPopover()
    
    let hotKey = HotKey(key: .p, modifiers: [.command, .option])
    
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        if let button = statusItem.button {
            button.image = NSImage(named:NSImage.Name("StatusBarButtonImage"))
            button.action = #selector(togglePopover(_:))
        }
        popover.behavior = NSPopover.Behavior.transient
        hotKey.keyDownHandler = {
            self.togglePopover(nil)
        }
        popover.contentViewController = SearchViewController.freshController()
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    @objc func togglePopover(_ sender: Any?) {
        if popover.isShown {
            closePopover(sender: sender)
        } else {
            showPopover(sender: sender)
        }
    }
    
    func showPopover(sender: Any?) {
        let newWindow = NSWindow(contentRect: NSMakeRect(NSScreen.main!.frame.midX, NSScreen.main!.frame.midY, 1, 1), styleMask: [.closable], backing: .buffered, defer: false)
        newWindow.title = "New Window"
        newWindow.isOpaque = false
        newWindow.center()
        newWindow.isMovableByWindowBackground = true
        newWindow.makeKeyAndOrderFront(nil)
        newWindow.backgroundColor = .clear
        
        let asd = NSMakeRect(-10, 0, 0, 0 )
        NSRunningApplication.current.activate(options: NSApplication.ActivationOptions.activateIgnoringOtherApps)
        
        popover.show(relativeTo: asd, of: newWindow.contentView as! NSView, preferredEdge: NSRectEdge.minY)
    }
    
    func closePopover(sender: Any?) {
        popover.performClose(sender)
    }
}






