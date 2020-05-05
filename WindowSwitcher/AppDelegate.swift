import Cocoa
import AppKit
import HotKey

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    let statusItem = NSStatusBar.system.statusItem(withLength:NSStatusItem.squareLength)
    let popover = NSPopover()
    let hotKey = HotKey(key: .p, modifiers: [.command, .option])
    
    // Source: https://github.com/mandrigin/AlfredSwitchWindows/blob/master/EnumWindows/main.swift#L45
    // Screen Recording permission is needed in Catalina to get window name
    func handleCatalinaScreenRecordingPermission() {
        guard let firstWindow = Windows.any else {
            return
        }
        
        guard !firstWindow.hasName else {
            return
        }
        
        let windowImage = CGWindowListCreateImage(.null, .optionIncludingWindow,
                                                  firstWindow.number,
                                                  [.boundsIgnoreFraming, .bestResolution])
        if windowImage == nil {
            debugPrint("Before using this app, you need to give permission in System Preferences > Security & Privacy > Privacy > Screen Recording.\nPlease authorize and re-launch.")
            exit(1)
        }
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        if let button = statusItem.button {
            button.image = NSImage(named:NSImage.Name("StatusBarButtonImage"))
            button.action = #selector(togglePopover(_:))
        }
        
        hotKey.keyDownHandler = {
            self.togglePopover(nil)
        }
        
        popover.behavior = NSPopover.Behavior.transient
        popover.contentViewController = SearchViewController.freshController()
        
        handleCatalinaScreenRecordingPermission()
    }
    
    @objc func togglePopover(_ sender: Any?) {
        if popover.isShown {
            closePopover(sender: sender)
        } else {
            showPopover(sender: sender)
        }
    }
    
    func showPopover(sender: Any?) {
        if let button = statusItem.button {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
        }
    }
    
    func closePopover(sender: Any?) {
        popover.performClose(sender);
    }
}






