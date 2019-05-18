//
//  DocumentObject.swift
//  MacUserGenerator
//
//  Created by Nindi Gill on 11/10/17.
//  Copyright © 2017 Nindi Gill. All rights reserved.
//

import Cocoa

class DocumentObject: NSObject {

  enum Key: String {
    case AccountType
    case FullName
    case AccountName
    case Picture
    case Password
    case Verify
    case PasswordHint
    case UserID
    case GroupID
    case GeneratedUID
    case LoginShell
    case HomeDirectory
    case HideUserAccount
    case HideHomeDirectory
    case LoginAutomatically
    case SkipSetupAssistant
    case SkipiCloud
    case SkipSiri
    case SkipTouchID
    case SkipAnalytics
    case SkipDataPrivacy
  }
  
  enum AccountType: String {
    case Administrator
    case Standard
  }
  
  enum LoginShell: String {
    case bash = "/bin/bash"
    case tcsh = "/bin/tcsh"
    case sh = "/bin/sh"
    case csh = "/bin/csh"
    case zsh = "/bin/zsh"
  }

  // document defaults
  var accountType = AccountType.Administrator
  var fullName = ""
  var accountName = ""
  var picture = NSImage()
  var password = ""
  var verify = ""
  var passwordHint = ""
  var userID = ""
  var groupID = "20"
  var generatedUID = NSUUID().uuidString
  var loginShell = LoginShell.bash
  var homeDirectory = ""
  var hideUserAccount = false
  var hideHomeDirectory = false
  var loginAutomatically = false
  var skipSetupAssistant = false
  var skipiCloud = false
  var skipSiri = false
  var skipTouchID = false
  var skipAnalytics = false
  var skipDataPrivacy = false
  
  convenience init(dictionary: NSDictionary) {
    self.init()
    
    if let string = dictionary[Key.AccountType.rawValue] as? String,
      let type = AccountType(rawValue: string) {
      accountType = type
    }
    
    if let string = dictionary[Key.FullName.rawValue] as? String {
      fullName = string
    }
    
    if let string = dictionary[Key.AccountName.rawValue] as? String {
      accountName = string
    }
          
    if let data = dictionary[Key.Picture.rawValue] as? Data,
      let image = NSImage(data: data) {
      picture = image
    }
    else if let image = NSImage(named: "Picture") {
      picture = image
    }
    
    if let string = dictionary[Key.PasswordHint.rawValue] as? String {
      passwordHint = string
    }
    
    if let string = dictionary[Key.UserID.rawValue] as? String {
      userID = string
    }
    
    if let string = dictionary[Key.GroupID.rawValue] as? String {
      groupID = string
    }
    
    if let string = dictionary[Key.LoginShell.rawValue] as? String,
      let shell = LoginShell(rawValue: string) {
      loginShell = shell
    }
    
    if let string = dictionary[Key.HomeDirectory.rawValue] as? String {
      homeDirectory = string
    }
    
    if let boolean = dictionary[Key.HideUserAccount.rawValue] as? Bool {
      hideUserAccount = boolean
    }
    
    if let boolean = dictionary[Key.HideHomeDirectory.rawValue] as? Bool {
      hideHomeDirectory = boolean
    }
    
    if let boolean = dictionary[Key.LoginAutomatically.rawValue] as? Bool {
      loginAutomatically = boolean
    }
    
    if let boolean = dictionary[Key.SkipSetupAssistant.rawValue] as? Bool {
      skipSetupAssistant = boolean
    }
    
    if let boolean = dictionary[Key.SkipiCloud.rawValue] as? Bool {
      skipiCloud = boolean
    }
    
    if let boolean = dictionary[Key.SkipSiri.rawValue] as? Bool {
      skipSiri = boolean
    }
    
    if let boolean = dictionary[Key.SkipTouchID.rawValue] as? Bool {
      skipTouchID = boolean
    }
    
    if let boolean = dictionary[Key.SkipAnalytics.rawValue] as? Bool {
      skipAnalytics = boolean
    }
    
    if let boolean = dictionary[Key.SkipDataPrivacy.rawValue] as? Bool {
      skipDataPrivacy = boolean
    }
  }
  
  /**
   NSDictionary representation of document object
  */
  var dictionary: NSDictionary {
    let dictionary = NSMutableDictionary()
    dictionary[Key.AccountType.rawValue] = accountType.rawValue
    dictionary[Key.FullName.rawValue] = fullName
    dictionary[Key.AccountName.rawValue] = accountName
    dictionary[Key.Picture.rawValue] = picture.isValid ? picture.tiffRepresentation : nil
    dictionary[Key.PasswordHint.rawValue] = passwordHint
    dictionary[Key.UserID.rawValue] = userID
    dictionary[Key.GroupID.rawValue] = groupID
    dictionary[Key.LoginShell.rawValue] = loginShell.rawValue
    dictionary[Key.HomeDirectory.rawValue] = homeDirectory
    dictionary[Key.HideUserAccount.rawValue] = hideUserAccount
    dictionary[Key.HideHomeDirectory.rawValue] = hideHomeDirectory
    dictionary[Key.LoginAutomatically.rawValue] = loginAutomatically
    dictionary[Key.SkipSetupAssistant.rawValue] = skipSetupAssistant
    dictionary[Key.SkipiCloud.rawValue] = skipiCloud
    dictionary[Key.SkipSiri.rawValue] = skipSiri
    dictionary[Key.SkipTouchID.rawValue] = skipTouchID
    dictionary[Key.SkipAnalytics.rawValue] = skipAnalytics
    dictionary[Key.SkipDataPrivacy.rawValue] = skipDataPrivacy
    return dictionary
  }
}
