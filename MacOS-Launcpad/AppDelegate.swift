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
    private var pageView: PageView!

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        self.window.makeFirstResponder(self)
        self.window.minSize = CGSize(width: 1000, height: 800)
        var frame = window.frame
        frame.size = NSSize(width: 1400, height: 1000) // Set desired width and height
        window.setFrame(frame, display: true, animate: true)
        //makeWindows()
        
        pageView = PageView(frame: .zero)
        
        window.contentView = pageView
        
        //window.appearance = NSAppearance(named: .aqua)
        //rootView.appearance = NSAppearance(named: .darkAqua)
        window.isOpaque = false
        window.backgroundColor = .clear
        
        let apps = AppsUtils.getAllApps()
        //rootView.setApps(apps)
        pageView.setApps(apps)
    }
    
    override var acceptsFirstResponder: Bool {
        get {
            return true
        }
    }
    
    override func keyDown(with event: NSEvent) {
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

}

