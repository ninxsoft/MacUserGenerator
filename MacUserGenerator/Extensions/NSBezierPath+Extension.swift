//
//  NSBezierPath+Extension.swift
//  MacUserGenerator
//
//  Created by Nindi Gill on 26/10/17.
//  Copyright © 2019 Nindi Gill. All rights reserved.
//

import Cocoa

extension NSBezierPath {

  /**
   Returns a CGPath converted from the provided NSBezierPath
  */
  var CGPath: CGPath {

    let path = CGMutablePath()
    var points = [CGPoint.zero, CGPoint.zero, CGPoint.zero]

    for index in 0..<self.elementCount {

      let type = self.element(at: index, associatedPoints: &points)

      switch type {
      case .moveTo:
        path.move(to: points[0])
      case .lineTo:
        path.addLine(to: points[0])
      case .curveTo:
        path.addCurve(to: points[0], control1: points[1], control2: points[2])
      case .closePath:
        path.closeSubpath()
      default:
        path.closeSubpath()
      }
    }

    return path
  }
}
