//
//  ExportTabBarView.swift
//  MacUserGenerator
//
//  Created by Nindi Gill on 26/10/17.
//  Copyright © 2017 Nindi Gill. All rights reserved.
//

import Cocoa

@IBDesignable class ExportTabBarView: NSView {

  private var inDarkMode: Bool {
    let mode = UserDefaults.standard.string(forKey: "AppleInterfaceStyle")
    return mode == "Dark"
  }

  @IBInspectable var title: NSString = "Title"
  @IBInspectable var fontSize: CGFloat = 14.0
  @IBInspectable var selected: Bool = false

  override func draw(_ dirtyRect: NSRect) {
    super.draw(dirtyRect)

    // highlight background if tab bar view is selected
    if selected {
      let selectedBackgroundColor = inDarkMode ? NSColor.systemBlue.withAlphaComponent(0.2) :  NSColor.systemBlue.withAlphaComponent(0.2)
      selectedBackgroundColor.setFill()
      dirtyRect.fill()
    }

    // horizontally center the title within the dirtyRect
    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.alignment = .center

    // title attributes (font size, color, alignment)
    let textColor = inDarkMode ? NSColor.white : NSColor.black
    let selectedTextColor = inDarkMode ? NSColor.systemBlue : NSColor.systemBlue
    let attributes: [NSAttributedString.Key: Any] = [.font: NSFont.systemFont(ofSize: fontSize),
                                                    .foregroundColor: selected ? selectedTextColor : textColor,
                                                    .paragraphStyle: paragraphStyle]

    // vertically center the title within the dirtyRect
    let height = title.size(withAttributes: attributes).height
    var rect = dirtyRect
    rect.origin.y -= (dirtyRect.size.height - height) / 2

    title.draw(in: rect, withAttributes: attributes)
  }
}
