//
//  KhSearchFieldNew.swift
//  MacOS-Launcpad
//
//  Created by Алексей Химунин on 18.08.2025.
//

import AppKit

class KhSearchFieldNewCell: NSTextFieldCell {
    var horizontalPadding: CGFloat = 32.0
    var verticalPadding: CGFloat = 1.0

    // Override methods to customize drawing, behavior, etc.
    override func draw(withFrame cellFrame: NSRect, in controlView: NSView) {
        // Custom drawing code here
        // Example: Draw a custom background or border
//        NSColor.systemBlue.setFill()
//        cellFrame.fill()

        // Call super to draw the text content
        super.draw(withFrame: cellFrame, in: controlView)
    }

    override func select(withFrame rect: NSRect, in controlView: NSView, editor textObj: NSText, delegate: Any?, start selStart: Int, length selLength: Int) {
        let insetRect = rect.insetBy(dx: horizontalPadding, dy: verticalPadding)
        super.select(withFrame: insetRect, in: controlView, editor: textObj, delegate: delegate, start: selStart, length: selLength)
    }
//
//    override func fieldEditor(for controlView: NSView) -> NSTextView? {
//        super.fieldEditor(for: controlView)
//    }

    override func drawInterior(withFrame cellFrame: NSRect, in controlView: NSView) {
        let insetRect = cellFrame.insetBy(dx: horizontalPadding, dy: verticalPadding)
        super.drawInterior(withFrame: insetRect, in: controlView)
    }
}

class KhSearchFieldNew: NSTextField {
    var onSearchTextChanged: ((String) -> Void)?

    private var searchIconView: NSImageView!
    private var clearButton: NSButton!

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        initView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initView()
    }

    private let placeholderTextColor = NSColor.gray

    private func initView() {
        self.delegate = self

        let paddedCell = KhSearchFieldNewCell()
        self.cell = paddedCell

        searchIconView = NSImageView(image: NSImage.search)
        searchIconView.imageScaling = .scaleProportionallyUpOrDown
        addSubview(searchIconView)

        clearButton = NSButton(image: NSImage.delete, target: self, action: #selector(clearButtonClicked(_:)))
        clearButton.wantsLayer = true
        clearButton.layer?.backgroundColor = NSColor.clear.cgColor
        clearButton.isBordered = false
        clearButton.imagePosition = .imageOnly
        clearButton.isHidden = true
        addSubview(clearButton)

        wantsLayer = true
        layer?.backgroundColor = NSColor.clear.cgColor
        
        isBezeled = false
        focusRingType = .none

        drawsBackground = false
        backgroundColor = .clear

        isEnabled = true
        isEditable = true
        usesSingleLineMode = true

        let placeholderAttrString = NSAttributedString(string: "App Search", attributes: [.foregroundColor: NSColor.gray])
        self.placeholderAttributedString = placeholderAttrString
        self.stringValue = ""

        layer?.borderWidth = 1
        layer?.borderColor = NSColor.white.cgColor
    }

    override var frame: NSRect {
                didSet {
                    resizeSubviews(withOldSize: self.bounds.size)
                }
            }

    override func resizeSubviews(withOldSize oldSize: NSSize) {
        super.resizeSubviews(withOldSize: oldSize)
        
        let selfSize = self.frame.size
        
        layer?.cornerRadius = selfSize.height * 0.5

        let iconPadding: CGFloat = 4
        let iconSize: CGFloat = selfSize.height - iconPadding * 2
        searchIconView.frame = CGRect(x: iconPadding, y: iconPadding, width: iconSize, height: iconSize)

        clearButton.frame = CGRect(x: selfSize.width - selfSize.height, y: 0, width: selfSize.height, height: selfSize.height)
    }

    @objc func clearButtonClicked(_ sender: Any?) {
        self.stringValue = ""
        self.onSearchTextChanged?(self.stringValue)
        clearButton.isHidden = true
    }

//    override var acceptsFirstResponder: Bool {
//        return true
//    }
//    
    override func keyDown(with event: NSEvent) {
        if event.keyCode == 53 {
            NSApp.terminate(nil)
        }
    }
}

extension KhSearchFieldNew : NSTextFieldDelegate {
    func controlTextDidChange(_ obj: Notification) {
        let textField = obj.object as! NSTextField
        if textField.stringValue.count > 0 {
            clearButton.isHidden = false
        } else {
            clearButton.isHidden = true
        }
        onSearchTextChanged?(textField.stringValue)
    }
}

extension NSTextField {
    var isFirstResponder: Bool {
        return currentEditor() == window?.firstResponder
    }
}
