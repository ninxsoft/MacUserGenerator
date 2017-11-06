//
//  NSImage+Extension.swift
//  macOSUserGenerator
//
//  Created by Nindi Gill on 13/10/17.
//  Copyright © 2017 Nindi Gill. All rights reserved.
//

import Cocoa

extension NSImage {

  /**
   Returns an image resized using the provided size parameter.
   - parameters:
     - size: The output size of the image.
  */
  func resizedImage(with size: NSSize) -> NSImage {
    
    let sourceRect = NSRect(origin: NSPoint.zero, size: self.size)
    let destinationRect = NSRect(origin: NSPoint.zero, size: size)
    let image = NSImage(size: size)
    
    image.lockFocus()
    self.draw(in: destinationRect, from: sourceRect, operation: .sourceOver, fraction: 1.0)
    image.unlockFocus()
    image.size = size
    
    return NSImage(data: image.tiffRepresentation!)!
  }
  
  /**
   An array of valid image path extentions, used to filter image types.
  */
  class var validPathExtensions: [String] {
    return ["jpg", "jpeg", "gif", "bmp", "png", "tiff", "svg", "ico", "icns"]
  }
}
