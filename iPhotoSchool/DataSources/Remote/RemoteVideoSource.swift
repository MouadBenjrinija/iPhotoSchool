//
//  RemoteVideoSource.swift
//  iPhotoSchool
//
//  Created by MOUAD BENJRINIJA on 19/1/2023.
//

import Foundation
import Combine

protocol RemoteVideoSource {
  func downloadVideo(from url: URL?) -> AnyPublisher<DownloadStatus, Error>
  func cancelDownload()
}

class RemoteVideoSourceMain: RemoteVideoSource {

  var session: URLSession!
  var downloadTask: URLSessionDownloadTask?
  var observation: NSKeyValueObservation?

  init() {
    let config = URLSessionConfiguration.default
    session = URLSession(configuration: config, delegate: nil, delegateQueue: OperationQueue())
  }

  func downloadVideo(from url: URL?) -> AnyPublisher<DownloadStatus, Error> {
    guard let url else {
      return Fail(error: DownloadError.invalidURL).eraseToAnyPublisher()
    }
    cancelDownload()
    let subject = PassthroughSubject<DownloadStatus, Error>()
    downloadTask = session.downloadTask(with: url) { localURL, _, error in
      guard let localURL else {
        subject.send(completion: .failure(error ?? DownloadError.failedToDownload))
        return
      }
      subject.send(.finished(localURL: localURL))
      subject.send(completion: .finished)
    }
    observation = downloadTask?.progress.observe(\.fractionCompleted) { progress, _ in
      subject.send(.downloading(progress: Int(progress.fractionCompleted * 100)))
    }
    downloadTask?.resume()
    return subject.eraseToAnyPublisher()
  }

  func cancelDownload() {
    downloadTask?.cancel()
    observation?.invalidate()
  }

  deinit {
    cancelDownload()
    session.finishTasksAndInvalidate()
    session.invalidateAndCancel()
  }

}

enum DownloadStatus {
  case downloading(progress: Int)
  case finished(localURL: URL)
}

enum DownloadError: Error {
  case invalidURL
  case failedToDownload
  case downloadCanceled
}
