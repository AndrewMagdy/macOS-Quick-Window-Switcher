import Foundation

// TODO: handle window names that contain quotes
// TODO: error handling
func switchWindow (windowOwner: String, windowName: String) {
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
    
    // Switching to the window depends on the responsivness of the system,
    // Need to wait for app to activate before switching windows
    let appleScript = """
    tell application "\(windowOwner)"
        activate
    end tell
    delay 0.5
    \(clickWindowName)
    """
    
    execAppleScript(appleScript: appleScript)
}

func switchWindow (window: WindowInfoDict) {
    let windowOwner = window.appName
    let windowName = window.windowTitle
    
    switchWindow(windowOwner: windowOwner, windowName: windowName)
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
