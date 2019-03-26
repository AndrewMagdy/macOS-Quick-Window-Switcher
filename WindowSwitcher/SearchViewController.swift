//
//  SearchViewController.swift
//  WindowSwitcher
//
//  Created by Andrew Magdy on 3/26/19.
//  Copyright © 2019 Andrew Magdy. All rights reserved.
//

import Cocoa

class SearchViewController: NSViewController {
    
    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet var searchField: NSView!

    
    var windows:[WindowInfoDict] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        self.windows = Windows.all
        tableView.reloadData()
    }
    
    func dataArray () -> NSMutableArray{
        return windows as! NSMutableArray
    }
    
    func switchToWindow(idx: Int) {
        if (idx < 0){
            return
        }
        
        let windowOwner = windows[idx].appName
        let windowName = windows[idx].windowTitle
        var error: NSDictionary?
        let myAppleScript = """
        try
            tell application "System Events"
                with timeout of 0.1 seconds
                    tell process "\(windowOwner)" to perform action "AXRaise" of window "\(windowName)"
                end timeout
            end tell
        end try
        
        tell application "\(windowOwner)"
            activate
        end tell
        """
        
        if let scriptObject = NSAppleScript(source: myAppleScript) {
            if let output: NSAppleEventDescriptor = scriptObject.executeAndReturnError(
                &error) {
                //print(output.stringValue)
            } else if (error != nil) {
                print("error: \(error)")
            }
        }
    }
    
}

extension SearchViewController : NSTableViewDelegate, NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return self.windows.count
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        self.switchToWindow(idx: tableView.selectedRow)
        let appDelegate = NSApplication.shared.delegate as! AppDelegate
        appDelegate.closePopover(sender: nil)
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard let vw = tableView.makeView(withIdentifier: tableColumn!.identifier, owner: self) as? NSTableCellView else { return nil }
        
        if tableColumn?.title == "App Name" {
            vw.textField?.stringValue = windows[row].appName
        } else {
            vw.textField?.stringValue = windows[row].windowTitle
        }
        
        return vw
    }
}

extension SearchViewController: NSSearchFieldDelegate {
    func searchFieldDidStartSearching(_ sender: NSSearchField) {
        print("didStart")
    }
    
    func searchFieldDidEndSearching(_ sender: NSSearchField) {
        print("didEnd")
    }
}

extension SearchViewController {
    // MARK: Storyboard instantiation
    static func freshController() -> SearchViewController {
        //1.
        let storyboard = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil)
        //2.
        let identifier = NSStoryboard.SceneIdentifier("SearchViewController")
        //3.
        guard let viewcontroller = storyboard.instantiateController(withIdentifier: identifier) as? SearchViewController else {
            fatalError("Why cant i find SearchViewController? - Check Main.storyboard")
        }
        return viewcontroller
    }
}
