import Foundation

func getTabs () -> Array<String> {
    
    let appleScript = """
        set titleString to ""
        tell application "Google Chrome"
         set window_list to every window # get the windows
         
         repeat with the_window in window_list # for every window
                 set tab_list to every tab in the_window # get the tabs
                 
                 repeat with the_tab in tab_list # for every tab
                         set the_url to the URL of the_tab # grab the URL
                         set the_title to the title of the_tab # grab the title
                         set titleString to titleString & the_title & "\n" # concatenate
                 end repeat
         end repeat

    end tell
    """
    
    guard let retVal = execAppleScript(appleScript: appleScript) else {
        return []
    }

    return retVal.components(separatedBy: "\n")
}

class TabInfoDict: NSObject {
    private let name : String;
    
    init(rawDict : String) {
        self.name = rawDict as String
        super.init()
    }
    
    @objc dynamic var appName : String {
        return "Google Chrome"
    }
    
    @objc dynamic var windowTitle : String {
        return self.name
    }
    
}

struct Tabs {
    static var all : [TabInfoDict] {
        get {
            let tabs = getTabs()
            return tabs.flatMap { (tab : String) -> [TabInfoDict] in
     
            
                let val = TabInfoDict(rawDict: tab)
            
                
                return [val]
            }
        }
    }
}
