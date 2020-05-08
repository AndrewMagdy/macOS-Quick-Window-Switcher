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
        self.searchResultsController.content = Windows.all as [SwitchableWindow] + BrowserTabs.all as [SwitchableWindow]
        tableView.reloadData()
        super.viewWillAppear()
    }
    
    func switchToSelectedWindow() {
        let window = self.searchResultsController.selectedObjects.first as! SwitchableWindow
        
        window.switchToMe()
        self.closePopOver()
    }
    
    func closePopOver() {
        let appDelegate = NSApplication.shared.delegate as! AppDelegate
        appDelegate.closePopover(sender: nil)
    }
}

// TODO: Reset after reaching top / bottom
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
    static func freshController() -> SearchViewController {
        let storyboard = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil)
        let identifier = NSStoryboard.SceneIdentifier("SearchViewController")
    
        guard let viewcontroller = storyboard.instantiateController(withIdentifier: identifier) as? SearchViewController else {
            fatalError("SearchViewController Not Found - Check Main.storyboard")
        }
        return viewcontroller
    }
}
