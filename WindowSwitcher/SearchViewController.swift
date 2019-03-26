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
    @IBOutlet var searchResultsController: NSArrayController!
    

    var windows:[WindowInfoDict] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func searchDidEndSearching(_ sender: Any) {
        self.searchResultsController.setSelectionIndex(0)
    }
    
    @IBAction func tableViewDoubleClick(_ sender: Any) {
        print("Hi")
        self.switchToSelectedWindow()
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        self.windows = Windows.all
        self.searchResultsController.content = Windows.all
        tableView.reloadData()
    }
    
    func dataArray () -> NSMutableArray{
        return windows as! NSMutableArray
    }
    
    func switchToSelectedWindow() {
        guard let window = self.searchResultsController.selectedObjects.first else {
            return
        }
        self.switchToWindow(window: window as! WindowInfoDict)
        
    }
    func switchToWindow(window: WindowInfoDict) {
        let windowOwner = window.appName
        let windowName = window.windowTitle
        print(windowOwner, windowName)
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


extension SearchViewController: NSSearchFieldDelegate {
    func control(_ control: NSControl, textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
        if commandSelector == #selector(insertNewline(_:)) {
            switchToSelectedWindow()
        }
        else if commandSelector == #selector(moveUp(_:)) {
            searchResultsController.selectPrevious(nil)
        }
        else if commandSelector == #selector(moveDown(_:)) {
            searchResultsController.selectNext(nil)
        }
        return false
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
