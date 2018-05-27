//
//  Exporter.swift
//  macOSUserGenerator
//
//  Created by Nindi Gill on 16/10/17.
//  Copyright © 2017 Nindi Gill. All rights reserved.
//

import Cocoa
import Security

class Exporter: NSObject {

  /**
   Creates a script at the specified url, using the provided document object and any options that are specified.
   - parameters:
     - url: The url at which to create the script.
     - documentObject: The document object to be used as the basis of the script.
     - options: Any script options that are specified when exporting.
  */
  class func createScriptAt(url: URL, documentObject: DocumentObject, options: ScriptOptions) {
    
    let scriptURL = Bundle.main.url(forResource: "Export", withExtension: "sh")
    
    do {
      var script = try String(contentsOf: scriptURL!)
      script = script.replaceFirstOccurrence(of: "#NAME#", with: documentObject.accountName)
      script = script.replaceFirstOccurrence(of: "#REALNAME#", with: documentObject.fullName)
      script = script.replaceFirstOccurrence(of: "#UID#", with: documentObject.userID)
      script = script.replaceFirstOccurrence(of: "#SHELL#", with: documentObject.loginShell.rawValue)
      script = script.replaceFirstOccurrence(of: "#HINT#", with: documentObject.passwordHint)
      
      if documentObject.hideHomeDirectory {
        script = script.replaceFirstOccurrence(of: "#HOME#", with: "/var/\(documentObject.accountName)")
      }
      else {
        script = script.replaceFirstOccurrence(of: "#HOME#", with: documentObject.homeDirectory)
      }
      
      script = script.replaceFirstOccurrence(of: "#SHADOWHASH#", with: documentObject.password.shadowHash)
      
      if documentObject.accountType == .Administrator {
        script = script.replacingOccurrences(of: "###SETADMINISTRATOR###", with: "")
      }
      else {
        script = script.replacePatternMatches(of: "###SETADMINISTRATOR###[\\s\\S]*###SETADMINISTRATOR###\\s", with: "")
      }
      
      if documentObject.hideUserAccount {
        script = script.replacingOccurrences(of: "###HIDEUSERACCOUNT###", with: "")
      }
      else {
        script = script.replacePatternMatches(of: "###HIDEUSERACCOUNT###[\\s\\S]*###HIDEUSERACCOUNT###\\s", with: "")
      }
      
      if documentObject.loginAutomatically {
        script = script.replacingOccurrences(of: "###SETAUTOLOGIN###", with: "")
        script = script.replaceFirstOccurrence(of: "#KCPASSWORDSTRING#", with: documentObject.password.kcpassword)
      }
      else {
        script = script.replacePatternMatches(of: "###SETAUTOLOGIN###[\\s\\S]*###SETAUTOLOGIN###\\s", with: "")
      }
      
      if documentObject.skipSetupAssistant {
        script = script.replacingOccurrences(of: "###SKIPSETUPASSISTANT###", with: "")
        
        if documentObject.skipiCloud {
          script = script.replacingOccurrences(of: "###SKIPICLOUD###", with: "")
        }
        else {
          script = script.replacePatternMatches(of: "###SKIPICLOUD[\\s\\S]*###SKIPICLOUD###\\s", with: "")
        }
        
        if documentObject.skipSiri {
          script = script.replacingOccurrences(of: "###SKIPSIRI###", with: "")
        }
        else {
          script = script.replacePatternMatches(of: "###SKIPSIRI###[\\s\\S]*###SKIPSIRI###\\s", with: "")
        }
        
        if documentObject.skipTouchID {
          script = script.replacingOccurrences(of: "###SKIPTOUCHID###", with: "")
        }
        else {
          script = script.replacePatternMatches(of: "###SKIPTOUCHID###[\\s\\S]*###SKIPTOUCHID###\\s", with: "")
        }
        
        if documentObject.skipAnalytics {
          script = script.replacingOccurrences(of: "###SKIPANALYTICS###", with: "")
        }
        else {
          script = script.replacePatternMatches(of: "###SKIPANALYTICS###[\\s\\S]*###SKIPANALYTICS###\\s", with: "")
        }
        
        if documentObject.skipDataPrivacy {
          script = script.replacingOccurrences(of: "###SKIPDATAPRIVACY###", with: "")
        }
        else {
          script = script.replacePatternMatches(of: "###SKIPDATAPRIVACY###[\\s\\S]*###SKIPDATAPRIVACY###\\s", with: "")
        }
      }
      else {
        script = script.replacePatternMatches(of: "###SKIPSETUPASSISTANT###[\\s\\S]*###SKIPSETUPASSISTANT###\\s", with: "")
        script = script.replacePatternMatches(of: "###SKIPICLOUD###[\\s\\S]*###SKIPICLOUD###\\s", with: "")
        script = script.replacePatternMatches(of: "###SKIPSIRI###[\\s\\S]*###SKIPSIRI###\\s", with: "")
        script = script.replacePatternMatches(of: "###SKIPTOUCHID###[\\s\\S]*###SKIPTOUCHID###\\s", with: "")
        script = script.replacePatternMatches(of: "###SKIPANALYTICS###[\\s\\S]*###SKIPANALYTICS###\\s", with: "")
        script = script.replacePatternMatches(of: "###SKIPDATAPRIVACY###[\\s\\S]*###SKIPDATAPRIVACY###\\s", with: "")
      }
      
      // do the picture base64 string last, as it's hella long and stuffs up the regex matching range
      if documentObject.picture.isValid  {

        if let tiff = documentObject.picture.tiffRepresentation {
          let string = tiff.base64EncodedString(options: .lineLength64Characters)
          // script = script.replaceFirstOccurrence(of: "#PICTURE#", with: string)
          // currently commented out, need to test
          script = script.replaceFirstOccurrence(of: "#PICTURE#", with: "")
        }
        else {
          script = script.replaceFirstOccurrence(of: "#PICTURE#", with: "")
        }
      }
      else {
        script = script.replaceFirstOccurrence(of: "#PICTURE#", with: "")
      }
    
      try script.write(to: url, atomically: true, encoding: .utf8)
        
      // make the script executable
      let command = "chmod +x \(url.path)"
      let task = Process()
      let outputPipe = Pipe()
      let errorPipe = Pipe()
      task.standardOutput = outputPipe
      task.standardError = errorPipe
      task.launchPath = "/bin/bash"
      task.arguments = ["-l", "-c", command]
      task.launch()
      task.waitUntilExit()
    }
    catch {
      print(error)
    }
  }
  
