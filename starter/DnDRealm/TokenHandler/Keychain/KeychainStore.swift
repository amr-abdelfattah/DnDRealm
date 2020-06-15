/// Copyright (c) 2020 Amr Elsayed
/// 
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
/// 
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
/// 
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
/// 
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import Foundation

class KeychainStore {
  static let `default` = KeychainStore()
  private let service = "default"
  
  @discardableResult
  func set(_ value: String, for userAccount: String) -> Bool {
    guard let encodedPassword = value.data(using: .utf8) else {
      return false
    }
    var query = [String(kSecAttrService): service,
                 String(kSecClass): kSecClassGenericPassword,
                 String(kSecAttrAccount): userAccount] as [String : Any]
    var status = SecItemCopyMatching(query as CFDictionary, nil)
    switch status {
    case errSecSuccess:
      var attributesToUpdate: [String: Any] = [:]
      attributesToUpdate[String(kSecValueData)] = encodedPassword
      status = SecItemUpdate(query as CFDictionary,
                             attributesToUpdate as CFDictionary)
      return status == errSecSuccess
    case errSecItemNotFound:
      query[String(kSecValueData)] = encodedPassword
      status = SecItemAdd(query as CFDictionary, nil)
      return status == errSecSuccess
    default:
      return false
    }
  }
  
  func value(for userAccount: String) -> String? {
    let query = [String(kSecAttrService): service,
                 String(kSecClass): kSecClassGenericPassword,
                 String(kSecAttrAccount): userAccount,
                 String(kSecMatchLimit): kSecMatchLimitOne,
                 String(kSecReturnAttributes): kCFBooleanTrue as Any,
                 String(kSecReturnData): kCFBooleanTrue as Any] as [String : Any]
    var queryResult: AnyObject?
    let status = withUnsafeMutablePointer(to: &queryResult) {
      SecItemCopyMatching(query as CFDictionary, $0)
    }
    switch status {
    case errSecSuccess:
      guard
        let queriedItem = queryResult as? [String: Any],
        let passwordData = queriedItem[String(kSecValueData)] as? Data,
        let password = String(data: passwordData, encoding: .utf8)
        else {
          return nil
      }
      return password
    default:
      return nil
    }
  }
}
