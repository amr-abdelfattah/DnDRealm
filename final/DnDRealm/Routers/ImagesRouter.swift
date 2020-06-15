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

enum ImagesRouter {
  case images(query: String)
  case refreshToken(refreshToken: String)
  case upload
  
  var baseURL: URL {
    URL(string: "https://api.imgur.com")!
  }
  
  static var authorizationURL = URL(string: "https://api.imgur.com/oauth2/authorize?client_id=\(AuthenticationKeys.clientId)&response_type=token")!
  
  var path: String {
    switch self {
    case .images:
      return "3/gallery/search/top/all"
    case .refreshToken:
      return "oauth2/token"
    case .upload:
      return "3/upload"
    }
  }
  
  var method: HTTPMethod {
    switch self {
    case .images:
      return .get
    case .refreshToken,
         .upload:
      return .post
    }
  }
  
  var parameters: [String: String] {
    switch self {
    case let .images(query: query):
      return ["q_any": "\(query)"]
    case let .refreshToken(refreshToken: refreshToken):
      return ["refresh_token": refreshToken,
              "client_id": AuthenticationKeys.clientId,
              "client_secret": AuthenticationKeys.clientSecret,
              "grant_type": "refresh_token"]
    case .upload:
      return [:]
    }
  }
}

// MARK: - URLRequestConvertible
extension ImagesRouter: URLRequestConvertible {
  func asURLRequest() throws -> URLRequest {
    let url = baseURL.appendingPathComponent(path)
    var request = URLRequest(url: url)
    request.method = method
    request = try URLEncodedFormParameterEncoder(destination: .methodDependent)
      .encode(parameters, into: request)
    return request
  }
}
