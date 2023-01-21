//
//  MockVideoRepository.swift
//  iPhotoSchoolTests
//
//  Created by MOUAD BENJRINIJA on 20/1/2023.
//

import XCTest
import Combine
@testable import iPhotoSchool

class MockVideoRepository: Mock, VideoRepository {
  enum Action {
    case downloadVideo
    case videoForURL
    case cancelDownload
  }

  var recorder = MockActionRecorder<Action>(expected: [])
  var downloadVideoResponse: [DownloadStatus] = []
  var videoForUrlReponse: Loadable<URL> = .notLoaded

  var publisher: PassthroughSubject<DownloadStatus, Error>?

  func downloadVideo(from url: URL?) -> AnyPublisher<DownloadStatus, Error> {
    record(action: .downloadVideo)
    publisher = PassthroughSubject<DownloadStatus, Error>()
    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(550)) {[weak self] in
      self?.downloadVideoResponse.forEach { status in
        self?.publisher?.send(status)
        if case .finished(localURL: _) = status {
          self?.publisher?.send(completion: .finished)
        }
      }
    }
    return publisher!.eraseToAnyPublisher()
  }

  func video(for urlString: String?) -> iPhotoSchool.Loadable<URL> {
    record(action: .videoForURL)
    return videoForUrlReponse
  }

  func cancelDownload() {
    record(action: .cancelDownload)
    publisher?.send(completion: .failure(CancellationError()))
  }

  
}
