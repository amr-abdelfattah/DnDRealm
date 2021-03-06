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

class ImagesCollectionViewController: UICollectionViewController {
  var items: [GalleryItem] = []
  var query: String?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setTitle()
    fetchImages()
  }
  
  private func setTitle() {
    navigationItem.title = query
  }
}

// MARK: - UICollectionViewDataSource
extension ImagesCollectionViewController {
  override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return items.count
  }
  
  override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    guard
      let imageCell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageCollectionViewCell.identifier, for: indexPath) as? ImageCollectionViewCell
      else {
        return UICollectionViewCell()
    }
    let item = items[indexPath.row]
    imageCell.configure(with: item)
    return imageCell
  }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension ImagesCollectionViewController: UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    let cellWidth = (collectionView.bounds.width/2) - 5
    let cellHeight = cellWidth
    return CGSize(width: cellWidth, height: cellHeight)
  }
}

// MARK: - UICollectionViewDelegate
extension ImagesCollectionViewController {
  override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    // TODO: Handle UploadRequest State
  }
}

// MARK: - Alamofire DataRequest
extension ImagesCollectionViewController {
  func fetchImages() {
    guard let query = query else { return }
    AF.request("https://api.imgur.com/3/gallery/search/top/all",
               parameters: ["q_any": "\(query),Dragons"])
      .validate()
      .responseDecodable(of: Images.self) { response in
        switch response.result {
        case let .success(images):
          self.items = images.all
          self.streamImages()
          self.collectionView.reloadData()
        case let .failure(error):
          self.presentAlertController(with: error.localizedDescription)
        }
    }
  }
}

// MARK: - Alamofire DataStreamRequest
extension ImagesCollectionViewController {
  func streamImages() {
    // TODO: Stream Images Requests
  }
}

// MARK: - Alamofire UploadRequest


// MARK: - Alamofire Request


// MARK: - Error Display
extension ImagesCollectionViewController {
  func showError(_ responseError: ResponseError?) {
    guard let responseError = responseError else { return }
    if responseError.isAuthenticationError {
      presentAuthenticationAlert(with: responseError.localizedDescription)
    } else {
      presentAlertController(with: responseError.localizedDescription)
    }
  }
  
  func presentAuthenticationAlert(with message: String) {
    presentAlertController(with: message) {
      // TODO: Login Action
    }
  }
}
