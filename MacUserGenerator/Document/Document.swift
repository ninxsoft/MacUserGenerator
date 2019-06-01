//
//  Document.swift
//  MacUserGenerator
//
//  Created by Nindi Gill on 9/10/17.
//  Copyright © 2019 Nindi Gill. All rights reserved.
//

import Cocoa

class Document: NSDocument {

  var dictionary = NSDictionary()

  override class var autosavesInPlace: Bool {
    return true
  }

  override func makeWindowControllers() {

    let storyboard = NSStoryboard(name: "Main", bundle: nil)
    let identifier = "Document Window Controller"

    guard let controller = storyboard.instantiateController(withIdentifier: identifier) as? NSWindowController else {
      return
    }

    guard let viewController = controller.contentViewController as? ViewController else {
      return
    }

    viewController.documentObject = DocumentObject(dictionary: dictionary)
    self.addWindowController(controller)
  }

  override func read(from url: URL, ofType typeName: String) throws {

    guard let dictionary = NSDictionary(contentsOf: url) else {
      throw NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)
    }

    self.dictionary = dictionary
  }

  override func write(to url: URL, ofType typeName: String) throws {

    guard let viewController = self.windowControllers.first?.contentViewController as? ViewController else {
      throw NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)
    }

    let dictionary = viewController.documentObject.dictionary

    guard dictionary.write(to: url, atomically: true) else {
      return
    }

    self.windowControllers.first?.setDocumentEdited(false)
  }
}
