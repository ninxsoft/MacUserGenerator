//
//  NSBezierPath+Extension.swift
//  macOSUserGenerator
//
//  Created by Nindi Gill on 26/10/17.
//  Copyright © 2017 Nindi Gill. All rights reserved.
//

import Cocoa

extension NSBezierPath {

  /**
   Returns a CGPath converted from the provided NSBezierPath
  */
  var CGPath: CGPath {
   
    let path = CGMutablePath()
    var points = [CGPoint.zero, CGPoint.zero, CGPoint.zero]
    
    for i in 0..<self.elementCount {
      
      let type = self.element(at: i, associatedPoints: &points)
      
      switch type {
      case .moveToBezierPathElement:
        path.move(to: points[0])
        break
      case .lineToBezierPathElement:
        path.addLine(to: points[0])
        break
      case .curveToBezierPathElement:
        path.addCurve(to: points[0], control1: points[1], control2: points[2])
        break
      case .closePathBezierPathElement:
        path.closeSubpath()
        break
      }
    }
    
    return path
  }
}
