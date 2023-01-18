//
//  LocalImageRepository.swift
//  iPhotoSchool
//
//  Created by MOUAD BENJRINIJA on 18/1/2023.
//

import Foundation
import UIKit.UIImage

struct LocalImageRepository: LocalImageSource {

  let diskSource: LocalImageSource
  let cacheSource: LocalImageSource

  func loadImage(for url: URL) async -> UIImage? {
    if let image = await cacheSource.loadImage(for: url) {
      return image
    }
    if let image = await diskSource.loadImage(for: url) {
      await cacheSource.saveImage(image: image, url: url)
      return image
    }
    return nil
  }

  func saveImage(image: UIImage, url: URL) async {
    await diskSource.saveImage(image: image, url: url)
    await cacheSource.saveImage(image: image, url: url)
  }


}
