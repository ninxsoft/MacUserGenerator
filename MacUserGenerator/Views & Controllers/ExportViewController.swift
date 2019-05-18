//
//  ExportViewController.swift
//  MacUserGenerator
//
//  Created by Nindi Gill on 16/10/17.
//  Copyright © 2017 Nindi Gill. All rights reserved.
//

import Cocoa

class ExportViewController: NSViewController {

  @IBOutlet var packageTabBarView: ExportTabBarView?
  @IBOutlet var scriptTabBarView: ExportTabBarView?
  @IBOutlet var tabView: NSTabView?
  @IBOutlet var packageIdentifierTextField: NSTextField?
  @IBOutlet var packageVersionTextField: NSTextField?
  @IBOutlet var packageCertificatesPopUpButton: NSPopUpButton?
  @IBOutlet var cancelButton: NSButton?
  @IBOutlet var nextButton: NSButton?
  var certificates = [String]()
  var exportType = ExportType.Package
  var packageOptions = PackageOptions()
  var scriptOptions = ScriptOptions()
  
  override func viewWillAppear() {
    certificates = getCertificates()
    populateCertificatePopupButton(with: certificates)
  }
  
  /**
   Returns an array of strings containing any Developer Installer Certificates found on the machine.
  */
  private func getCertificates() -> [String] {
    
    var certificates = [String]()
    
    let command = "security find-identity -v | grep \"Developer ID Installer:\""
    let task = Process()
    let outputPipe = Pipe()
    let errorPipe = Pipe()
    task.standardOutput = outputPipe
    task.standardError = errorPipe
    task.launchPath = "/bin/bash"
    task.arguments = ["-l", "-c", command]
    task.launch()
    task.waitUntilExit()
    
    let data = outputPipe.fileHandleForReading.readDataToEndOfFile()
  
    guard let string = String(data: data, encoding: .utf8) else {
      return certificates
    }

    let strings = string.split{$0 == "\n"}.map(String.init)

    for string in strings {
      // strip out the leading whitespace and the uuid
      let certificate = string.replacePatternMatches(of: "^.*[0-9A-F]{40} ", with: "").replacingOccurrences(of: "\"", with: "")
      certificates.append(certificate)
    }
  
    return certificates
  }
  
  /**
   Populates the NSPopupButton with items containing Developer Installer Certificate names.
   - Parameters:
     - certificates: The array of strings contaning Developer Installer Certificate names.
  */
  private func populateCertificatePopupButton(with certificates: [String]) {

    guard !certificates.isEmpty else {
      packageCertificatesPopUpButton?.addItem(withTitle: "No certificates found")
      return
    }
    
    for certificate in certificates {
      
      packageCertificatesPopUpButton?.addItem(withTitle: certificate)
        
      if let image = NSImage(named: "Certificate"),
        let item = self.packageCertificatesPopUpButton?.itemArray.last {
        item.image = image
      }
    }
    
    if let title = packageCertificatesPopUpButton?.itemTitles[2] {
      packageCertificatesPopUpButton?.selectItem(withTitle: title)
    }
  }
  
  /**
   Selects the Tab Bar view that was clicked. Also unselects all other Tab Bar Views.
   - Parameters:
   - sender: The NSClickGestureRecognizer that was clicked.
  */
  @IBAction func exportTabBarViewClicked(sender: NSClickGestureRecognizer) {
    
    for (index, tabBarView) in [packageTabBarView, scriptTabBarView].enumerated() {
      
      tabBarView?.selected = sender.view == tabBarView
      
      if sender.view == tabBarView {
        
        if let type = ExportType(rawValue: index) {
          exportType = type
        }
        
        tabView?.selectTabViewItem(at: index)
      }
    }
    
    validateNextButton()
  }
  
  func controlTextDidChange(_ obj: Notification) {
    validateNextButton()
  }
  
  /**
   Validates the Next button based on the options selected in the Tab Views.
  */
  private func validateNextButton() {
    
    switch exportType {
    case .Package:
      // if export type is package, ensure package identifier and version fields are not empty
      nextButton?.isEnabled = !(packageIdentifierTextField?.stringValue.isEmpty)! && !(packageVersionTextField?.stringValue.isEmpty)!
      break
    case .Script:
      nextButton?.isEnabled = true
      break
    }
  }
  
  /**
   Closes the Export Window, by selecting either the Cancel or Next... buttons
   - Parameters:
   - sender: The button that was clicked.
  */
  @IBAction func buttonClicked(sender: NSButton) {
      
    switch exportType {
    case .Package:
      packageOptions.identifier = (packageIdentifierTextField?.stringValue)!
      packageOptions.version = (packageVersionTextField?.stringValue)!
      
      if let certificate = packageCertificatesPopUpButton?.titleOfSelectedItem {
       
        if certificates.contains(certificate) {
          packageOptions.certificate = certificate
        }
      }
      break
    case .Script:
      // script options go here
      break
    }
    
    let returnCode: NSApplication.ModalResponse = sender == cancelButton ? .cancel : .OK
    view.window?.sheetParent?.endSheet(view.window!, returnCode: returnCode)
  }
}
