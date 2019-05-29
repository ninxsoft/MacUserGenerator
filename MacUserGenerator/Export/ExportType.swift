//
//  ExportType.swift
//  MacUserGenerator
//
//  Created by Nindi Gill on 1/11/17.
//  Copyright © 2017 Nindi Gill. All rights reserved.
//

import Cocoa

enum ExportType: Int {

  case package
  case script

  var title: String {

    switch self {
    case .package:
      return "Package"
    case .script:
      return "Script"
    }
  }

  var fileExtension: String {

    switch self {
    case .package:
      return "pkg"
    case .script:
      return "py"
    }
  }
}
