import Foundation

func getTabs () -> [String: [String]]{
    let browserScriptDict: [String: String] = [ "Safari": """
                                                    set titleString to ""
                                                    tell application "Safari"
                                                        set window_list to every window # get the windows
                                                        repeat with the_window in window_list # for every window
                                                            set tab_list to every tab in the_window # get the tabs
                                                            set the_window_id to id of the_window
                                                            set tab_idx to 1
                                                            repeat with the_tab in tab_list # for every tab
                                                                set the_url to the URL of the_tab # grab the URL
                                                                set the_title to the name of the_tab # grab the title
                                                                set titleString to titleString & the_title & "\n"
                                                                set titleString to titleString & the_window_id & "-" & tab_idx & "\n"
                                                                set tab_idx to tab_idx + 1
                                                            end repeat
                                                        end repeat
                                                        return titleString
                                                    end tell
                                                """,
                                "Google Chrome": """
                                    set titleString to ""
                                    tell application "Google Chrome"
                                        set window_list to every window # get the windows
                                        repeat with the_window in window_list # for every window
                                        set tab_list to every tab in the_window # get the tabs
                                            set the_window_id to id of the_window
                                            set tab_idx to 1
                                            repeat with the_tab in tab_list # for every tab
                                                set the_url to the URL of the_tab # grab the URL
                                                set the_title to the title of the_tab # grab the title
                                                set titleString to titleString & the_title & "\n"
                                                set titleString to titleString & the_window_id & "-" & tab_idx & "\n"
                                                set tab_idx to tab_idx + 1
                                            end repeat
                                        end repeat
                                        return titleString
                                    end tell
                                """]
    
    var retVal = [String: [String]]()
    for (browser, appleScript) in browserScriptDict {
        
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
        let browserScriptDict: [String: String] = [ "Safari": """
                                                                tell application "Safari"
                                                                    set curr_window to first window whose id is "\(self.windowId)"
                                                                    tell curr_window
                                                                        set current tab to tab \(self.tabIdx)
                                                                    end tell
                                                                end tell
                                                                """,
                                                    "Google Chrome": """
                                                        tell application "Google Chrome"
                                                            set curr_window to first window whose id is "\(self.windowId)"
                                                            set (active tab index of (curr_window)) to "\(self.tabIdx)"
                                                        end tell
                                                    """]
        
        execAppleScript(appleScript: browserScriptDict[self.browserName]!)
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
