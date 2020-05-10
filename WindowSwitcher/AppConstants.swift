struct Constants {
    static let supportedBrowsers = ["Safari", "Google Chrome"]
    static let browserScriptDict: [String: String] = [ "Safari": """
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
    static let browserSwitchScripts: [String: String] = [ "Safari": """
                                                                tell application "Safari"
                                                                    set curr_window to first window whose id is %@
                                                                    tell curr_window
                                                                        set current tab to tab  %@
                                                                    end tell
                                                                end tell
                                                                """,
                                                    "Google Chrome": """
                                                        tell application "Google Chrome"
                                                            set curr_window to first window whose id is  %@
                                                            set (active tab index of (curr_window)) to  %@
                                                        end tell
                                                    """]
}
