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
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func searchDidEndSearching(_ sender: Any) {
        self.searchResultsController.setSelectionIndex(0)
    }
    
    @IBAction func tableViewDoubleClick(_ sender: Any) {
        self.switchToSelectedWindow()
    }
    
    
    override func viewWillAppear() {
        self.searchResultsController.content = Windows.all
        tableView.reloadData()
        super.viewWillAppear()
    }
    
    
    
    func switchToSelectedWindow() {
        guard let window = self.searchResultsController.selectedObjects.first else {
            return
        }
        self.switchToWindow(window: window as! WindowInfoDict)
        let appDelegate = NSApplication.shared.delegate as! AppDelegate
        appDelegate.closePopover(sender: nil)
        
    }
    func switchToWindow(window: WindowInfoDict) {
        let windowOwner = window.appName
        let windowName = window.windowTitle
        
        print(windowOwner, windowName)
        var error: NSDictionary?
        let myAppleScript = """
        tell application "\(windowOwner)"
            tell application "System Events"
                tell process "\(windowOwner)"
                    tell menu bar 1
                        click menu item "\(windowName)" of menu 1 of menu bar item -2
                    end tell
                end tell
            end tell
            delay 3
            activate
        end tell
        """
        //print(myAppleScript)
        
        if let scriptObject = NSAppleScript(source: myAppleScript) {
            if let output: NSAppleEventDescriptor = scriptObject.executeAndReturnError(
                &error) {
                print(output.stringValue)
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
