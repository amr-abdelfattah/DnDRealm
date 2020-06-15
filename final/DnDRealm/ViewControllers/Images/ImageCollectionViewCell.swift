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

enum ImageCellState {
  case none
  case uploading
  case uploaded
}

class ImageCollectionViewCell: UICollectionViewCell {
  static let identifier = "ImageCollectionViewCell"
  private var item: GalleryItem?
  @IBOutlet weak var imageView: UIImageView!
  @IBOutlet weak var iconImageView: UIImageView!
  @IBOutlet weak var progressBar: UIProgressView!
  
  private var state: ImageCellState = .none {
    didSet {
      applyCellState()
    }
  }
  
  override func awakeFromNib() {
    super.awakeFromNib()
    resetCell()
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    resetCell()
  }
}

// MARK: - Cell Configuration
extension ImageCollectionViewCell {
  func configure(with image: GalleryItem) {
    item = image
    configureDataStream(with: image)
    if let uploadRequest = image.uploadRequest {
      configureWithUploadRequest(uploadRequest)
    }
  }
}

// MARK: - DataStream
extension ImageCollectionViewCell {
  private func configureDataStream(with image: GalleryItem) {
    setImage(with: image.data)
    monitorDataStream(for: image)
  }
  
  private func monitorDataStream(for image: GalleryItem) {
    image.responseStream = { [weak self] data in
      guard let self = self else { return }
      NSObject.cancelPreviousPerformRequests(withTarget: self)
      self.perform(#selector(self.setImage(with:)), with: data, afterDelay: 0.2)
    }
  }
}

// MARK: - UploadRequest
extension ImageCollectionViewCell {
  private func configureWithUploadRequest(_ uploadRequest: UploadRequest) {
    updateCellState(with: uploadRequest.state)
    monitorUploadProgress(for: uploadRequest)
  }
  
  private func updateCellState(with requestState: Request.State) {
    switch requestState {
    case .initialized, .resumed:
      state = .uploading
    case .finished:
      state = .uploaded
    default:
      state = .none
    }
  }
  
  private func monitorUploadProgress(for uploadRequest: UploadRequest) {
    updateCellProgress(uploadRequest.uploadProgress)
    uploadRequest.uploadProgress(closure: { [weak self] progress in
      guard let self = self else { return }
      self.updateCellProgress(progress)
    })
  }
}

// MARK: - Cell Modifiers
extension ImageCollectionViewCell {
  private func resetCell() {
    NSObject.cancelPreviousPerformRequests(withTarget: self)
    item?.responseStream = nil
    resetCellState()
    setImage(with: nil)
  }
  
  private func resetCellState() {
    state = .none
  }
  
  private func applyCellState() {
    switch state {
    case .none:
      iconImageView.isHidden = false
      progressBar.isHidden = true
    case .uploading:
      iconImageView.isHidden = true
      progressBar.isHidden = false
    case .uploaded:
      iconImageView.isHidden = true
      progressBar.isHidden = true
    }
  }
  
  private func updateCellProgress(_ progress: Progress) {
    progressBar.setProgress(Float(progress.fractionCompleted), animated: true)
  }
  
  @objc private func setImage(with data: Data?) {
    guard let data = data else {
      return imageView.image = nil
    }
    imageView.image = UIImage(data: data)
  }
}
