//
//  ViewController.swift
//  MacUserGenerator
//
//  Created by Nindi Gill on 9/10/17.
//  Copyright © 2019 Nindi Gill. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

  @IBOutlet var administratorButton: NSButton?
  @IBOutlet var standardButton: NSButton?
  @IBOutlet var fullNameTextField: NSTextField?
  @IBOutlet var accountNameTextField: NSTextField?
  @IBOutlet var accountNameImageView: NSImageView?
  @IBOutlet var pictureView: PictureView?
  @IBOutlet var passwordSecureTextField: NSSecureTextField?
  @IBOutlet var verifySecureTextField: NSSecureTextField?
  @IBOutlet var verifyImageView: NSImageView?
  @IBOutlet var passwordHintTextField: NSTextField?
  @IBOutlet var userIDTextField: NSTextField?
  @IBOutlet var userIDImageView: NSImageView?
  @IBOutlet var bashButton: NSButton?
  @IBOutlet var tcshButton: NSButton?
  @IBOutlet var shButton: NSButton?
  @IBOutlet var cshButton: NSButton?
  @IBOutlet var zshButton: NSButton?
  @IBOutlet var homeDirectoryTextField: NSTextField?
  @IBOutlet var homeDirectoryImageView: NSImageView?
  @IBOutlet var homeDirectorySelectButton: NSButton?
  @IBOutlet var hideUserAccountCheckbox: NSButton?
  @IBOutlet var hideHomeDirectoryCheckbox: NSButton?
  @IBOutlet var loginAutomaticallyCheckbox: NSButton?
  @IBOutlet var skipSetupAssistantCheckbox: NSButton?
  @IBOutlet var exportButton: NSButton?
  @IBOutlet var helpButton: NSButton?
  var documentObject = DocumentObject()

  override func viewDidAppear() {
    administratorButton?.state = documentObject.accountType == .administrator ? .on : .off
    standardButton?.state = documentObject.accountType == .standard ? .on : .off
    fullNameTextField?.stringValue = documentObject.fullName
    accountNameTextField?.stringValue = documentObject.accountName
    pictureView?.imageLayer.contents = documentObject.picture
    passwordSecureTextField?.stringValue = documentObject.password
    verifySecureTextField?.stringValue = documentObject.verify
    passwordHintTextField?.stringValue = documentObject.passwordHint
    userIDTextField?.stringValue = documentObject.userID
    bashButton?.state = documentObject.loginShell == .bash ? .on : .off
    tcshButton?.state = documentObject.loginShell == .tcsh ? .on : .off
    shButton?.state = documentObject.loginShell == .shell ? .on : .off
    cshButton?.state = documentObject.loginShell == .csh ? .on : .off
    zshButton?.state = documentObject.loginShell == .zsh ? .on : .off
    homeDirectoryTextField?.stringValue = documentObject.homeDirectory
    hideUserAccountCheckbox?.state = documentObject.hideUserAccount ? .on : .off
    hideHomeDirectoryCheckbox?.state = documentObject.hideHomeDirectory ? .on : .off
    loginAutomaticallyCheckbox?.state = documentObject.loginAutomatically ? .on : .off
    skipSetupAssistantCheckbox?.state = documentObject.skipSetupAssistant ? .on : .off
    validateExportButton()
  }

  /**
   Pulls down an NSOpenPanel to select an image for the picture view.
   - Parameters:
     - sender: The NSClickGestureRecognizer that was clicked.
  */
  @IBAction func pictureViewClicked(sender: NSClickGestureRecognizer) {

    let panel = NSOpenPanel()
    panel.canChooseFiles = true
    panel.canChooseDirectories = false
    panel.resolvesAliases = false
    panel.allowsMultipleSelection = false
    panel.canCreateDirectories = false
    panel.allowedFileTypes = NSImage.validPathExtensions

    panel.beginSheetModal(for: view.window!, completionHandler: { response -> Void in

      guard response == .OK else {
        return
      }

      guard let url = panel.url else {
        return
      }

      guard self.pictureView?.validateAndUpdateImageFromURL(url) == true else {
        return
      }

      self.documentHasBeenEdited()
      self.validateExportButton()
    })
  }

  /**
   Invokes the action associated with the button that was clicked.
   - Parameters:
     - sender: The NSButton that was clicked.
  */
  @IBAction func buttonClicked(sender: NSButton) {

    if sender == administratorButton {
      documentObject.accountType = .administrator
      documentHasBeenEdited()
    }

    if sender == standardButton {
      documentObject.accountType = .standard
      documentHasBeenEdited()
    }

    if sender == bashButton {
      documentObject.loginShell = .bash
      documentHasBeenEdited()
    }

    if sender == tcshButton {
      documentObject.loginShell = .tcsh
      documentHasBeenEdited()
    }

    if sender == shButton {
      documentObject.loginShell = .shell
      documentHasBeenEdited()
    }

    if sender == cshButton {
      documentObject.loginShell = .csh
      documentHasBeenEdited()
    }

    if sender == zshButton {
      documentObject.loginShell = .zsh
      documentHasBeenEdited()
    }

    if sender == homeDirectorySelectButton {
      showHomeDirectoryOpenPanel()
    }

    if sender == exportButton {
      showExportWindow()
    }

    if sender == helpButton {
      showHelp()
    }
  }

  /**
   Shows the NSOpenPanel to select the Users home directory.
  */
  private func showHomeDirectoryOpenPanel() {

    let panel = NSOpenPanel()
    panel.canChooseFiles = false
    panel.canChooseDirectories = true
    panel.resolvesAliases = false
    panel.allowsMultipleSelection = false
    panel.canCreateDirectories = false

    panel.beginSheetModal(for: view.window!, completionHandler: { response in

      guard response == .OK else {
        return
      }

      guard let path = panel.url?.path else {
        return
      }

      self.documentObject.homeDirectory = path
      self.homeDirectoryTextField?.stringValue = path
      self.documentHasBeenEdited()
      self.validateExportButton()
    })
  }

  /**
   Shows the Export window (and the attached ExportViewController), allowing for export type selection and options.
  */
  private func showExportWindow() {

    let storyboard = NSStoryboard(name: "Main", bundle: nil)
    let identifier = "ExportWindowController"

    guard let controller = storyboard.instantiateController(withIdentifier: identifier) as? NSWindowController else {
      return
    }

    view.window?.beginSheet((controller.window!), completionHandler: { response in

      guard response == .OK else {
        return
      }

      guard let viewController = controller.contentViewController as? ExportViewController else {
        return
      }

      let type = viewController.exportType
      let packageOptions = viewController.packageOptions
      let scriptOptions = viewController.scriptOptions
      self.showExportSavePanel(type: type, packageOptions: packageOptions, scriptOptions: scriptOptions)
    })
  }

  /**
   Shows the NSSavePanel to select a name and location for the export file.
   - Parameters:
     - type: The type of export (package or script).
  */
  private func showExportSavePanel(type: ExportType, packageOptions: PackageOptions, scriptOptions: ScriptOptions) {

    let panel = NSSavePanel()
    panel.nameFieldLabel = "Name:"
    panel.nameFieldStringValue = self.documentObject.accountName
    panel.allowedFileTypes = [type.fileExtension]

    panel.beginSheetModal(for: self.view.window!, completionHandler: { response -> Void in

      guard response == .OK else {
        return
      }

      switch type {
      case .package:
        Exporter.createPackageAt(url: panel.url!, documentObject: self.documentObject, options: packageOptions)
      case .script:
        Exporter.createScriptAt(url: panel.url!, documentObject: self.documentObject, options: scriptOptions)
      }
    })
  }

  /**
   Opens the Help URL in Safari.app.
  */
  private func showHelp() {
    let url = URL(fileURLWithPath: "https://github.com/ninxsoft/MacUserGenerator/")
    NSWorkspace.shared.open(url)
  }

  /**
   Toggles the checkbox that was selected.
   - Parameters:
     - sender: The NSButton (checkbox) that was selected.
  */
  @IBAction func checkBoxSelected(sender: NSButton) {

    let selected = sender.state == .on

    // if the option key was held down during a click
    guard !NSEvent.modifierFlags.contains(.option) else {
      documentObject.hideUserAccount = selected
      documentObject.hideHomeDirectory = selected
      documentObject.loginAutomatically = selected
      documentObject.skipSetupAssistant = selected
      hideUserAccountCheckbox?.state = selected ? .on : .off
      hideHomeDirectoryCheckbox?.state = selected ? .on : .off
      hideUserAccountCheckbox?.state = selected ? .on : .off
      loginAutomaticallyCheckbox?.state = selected ? .on : .off
      skipSetupAssistantCheckbox?.state = selected ? .on : .off
      return
    }

    if sender == hideUserAccountCheckbox {
      documentObject.hideUserAccount = selected
    } else if sender == hideHomeDirectoryCheckbox {
      documentObject.hideHomeDirectory = selected
    } else if sender == loginAutomaticallyCheckbox {
      documentObject.loginAutomatically = selected
    } else if sender == skipSetupAssistantCheckbox {
      documentObject.skipSetupAssistant = selected
    }

    documentHasBeenEdited()
    validateExportButton()
  }

  /**
   Flags the document window as edited.
  */
  func documentHasBeenEdited() {
    view.window?.windowController?.setDocumentEdited(true)
    view.window?.windowController?.document?.updateChangeCount(.changeDone)
  }

  /**
   Validates whether the Export button should be enabled or not, based on the input of the textfields and checkboxes.
  */
  private func validateExportButton() {

    if documentObject.accountName.isEmpty {
      accountNameImageView?.image = NSImage(named: "NSStatusPartiallyAvailable")
    } else if documentObject.accountName.isValidAccountName {
      accountNameImageView?.image = NSImage(named: "NSStatusAvailable")
    } else {
      accountNameImageView?.image = NSImage(named: "NSStatusUnavailable")
    }

    if documentObject.verify.isEmpty {
      verifyImageView?.image = NSImage(named: "NSStatusPartiallyAvailable")
    } else if documentObject.password == documentObject.verify {
      verifyImageView?.image = NSImage(named: "NSStatusAvailable")
    } else {
      verifyImageView?.image = NSImage(named: "NSStatusUnavailable")
    }

    if documentObject.userID.isEmpty {
      userIDImageView?.image = NSImage(named: "NSStatusPartiallyAvailable")
    } else if documentObject.userID.isValidUserID {
      userIDImageView?.image = NSImage(named: "NSStatusAvailable")
    } else {
      userIDImageView?.image = NSImage(named: "NSStatusUnavailable")
    }

    if documentObject.homeDirectory.isEmpty {
      homeDirectoryImageView?.image = NSImage(named: "NSStatusPartiallyAvailable")
    } else if documentObject.homeDirectory.isValidHomeDirectory {
      homeDirectoryImageView?.image = NSImage(named: "NSStatusAvailable")
    } else {
      homeDirectoryImageView?.image = NSImage(named: "NSStatusUnavailable")
    }

    exportButton?.isEnabled = documentObject.accountName.isValidAccountName &&
                              documentObject.userID.isValidUserID &&
                              documentObject.password == documentObject.verify &&
                              documentObject.homeDirectory.isValidHomeDirectory
  }
}

