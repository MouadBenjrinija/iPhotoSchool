//
//  RemoteImageSource.swift
//  iPhotoSchool
//
//  Created by MOUAD BENJRINIJA on 18/1/2023.
//

import Foundation
import Combine
import UIKit.UIImage

protocol RemoteImageSource {
  func loadImage(from url: URL) async throws -> UIImage
}

struct RemoteImageSourceMain: RemoteImageSource {
  let session: URLSession

  func loadImage(from url: URL) async throws -> UIImage {
    try await session.dataTaskPublisher(for: url)
      .mapData()
      .tryMap {
        try UIImage(data: $0) ?? {
          throw ImageLoaderError.invalidData
        }()
      }
      .eraseToAnyPublisher()
      .async()
  }

}

enum ImageLoaderError: Error {
  case invalidData
}
