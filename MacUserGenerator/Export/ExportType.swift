//
//  ExportType.swift
//  macOSUserGenerator
//
//  Created by Nindi Gill on 1/11/17.
//  Copyright © 2017 Nindi Gill. All rights reserved.
//

import Cocoa

enum ExportType: Int {

  case Package
  case Script

  var title: String {

    switch self {
    case .Package:
      return "Package"
    case .Script:
      return "Script"
    }
  }

  var fileExtension: String {
    
    switch self {
    case .Package:
      return "pkg"
    case .Script:
      return "sh"
    }
  }
}
