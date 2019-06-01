//
//  DocumentObject.swift
//  MacUserGenerator
//
//  Created by Nindi Gill on 11/10/17.
//  Copyright © 2019 Nindi Gill. All rights reserved.
//

import Cocoa

class DocumentObject: NSObject {

  enum Key: String {
    case accountType
    case fullName
    case accountName
    case picture
    case password
    case verify
    case passwordHint
    case userID
    case loginShell
    case homeDirectory
    case hideUserAccount
    case hideHomeDirectory
    case loginAutomatically
    case skipSetupAssistant
  }

  enum AccountType: String {
    case administrator
    case standard
  }

  enum LoginShell: String {
    case bash = "/bin/bash"
    case tcsh = "/bin/tcsh"
    case shell = "/bin/sh"
    case csh = "/bin/csh"
    case zsh = "/bin/zsh"
  }

  // document defaults
  var accountType = AccountType.administrator
  var fullName = ""
  var accountName = ""
  var picture = NSImage()
  var password = ""
  var verify = ""
  var passwordHint = ""
  var userID = ""
  var loginShell = LoginShell.bash
  var homeDirectory = ""
  var hideUserAccount = false
  var hideHomeDirectory = false
  var loginAutomatically = false
  var skipSetupAssistant = false

  convenience init(dictionary: NSDictionary) {
    self.init()

    if let string = dictionary[Key.accountType.rawValue] as? String,
      let type = AccountType(rawValue: string) {
      accountType = type
    }

    if let string = dictionary[Key.fullName.rawValue] as? String {
      fullName = string
    }

    if let string = dictionary[Key.accountName.rawValue] as? String {
      accountName = string
    }

    if let data = dictionary[Key.picture.rawValue] as? Data,
      let image = NSImage(data: data) {
      picture = image
    } else if let image = NSImage(named: "Picture") {
      picture = image
    }

    if let string = dictionary[Key.passwordHint.rawValue] as? String {
      passwordHint = string
    }

    if let string = dictionary[Key.userID.rawValue] as? String {
      userID = string
    }

    if let string = dictionary[Key.loginShell.rawValue] as? String,
      let shell = LoginShell(rawValue: string) {
      loginShell = shell
    }

    if let string = dictionary[Key.homeDirectory.rawValue] as? String {
      homeDirectory = string
    }

    if let userAccount = dictionary[Key.hideUserAccount.rawValue] as? Bool,
      let homeDirectory = dictionary[Key.hideHomeDirectory.rawValue] as? Bool,
      let automatically = dictionary[Key.loginAutomatically.rawValue] as? Bool,
      let setupAssistant = dictionary[Key.skipSetupAssistant.rawValue] as? Bool {
      hideUserAccount = userAccount
      hideHomeDirectory = homeDirectory
      loginAutomatically = automatically
      skipSetupAssistant = setupAssistant
    }
  }

  /**
   NSDictionary representation of document object
  */
  var dictionary: NSDictionary {
    let dictionary = NSMutableDictionary()
    dictionary[Key.accountType.rawValue] = accountType.rawValue
    dictionary[Key.fullName.rawValue] = fullName
    dictionary[Key.accountName.rawValue] = accountName
    dictionary[Key.picture.rawValue] = picture.isValid ? picture.tiffRepresentation : nil
    dictionary[Key.passwordHint.rawValue] = passwordHint
    dictionary[Key.userID.rawValue] = userID
    dictionary[Key.loginShell.rawValue] = loginShell.rawValue
    dictionary[Key.homeDirectory.rawValue] = homeDirectory
    dictionary[Key.hideUserAccount.rawValue] = hideUserAccount
    dictionary[Key.hideHomeDirectory.rawValue] = hideHomeDirectory
    dictionary[Key.loginAutomatically.rawValue] = loginAutomatically
    dictionary[Key.skipSetupAssistant.rawValue] = skipSetupAssistant
    return dictionary
  }
}
