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

class ImagesRequestInterceptor: RequestInterceptor, Authenticator {
  var retryLimit = 3
  var lastProceededResponse: HTTPURLResponse?
  
  func retry(_ request: Request,
             for session: Session,
             dueTo error: Error,
             completion: @escaping (RetryResult) -> Void) {
    guard
      lastProceededResponse != request.response,
      request.retryCount < retryLimit,
      let statusCode = request.response?.statusCode,
      statusCode.isAuthenticationErrorCode()
      else {
        return completion(.doNotRetry)
    }
    lastProceededResponse = request.response
    refreshToken { isSuccess in
      isSuccess ? completion(.retry) : completion(.doNotRetry)
    }
  }
  
  func adapt(_ urlRequest: URLRequest,
             for session: Session,
             completion: @escaping (Result<URLRequest, Error>) -> Void) {
    var urlRequest = urlRequest
    if let accessToken = accessToken {
      urlRequest.headers.add(.authorization(bearerToken: accessToken))
      completion(.success(urlRequest))
    } else {
      completion(.failure(ResponseError.authentication(message: "Login to Imgur to enjoy streaming and uploading")))
    }
  }
}
