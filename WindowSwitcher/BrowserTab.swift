import Foundation

func getTabs () -> Array<String> {
    
    let appleScript = """
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
    """
    
    guard let retVal = execAppleScript(appleScript: appleScript) else {
        return []
    }

    return retVal.components(separatedBy: "\n")
}

class TabInfoDict: NSObject, SwitchableWindow {
    private let name : String;
    private let windowId: String;
    private let tabIdx: String;
    
    init(rawDict : String, windowId: String, tabIdx: String) {
        self.name = rawDict
        self.windowId = windowId
        self.tabIdx = tabIdx
        
        super.init()
    }
    
    @objc dynamic var appName : String {
        return "Google Chrome"
    }
    
    @objc dynamic var windowTitle : String {
        return self.name
    }
    
    func switchToMe() {
        let appleScript = """
        tell application "Google Chrome"
            set curr_window to first window whose id is "\(self.windowId)"
            set (active tab index of (curr_window)) to "\(self.tabIdx)"
        end tell
        """
        execAppleScript(appleScript: appleScript)
        switchWindow(windowOwner: "Google Chrome", windowName: self.name)
    }
    
}

struct Tabs {
    static var all : [TabInfoDict] {
        get {
            let tabsData = getTabs()
            var tabs: [TabInfoDict] = []
            
            for (index, element) in tabsData.enumerated() {
                if index % 2 == 1 {
                    let parts = element.components(separatedBy: "-")
                    let windowId = parts[0]
                    let tabIdx = parts[1]
                    let newTab: TabInfoDict = TabInfoDict(rawDict: tabsData[index - 1], windowId: windowId, tabIdx: tabIdx)
                    tabs.append(newTab)
                }
            }
            
            return tabs
        }
    }
}
