//
//  AppDelegate.swift
//  MacOS-Launcpad
//
//  Created by Алексей Химунин on 15.08.2025.
//

import Cocoa

@main
class AppDelegate: NSResponder, NSApplicationDelegate, NSWindowDelegate {

    @IBOutlet var window: KhWindow!
    //private var pageView: PageView!

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        self.window.makeFirstResponder(self)        
        
        ///Select type view
        let isTest: Bool = true //true //false
        ///
        if isTest == true {
            self.window.minSize = CGSize(width: 1000, height: 800)
            var frame = window.frame
            frame.size = NSSize(width: 1400, height: 1000) // Set desired width and height
            window.setFrame(frame, display: true, animate: true)
        }else {
            makeWindows()
        }
        
        window.isOpaque = false
        window.backgroundColor = .clear
        
        if let pageView = self.window.contentView as? PageView {
            pageView.reloadApps()
            let urls = pageView.getAllDBUrls()
            upfateAppsPath(urls: urls)
        }
    }
    
    override var acceptsFirstResponder: Bool {
        get {
            return true
        }
    }
    
    override func keyDown(with event: NSEvent) {
        super.keyDown(with: event)
        if event.keyCode == 53 {
            NSApp.terminate(nil)
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }

    func makeWindows() {
        window.titleVisibility = .hidden
        window.titlebarAppearsTransparent = true
        window.standardWindowButton(.zoomButton)?.isHidden = true
        window.standardWindowButton(.miniaturizeButton)?.isHidden = true
        window.standardWindowButton(.closeButton)?.isHidden = true
        window.styleMask.remove(.resizable)
        window.styleMask.remove(.titled)
        window.styleMask.insert(.fullSizeContentView)
        window.collectionBehavior.insert(.fullScreenPrimary)
        window.level = .floating
        window.setFrame(NSScreen.main?.frame ?? .zero, display: true)
    }
    
    func upfateAppsPath(urls: [DBAppUrl]) {
        if let menuItem = getMenuItem(from: window.menu, name: "Add") {
            for dbUrl in urls {
                let mItem = NSMenuItem(title: dbUrl.url()?.path() ?? "", action: nil, keyEquivalent: "")
                menuItem.submenu?.addItem(mItem)
            }
        }
    }
    
    @IBAction func addAppPath(_ sender: Any) {
        if let pageView = self.window.contentView as? PageView {
            pageView.addNewAppsFolder()
        }
    }
}

extension AppDelegate {
    func getMenuItem(from menu: NSMenu?, name: String) -> NSMenuItem? {
        if let menu = menu {
            for item in menu.items {
                if let identifier = item.identifier?.rawValue as? String, identifier == name {
                    return item
                }
                if let subMenu = item.submenu {
                    if let subItem = getMenuItem(from: subMenu, name: name) {
                        return subItem
                    }
                }
            }
        }
        return nil
    }
}
