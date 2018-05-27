//
//  PictureView.swift
//  MacUserGenerator
//
//  Created by Nindi Gill on 26/10/17.
//  Copyright © 2017 Nindi Gill. All rights reserved.
//

import Cocoa

class PictureView: NSView {

  var imageLayer = CALayer()
  var shapeLayer = CAShapeLayer()
  var textLayer = CATextLayer()
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    
    // layer
    self.wantsLayer = true
    self.layer?.borderWidth = 0.5
    self.layer?.borderColor = NSColor.systemGray.cgColor
    self.layer?.cornerRadius = self.frame.width / 2
    self.layer?.masksToBounds = true
    
    // image layer
    imageLayer.frame = NSRect(origin: CGPoint.zero, size: frame.size)
    imageLayer.contentsGravity = kCAGravityResizeAspect
    self.layer?.addSublayer(imageLayer)
    
    // shape layer
    let path = NSBezierPath(rect: self.bounds)
    shapeLayer.path = path.CGPath
    shapeLayer.fillColor = NSColor.systemGray.cgColor
    shapeLayer.opacity = 0.25
    shapeLayer.isHidden = true
    self.layer?.addSublayer(shapeLayer)
    
    // text layer
    let attributes = [NSAttributedStringKey.font: NSFont.systemFont(ofSize: 14.0),
                      NSAttributedStringKey.foregroundColor: NSColor.white.cgColor] as [NSAttributedStringKey : Any]
    let attributedString = NSAttributedString(string: "Edit", attributes: attributes)
    textLayer.string = attributedString
    textLayer.backgroundColor = NSColor.black.cgColor
    textLayer.alignmentMode = kCAAlignmentCenter
    textLayer.contentsScale = (NSScreen.main?.backingScaleFactor)!
    let size = CGSize(width: self.frame.size.width,
                      height: self.frame.size.height * 0.25)
    let textRect = NSRect(origin: CGPoint.zero, size: size)
    textLayer.frame = textRect
    textLayer.isHidden = true
    self.layer?.addSublayer(textLayer)
    
    // tracking
    let trackingRect = NSRect(origin: CGPoint.zero, size: self.frame.size)
    let options: NSTrackingArea.Options = [.activeInKeyWindow, .mouseEnteredAndExited, .mouseMoved]
    let trackingArea = NSTrackingArea(rect: trackingRect, options: options, owner: self, userInfo: nil)
    self.addTrackingArea(trackingArea)
    
    // dragging
    if #available(OSX 10.13, *) {
      self.registerForDraggedTypes([.URL])
    }
  }
  
  override func mouseEntered(with event: NSEvent) {
    shapeLayer.isHidden = false
    textLayer.isHidden = false
  }
  
  override func mouseExited(with event: NSEvent) {
    shapeLayer.isHidden = true
    textLayer.isHidden = true
  }
  
  override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
    
    let pasteboard = sender.draggingPasteboard()
    let url = NSURL(from: pasteboard)
    
    guard let pathExtension = url?.pathExtension else {
      return .delete
    }
    
    return NSImage.validPathExtensions.contains(pathExtension) ? .copy : .delete
  }
  
  override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {

    let pasteboard = sender.draggingPasteboard()
    let url = NSURL(from: pasteboard)
    
    guard let pathExtension = url?.pathExtension else {
      return false
    }
    
    return NSImage.validPathExtensions.contains(pathExtension)
  }
  
  override func concludeDragOperation(_ sender: NSDraggingInfo?) {
    
    guard let pasteboard = sender?.draggingPasteboard() else {
      return
    }
    
    guard let url = NSURL(from: pasteboard) else {
      return
    }
    
    _ = validateAndUpdateImageFromURL(url as URL)
  }
  
  /**
   Validates and updates the image for the picture view.
   - Parameters:
     - url: The URL of the image.
  */
  func validateAndUpdateImageFromURL(_ url: URL) -> Bool {
    
    guard let viewController = window?.contentViewController as? ViewController,
      let image = NSImage(contentsOf: url) else {
      return false
    }
    
    let size = NSSize(width: 128, height: 128)
    let resizedImage = image.resizedImage(with: size)
    imageLayer.contents = resizedImage
    viewController.documentObject.picture = resizedImage
    return true
  }
}
