//
//  KhSearchField.swift
//  MacOS-Launcpad
//
//  Created by Алексей Химунин on 18.08.2025.
//

import AppKit

class KhSearchFieldCell: NSTextFieldCell {
}

class KhSearchField: NSSearchField {
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        initView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initView()
    }
    
    override var searchButtonBounds: NSRect {
        get {
            return CGRect(x: 60, y: 0, width: 32, height: 32)
        }
    }
    
    override var searchTextBounds: NSRect {
        get {
            let selfSize = self.bounds.size
            let left = selfSize.height
            let widht = selfSize.width - 2 * left
            //return CGRect(x: left, y: 0, width: widht, height: selfSize.height)
            return CGRect(x: 100, y: 0, width: 32, height: 32)
        }
    }
    
//    override func rectForSearchText(whenCentered isCentered: Bool) -> NSRect {
//        super.rectForSearchText(whenCentered: isCentered)
//        return CGRect(x: 100, y: 0, width: 100, height: 32)
//    }

    private var searchFieldCell = KhSearchFieldCell()
    private func initView() {
        cell = searchFieldCell
        textColor = .white
        font = NSFont.systemFont(ofSize: 24)
        if let searchButtonCell = self.cell as? NSSearchFieldCell {
            if let searchButton = searchButtonCell.searchButtonCell {
                let search = NSImage.search
                search.isTemplate = true
                
                searchButton.image = search
                searchButton.imageScaling = .scaleProportionallyUpOrDown
//                searchButton.wantsLayer = true
//                searchButton.layer?.backgroundColor = NSColor.white.cgColor
            }
//             searchButtonCell.setButtonType(.toggle)
//             let filterImage = #imageLiteral(resourceName: "filter")
//             searchButtonCell.image = filterImage.tinted(with: .systemGray)
//             searchButtonCell.alternateImage = filterImage.tinted(with: .systemBlue)
         }
        
        self.delegate = self
//        //searchField.isEditable = true
//        //searchField.wantsLayer = true
//        //searchField.layer?.backgroundColor = NSColor.clear.cgColor
//        searchField.drawsBackground = true
//        searchField.backgroundColor = .clear
        //drawsBackground = true
        //backgroundColor = .red
        
        wantsLayer = true
        layer?.backgroundColor = NSColor.clear.cgColor
        
        layer?.borderColor = NSColor.darkGray.cgColor
        layer?.borderWidth = 1
        layer?.cornerRadius = 16
        
        isBezeled = false
        //bezelStyle = .roundedBezel
        focusRingType = .none
        
        //appearance =
        //[NSAppearance appearanceNamed:NSAppearanceNameVibrantLight];
        
    }
    
//    override func rectForSearchText(whenCentered isCentered: Bool) -> NSRect {
//        super.rectForSearchText(whenCentered: isCentered)
//        print(isCentered)
//        
//        let selfSize = self.bounds.size
//        let left = selfSize.height
//        let width = selfSize.width - 2 * left
//        
//        return CGRect(x: left, y: 0, width: width, height: selfSize.height)
//    }

    
//    open override func textShouldBeginEditing(_ textObject: NSText) -> Bool {
//        print("")
//        return true
//    }
//
//    open override func textShouldEndEditing(_ textObject: NSText) -> Bool {
//        print("")
//        return true
//    }
//
//    open override func textDidBeginEditing(_ notification: Notification) {
//        print("")
//    }
    
//    override var acceptsFirstResponder: Bool {
//        layer?.borderColor = NSColor.white.cgColor
//        layer?.borderWidth = 2
//        return true
//    }
//
//    open override func textDidEndEditing(_ notification: Notification) {
//        layer?.borderColor = NSColor.darkGray.cgColor
//        layer?.borderWidth = 1
//    }
    
    open override func draw(_ dirtyRect: NSRect) {
        let newRect = dirtyRect.insetBy(dx: 16, dy: 2)
        super.draw(newRect)
    }
    
//    override func select(withFrame: NSRect, in: NSView, editor: NSText, delegate: Any?, start: Int, length: Int) {
//        
//    }
    
}

extension KhSearchField: NSSearchFieldDelegate {
//    func searchFieldDidStartSearching(_ sender: NSSearchField) {
//        layer?.borderColor = NSColor.white.cgColor
//        layer?.borderWidth = 2
//    }
//    
//    func searchFieldDidEndSearching(_ sender: NSSearchField) {
//        layer?.borderColor = NSColor.darkGray.cgColor
//        layer?.borderWidth = 1
//    }
}
