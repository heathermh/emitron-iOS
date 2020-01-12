/// Copyright (c) 2020 Razeware LLC
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

final class DataCacheChildContentsViewModel: ChildContentsViewModel {
  private let service: ContentsService

  init(parentContentId: Int, downloadAction: DownloadAction, repository: Repository, service: ContentsService) {
    self.service = service
    super.init(parentContentId: parentContentId, downloadAction: downloadAction, repository: repository)
  }
  
  override func configureSubscriptions() {
    repository
      .childContentsState(for: parentContentId)
      .sink(receiveCompletion: { [weak self] (completion) in
        guard let self = self else { return }
        if case .failure(let error) = completion, (error as? DataCacheError) == DataCacheError.cacheMiss {
          self.getContentDetailsFromService()
        } else {
          self.state = .failed
          Failure
            .repositoryLoad(from: "DataCacheContentDetailsViewModel", reason: "Unable to retrieve download content detail: \(completion)")
            .log()
        }
      }, receiveValue: { [weak self] (childContentsState) in
        guard let self = self else { return }
        
        self.state = .hasData
        self.contents = childContentsState.contents
        self.groups = childContentsState.groups
      })
      .store(in: &subscriptions)
  }
  
  private func getContentDetailsFromService() {
    self.state = .loading
    service.contentDetails(for: parentContentId) { (result) in
      switch result {
      case .failure(let error):
        self.state = .failed
        Failure
          .fetch(from: String(describing: type(of: self)), reason: error.localizedDescription)
          .log(additionalParams: nil)
      case .success(let (_, cacheUpdate)):
        self.repository.apply(update: cacheUpdate)
        self.reload()
      }
    }
  }
}