extension ViewController: NSTextFieldDelegate {

  func controlTextDidChange(_ obj: Notification) {

    guard let textField = obj.object as? NSTextField else {
      return
    }

    let string = textField.stringValue

    if textField == fullNameTextField {
      documentObject.fullName = string
    } else if textField == accountNameTextField {
      documentObject.accountName = string
    } else if textField == passwordSecureTextField {
      documentObject.password = string
    } else if textField == verifySecureTextField {
      documentObject.verify = string
    } else if textField == passwordHintTextField {
      documentObject.passwordHint = string
    } else if textField == userIDTextField {
      documentObject.userID = string
    } else if textField == homeDirectoryTextField {
      documentObject.homeDirectory = string
    }

    documentHasBeenEdited()
    validateExportButton()
  }

  func controlTextDidEndEditing(_ obj: Notification) {

    guard let textField = obj.object as? NSTextField else {
      return
    }

    let string = textField.stringValue

    // auto populate account name if full name has been entered, and account name is blank
    if textField == fullNameTextField && (accountNameTextField?.stringValue.isEmpty)! {
      let accountName = string.convertedToAccountName
      documentObject.accountName = accountName
      accountNameTextField?.stringValue = accountName
    }
    // auto populate home directory if account name has been entered and is valid and home directory is blank
    else if textField == accountNameTextField &&
      documentObject.accountName.isValidAccountName &&
      (homeDirectoryTextField?.stringValue.isEmpty)! {
      let homeDirectory = "/Users/\(string)"
      documentObject.homeDirectory = homeDirectory
      homeDirectoryTextField?.stringValue = homeDirectory
    }

    validateExportButton()
  }
}
