//
//  KhWindow.swift
//  MacOS-Launcpad
//
//  Created by Алексей Химунин on 17.08.2025.
//

import AppKit

class KhWindow: NSWindow {
    
    override var canBecomeKey: Bool {
        get {
            return true
        }
    }
    
    override var canBecomeMain: Bool {
        get {
            return true
        }
    }
}
