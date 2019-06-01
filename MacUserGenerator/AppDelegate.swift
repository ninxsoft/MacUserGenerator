//
//  AppDelegate.swift
//  MacUserGenerator
//
//  Created by Nindi Gill on 9/10/17.
//  Copyright © 2019 Nindi Gill. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

  func applicationDidFinishLaunching(_ aNotification: Notification) {
    cleanupTemporaryPackageFiles()
  }

  func applicationWillTerminate(_ aNotification: Notification) {
    cleanupTemporaryPackageFiles()
  }

  /**
   Cleans up any temporary files or directories used when creating packages.
  */
  private func cleanupTemporaryPackageFiles() {

    let path = NSTemporaryDirectory() + "Packages"

    guard FileManager.default.fileExists(atPath: path) else {
      return
    }

    do {
      try FileManager.default.removeItem(atPath: path)
    } catch {
      print(error)
    }
  }
}
