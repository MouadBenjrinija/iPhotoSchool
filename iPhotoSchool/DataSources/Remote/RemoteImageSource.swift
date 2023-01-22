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
    // request a resized image for a better performance
    let urlComponents = NSURLComponents(url: url, resolvingAgainstBaseURL: false)
    urlComponents?.queryItems = [URLQueryItem(name: "image_crop_resized", value: "250x140")]
    guard let url = urlComponents?.url else { throw ImageLoaderError.urlError }
    return try await session.dataTaskPublisher(for: url)
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
  case urlError
}
