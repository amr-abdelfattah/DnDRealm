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

import Alamofire

protocol Authenticator: class, TokenHandler {
  func refreshToken(completion: @escaping (_ isSuccess: Bool) -> Void)
}

// MARK: - Token Refresher
extension Authenticator {
  func refreshToken(completion: @escaping (_ isSuccess: Bool) -> Void) {
    guard let refreshToken = refreshToken else {
      return completion(false)
    }
    AF.request("https://api.imgur.com/oauth2/token",
               method: .post,
               parameters: ["refresh_token": refreshToken,
                            "client_id": AuthenticationKeys.clientId,
                            "client_secret": AuthenticationKeys.clientSecret,
                            "grant_type": "refresh_token"])
      .validate()
      .responseDecodable(of: AuthenticationData.self) { [weak self] response in
        guard let self = self, let response = response.value else {
            return completion(false)
        }
        self.saveTokens(accessToken: response.accessToken, refreshToken: response.refreshToken)
        completion(true)
    }
  }
}

// MARK: - Error Code Checker
extension Int {
  func isAuthenticationErrorCode() -> Bool {
    [401, 403].contains(self)
  }
}
