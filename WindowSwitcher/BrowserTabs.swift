import Foundation

func getTabs () -> [String: [String]]{
    var retVal = [String: [String]]()
    let browserWindows: Set<String> = Set(Windows.allBrowsers.map{ $0.processName })
    
    for browser in browserWindows {
        guard let appleScript = Constants.browserScriptDict[browser] else {
            continue
        }
        retVal[browser] = execAppleScript(appleScript: appleScript)?.components(separatedBy: "\n")
    }
    
    return retVal
}

class TabInfoDict: NSObject, SwitchableWindow {
    private let browserName : String;
    private let tabName : String;
    private let windowId: String;
    private let tabIdx: String;
    
    init(browserName: String, tabName : String, windowId: String, tabIdx: String) {
        self.browserName = browserName
        self.tabName = tabName
        self.windowId = windowId
        self.tabIdx = tabIdx
        
        super.init()
    }
    
    @objc dynamic var appName : String {
        return self.browserName
    }
    
    @objc dynamic var windowTitle : String {
        return self.tabName
    }
    
    func switchToMe() {
        let appleScript = String(format: Constants.browserSwitchScripts[self.browserName]!, self.windowId, self.tabIdx)
        execAppleScript(appleScript: appleScript)
        switchWindow(windowOwner: self.browserName, windowName: self.tabName)
    }
    
}


struct BrowserTabs {
    static var all : [TabInfoDict] {
        get {
            let tabsData = getTabs()
            var retVal: [TabInfoDict] = []
            
            for (browserName, tabs) in tabsData {
                for (index, value) in tabs.enumerated() {
                    if index % 2 == 1 {
                        let parts = value.components(separatedBy: "-")
                        let windowId = parts[0]
                        let tabIdx = parts[1]
                        let newTab: TabInfoDict = TabInfoDict(browserName: browserName, tabName: tabs[index - 1], windowId: windowId, tabIdx: tabIdx)
                        retVal.append(newTab)
                    }
                }

            }
            return retVal
        }
    }
}
