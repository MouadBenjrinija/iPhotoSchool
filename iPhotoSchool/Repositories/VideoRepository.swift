//
//  VideoRepository.swift
//  iPhotoSchool
//
//  Created by MOUAD BENJRINIJA on 19/1/2023.
//

import Foundation
import Combine

protocol VideoRepository {
  func downloadVideo(from url: URL?) -> AnyPublisher<DownloadStatus, Error>
  func video(for urlString: String?) -> Loadable<URL>
  func cancelDownload()
}

struct VideoRepositoryMain: VideoRepository {

  let remoteSource: RemoteVideoSource
  let localSource: LocalVideoSource

  func downloadVideo(from url: URL?) -> AnyPublisher<DownloadStatus, Error> {
    return remoteSource
      .downloadVideo(from: url)
      .handleEvents(receiveOutput: { status in
        if case .finished(localURL: let localURL) = status, let url {
          _ = try? localSource.saveFile(url: localURL, for: url) // should handle error
        }
      })
      .eraseToAnyPublisher()
  }

  func video(for urlString: String?) -> Loadable<URL> {
    guard let urlString, let url = URL(string: urlString) else { return .notLoaded } // todo: handle error
    if let localUrl = localSource.urlFor(file: urlString) {
      return .loaded(value: localUrl, source: .local)
    } else {
      return .loaded(value: url, source: .remote)
    }
  }

  func cancelDownload() {
    remoteSource.cancelDownload()
  }
}
