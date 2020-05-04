import Foundation

// TODO: handle window names that contain quotes
// TODO: error handling
func switchWindow (window: WindowInfoDict) {
    let windowOwner = window.appName
    let windowName = window.windowTitle
    
    // Click Appbar -> Window -> WindowName
    let clickWindowName = """
    tell application "\(windowOwner)"
        tell application "System Events"
            tell process "\(windowOwner)"
                tell menu bar 1
                    if exists ((menu item 1 where its name contains "\(windowName)") of menu 1 of menu bar item -2) then
                        click (menu item 1 where its name contains "\(windowName)") of menu 1 of menu bar item -2
                    end if
                end tell
            end tell
        end tell
        activate
    end tell
    """
    
    // * Activating desktop first allows switching to a specific window of the app
    // * Clicking Window Name twice fixes the issue of sometimes switching to the app but not
    //   the specific window
    let appleScript = """
    tell application "Finder" to activate desktop
    delay 0.1
    \(clickWindowName)
    delay 0.1
    \(clickWindowName)
    """
    
    execAppleScript(appleScript: appleScript)
}


public func execAppleScript (appleScript: String) -> String? {
    var error: NSDictionary?
    if let scriptObject = NSAppleScript(source: appleScript) {
        if let output: NSAppleEventDescriptor = scriptObject.executeAndReturnError(
            &error) {
            return output.stringValue
        } else if (error != nil) {
            print("error: \(error)")
        }
    }
    return nil
}
