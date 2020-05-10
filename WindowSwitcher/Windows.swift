
// Source : https://github.com/mandrigin/AlfredSwitchWindows/blob/master/EnumWindows/Windows.swift

import Foundation

class WindowInfoDict: NSObject, SwitchableWindow {
    private let windowInfoDict : Dictionary<NSObject, AnyObject>;
    
    init(rawDict : UnsafeRawPointer) {
        self.windowInfoDict = unsafeBitCast(rawDict, to: CFDictionary.self) as Dictionary
        super.init()
    }
    
    @objc dynamic var name : String {
        return self.dictItem(key: "kCGWindowName", defaultValue: "")
    }
    
    @objc dynamic var windowTitle: String {
        return self.name
    }
    
    var hasName : Bool {
        return self.windowInfoDict["kCGWindowName" as NSObject] != nil
    }
    
    var processName : String {
        return self.dictItem(key: "kCGWindowOwnerName", defaultValue: "")
    }
    
    @objc dynamic var appName : String {
        return self.dictItem(key: "kCGWindowOwnerName", defaultValue: "")
    }
    
    var pid : Int {
        return self.dictItem(key: "kCGWindowOwnerPID", defaultValue: -1)
    }
    
    var bounds : CGRect {
        let dict = self.dictItem(key: "kCGWindowBounds", defaultValue: NSDictionary())
        guard let bounds = CGRect.init(dictionaryRepresentation: dict) else {
            return CGRect.zero
        }
        return bounds
    }
    
    var alpha : Float {
        return self.dictItem(key: "kCGWindowAlpha", defaultValue: 0.0)
    }
    
    var number: UInt32 {
        return self.dictItem(key: "kCGWindowNumber", defaultValue: 0)
    }
    
    var tabIndex: Int {
        return 0
    }
    
    func switchToMe () {
        switchWindow(window: self)
    }
    
    func dictItem<T>(key : String, defaultValue : T) -> T {
        guard let value = windowInfoDict[key as NSObject] as? T else {
            return defaultValue
        }
        return value
    }
    
    static func == (lhs: WindowInfoDict, rhs: WindowInfoDict) -> Bool {
        return lhs.processName == rhs.processName && lhs.name == rhs.name
    }
    
    var searchStrings: [String] {
        return [self.processName, self.name]
    }
    
    var isProbablyMenubarItem : Bool {
        return self.bounds.height < 30
    }
    
    var isBrowserWindow : Bool {
        return Constants.supportedBrowsers.contains(self.processName)
    }
    
    var isVisible : Bool {
        return self.alpha > 0
    }
}

struct Windows {
    static var any : WindowInfoDict? {
        get {
            guard let wl = CGWindowListCopyWindowInfo([.optionOnScreenOnly, .excludeDesktopElements], kCGNullWindowID) else {
                return nil
            }
            
            return (0..<CFArrayGetCount(wl)).flatMap { (i : Int) -> [WindowInfoDict] in
                guard let windowInfoRef = CFArrayGetValueAtIndex(wl, i) else {
                    return []
                }
                
                let wi = WindowInfoDict(rawDict: windowInfoRef)
                return [wi]
                }.first
        }
    }
    
    static var allBrowsers: [WindowInfoDict] {
        get {
            return Windows.all.filter {$0.isBrowserWindow}
        }
    }
    
    static var allNonBrowser: [WindowInfoDict] {
        get {
            return Windows.all.filter {!$0.isBrowserWindow}
        }
    }
    
    static var all : [WindowInfoDict] {
        get {
            guard let wl = CGWindowListCopyWindowInfo([.excludeDesktopElements], kCGNullWindowID) else {
                return []
            }
            
            return (0..<CFArrayGetCount(wl)).flatMap { (i : Int) -> [WindowInfoDict] in
                guard let windowInfoRef = CFArrayGetValueAtIndex(wl, i) else {
                    return []
                }
                
                let wi = WindowInfoDict(rawDict: windowInfoRef)
                // We don't want to clutter our output with unnecessary windows that we can't switch to anyway.
                guard wi.name.characters.count > 0 && !wi.isProbablyMenubarItem && wi.isVisible else {
                    return []
                }
                
                return [wi]
            }
        }
    }
}
