//
//  String+Extension.swift
//  MacUserGenerator
//
//  Created by Nindi Gill on 12/10/17.
//  Copyright © 2017 Nindi Gill. All rights reserved.
//

import Cocoa

extension String {

  /**
   A boolean value indicating if the provided string is a valid macOS account name (shortname).
   
   Must only contain alphanumberic characters, hyphens, underscores or periods.
  */
  var isValidAccountName: Bool {
    let pattern = "^[0-9a-zA-Z\\_\\-\\.]*[a-zA-Z]+[0-9a-zA-Z\\_\\-\\.]*$"
    return self.isValidWithPattern(pattern)
  }

  /**
   A boolean value indicating if the provided string is a valid User ID (uid).
   
   Must only contain digits.
  */
  var isValidUserID: Bool {
    let pattern = "^[0-9]+$"
    return self.isValidWithPattern(pattern)
  }

  /**
   A boolean value indicating if the provided string is a valid home directory.
   
   Must be a valid directory path.
  */
  var isValidHomeDirectory: Bool {
    let pattern = "^[\\/]([^\\:\\/]+[\\/]?)*$"
    return self.isValidWithPattern(pattern)
  }

  /**
   A boolean value indicating if the provided string is a valid pattern (regex).
  */
  private func isValidWithPattern(_ pattern: String) -> Bool {
    
    do {
      let regex = try NSRegularExpression(pattern: pattern, options: [])
      let length = self.distance(from: self.startIndex, to: self.endIndex)
      let matches = regex.matches(in: self, options: [], range: NSRange(location: 0, length: length))
      return !matches.isEmpty
    }
    catch {
      return false
    }
  }
  
  /**
   Returns a string replacing all matches of a pattern string with a given string.
   - Parameters:
     - pattern: The substring being searched for.
     - newString: The substring to replace all matches with.
  */
  func replacePatternMatches(of pattern: String, with newString: String) -> String {
  
    let distance = self.distance(from: self.startIndex, to: self.endIndex)
    
    do {
      let pattern = try NSRegularExpression(pattern: pattern, options: [])
      let range = NSRange(location: 0, length: distance)
      return pattern.stringByReplacingMatches(in: self, options: [], range: range, withTemplate: newString)
    }
    catch {
      return self
    }
  }
  
  /**
   Converts the provided string to a valid account name (shortname) string.
  */
  var convertedToAccountName: String {
    return self.replacePatternMatches(of: " ", with: "").lowercased()
  }
  
  /**
   Converts the provided string to a base64 encoded shadow hash, based on PBKDF2.
  */
  var shadowHash: String {
    
    let algorithm = CCPBKDFAlgorithm(kCCPBKDF2)
    
    guard let passwordData = self.data(using: .utf8) else {
      return ""
    }
    
    let password = [UInt8](passwordData).map { Int8(bitPattern: $0) }
    let passwordLen = password.count
    let saltString = String.randomSalt()
    let saltData = Data(hex: saltString)
    let salt = [UInt8](saltData)
    let saltLen = salt.count
    let prf = CCPseudoRandomAlgorithm(CCPBKDFAlgorithm(kCCPRFHmacAlgSHA512))
    let rounds = arc4random_uniform(UInt32(2^32-1))
    var derivedKey = [UInt8](repeating: 0, count: 128)
    let derivedKeyLen = derivedKey.count
    let status = CCKeyDerivationPBKDF(algorithm, password, passwordLen, salt, saltLen, prf, rounds, &derivedKey, derivedKeyLen)
    
    guard status == 0 else {
      return ""
    }
    
    let entropyData = Data(bytes: derivedKey, count: derivedKey.count)
    
    let string = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>" +
                 "<!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\">" +
                 "<plist version=\"1.0\">" +
                   "<dict>" +
                     "<key>SALTED-SHA512-PBKDF2</key>" +
                     "<dict>" +
                       "<key>entropy</key>" +
                       "<data>" +
                         entropyData.base64EncodedString() +
                       "</data>" +
                       "<key>iterations</key>" +
                       "<integer>" +
                         "\(rounds)" +
                       "</integer>" +
                       "<key>salt</key>" +
                       "<data>" +
                         saltData.base64EncodedString() +
                       "</data>" +
                     "</dict>" +
                   "</dict>" +
                 "</plist>"

    return string
  }
  
  /**
   Generates a random 64 character hex salt string
  */
  static func randomSalt() -> String {
    
    let characters = "0123456789abcdef"
    let length = UInt32(characters.count)
    var string = ""
    
    for _ in 0..<64 {
      let rand = Int(arc4random_uniform(length))
      let index = characters.index(characters.startIndex, offsetBy: rand)
      let character = characters[index]
      string = string + String(character)
    }
    
    return string
  }
  
  /**
   Converts the provided string to a base64 encoded kcpassword
  */
  var kcpassword: String {
    
    let characters = self.utf8.map{ UInt8($0) }
    let keys: [UInt8] = [125, 137, 82, 35, 210, 188, 221, 234, 163, 185, 31]
    var xors = [UInt8]()
    
    // xor each byte of the password
    for i in 0..<characters.count {
      let xor = characters[i] ^ keys[i % 11]
      xors.append(xor)
    }

    // pad the xor array with garbage until it's a multiple of 12 bytes long
    while xors.count % 12 != 0 {
      let character = UInt8(arc4random_uniform(50) + 50)
      let key = keys[Int(arc4random_uniform(UInt32(keys.count)))]
      let xor = character ^ key
      xors.append(xor)
    }
    
    let data = NSData(bytes: &xors, length: xors.count)
    let string = data.base64EncodedString(options: .lineLength64Characters)
    return string
  }
}
