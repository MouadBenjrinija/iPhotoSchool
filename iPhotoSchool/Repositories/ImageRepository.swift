//
//  ImageRepository.swift
//  iPhotoSchool
//
//  Created by MOUAD BENJRINIJA on 18/1/2023.
//

import Foundation
import Combine
import UIKit.UIImage

protocol ImageRepository {
  func loadImage(from urlString: String?) async -> UIImage?
}

struct ImageRepositoryMain: ImageRepository {
  let localImageSource: LocalImageSource
  let remoteImageSource: RemoteImageSource

  func loadImage(from urlString: String?) async -> UIImage? {
    guard let urlString, let url = URL(string: urlString) else { return nil }
    if let image = await localImageSource.loadImage(for: url) {
      return image
    }
    if let image = try? await remoteImageSource.loadImage(from: url) {
      await localImageSource.saveImage(image: image, url: url)
      return image
    }
    return nil
  }

}