  /**
   Creates a package at the specified url, using the provided document object and any options that are specified.
   - parameters:
     - url: The url at which to create the package.
     - documentObject: The document object to be used as the basis of the package.
     - options: Any package options that are specified when exporting.
   */
  class func createPackageAt(url: URL, documentObject: DocumentObject, options: PackageOptions) {
    
    let packagesPath = "\(NSTemporaryDirectory())/Packages"
    let packagePath = "\(packagesPath)/\(options.identifier.replacingOccurrences(of: ".", with: ""))"
    let packageURL = URL(fileURLWithPath: "\(packagePath)/\(url.lastPathComponent)")
    let scriptsPath = "\(packagePath)/Scripts"
    let scriptsURL = URL(fileURLWithPath: scriptsPath, isDirectory: true)
    let scriptPath = "\(scriptsPath)/postinstall"
    let scriptURL = URL(fileURLWithPath: scriptPath, isDirectory: false)
    
    do {
      try FileManager.default.createDirectory(at: scriptsURL,
                                              withIntermediateDirectories: true,
                                              attributes: nil)
      
      createScriptAt(url: scriptURL, documentObject: documentObject, options: ScriptOptions())
      buildPackage(identifier: options.identifier,
                   version: options.version,
                   scripts: scriptsPath,
                   certificate: options.certificate,
                   fromURL: packageURL,
                   toURL: url)
    }
    catch {
      print(error)
    }
  }
  
  /**
   Builds a package with the provided options in a temporary location,
   - parameters:
     - identifier: The unique identifier to associate with the package. Uses reverse domain name notation.
     - version: The version number to associate with the package.
     - scripts: The folder containing preinstall and postinstall scripts to be added to the package.
     - certificate: The full name of a Developer ID Certificate, used to sign the package. If this is empty, the package is created unsigned.
     - fromURL: The temporary url location of the package.
     - toURL: The destination url location of the package.
   */
  private static func buildPackage(identifier: String, version: String, scripts: String, certificate: String, fromURL: URL, toURL: URL) {
    
    let command = "pkgbuild --identifier \(identifier)" +
                          " --version \(version)" +
                          " --nopayload --scripts \(scripts) " +
                          (certificate.isEmpty ? "" : "--sign \"\(certificate)\"") +
                          " --timestamp=none" +
                          " \(fromURL.path)"
    
    DispatchQueue.global(qos: .background).async { () -> Void in

      let task = Process()
      let outputPipe = Pipe()
      let errorPipe = Pipe()
      task.standardOutput = outputPipe
      task.standardError = errorPipe
      task.launchPath = "/bin/bash"
      task.arguments = ["-l", "-c", command]
      task.terminationHandler = { process in
        
//        let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
//
//        if let string = String(data: outputData, encoding: .utf8) {
//          print("OUTPUT: \(string)")
//        }
//
//        let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
//
//        if let string = String(data: errorData, encoding: .utf8) {
//          print("ERROR: \(string)")
//        }
        
        DispatchQueue.main.async {
          
          do {
            // overwrite the destination package, if required
            let _ = try FileManager.default.replaceItemAt(toURL, withItemAt: fromURL)
            // delete the temporary package, if required
            try FileManager.default.removeItem(atPath: fromURL.deletingLastPathComponent().path)
          }
          catch {
            print(error)
          }
        }
      }

      task.launch()
    }
  }
}
